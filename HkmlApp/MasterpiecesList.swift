//
//  MasterpiecesList.swift
//  HkmlApp
//
//  Created by Richard So on 5/9/2023.
//

import SwiftUI
import UIKit
import WebKit
import Combine
import SDWebImage

struct MasterpiecesList: View {
    var wkProcessPool: WKProcessPool //= WKProcessPool()
    @State var showWebsite: Bool = false

    private let memoryWarningPublisher = NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)

    @StateObject var mpData = MPData()
    @State private var selection: Int?
    @State var showLoginButton: Bool = false
    @State private var showLoginPanel: Bool = false
    @State private var visibility = NavigationSplitViewVisibility.doubleColumn
    
    var body: some View {
        ZStack {
                VStack {
                    NavigationSplitView(columnVisibility: $visibility ) {
                        Group {
                            HStack {
                                Button("Login", role: .cancel) {
                                    self.showLoginPanel = true
                                }
                                .padding(10).opacity(showLoginButton ? 1 : 0)
                                .sheet(isPresented: $showLoginPanel, onDismiss: {
                                    //print("Dismiss")
                                    mpData.webview?.reload()
                                }, content: {
                                    LoginPageView(wkProcessPool: wkProcessPool, requireLogin: $showLoginPanel)
                                })
                                Spacer()
                                Text("HKML Masterpieces")
                                    .font(.title3)
                                Spacer()
                                Button("    ", role: .cancel) {
                                    self.showWebsite = true
                                }.padding(10)
                                    .fullScreenCover(isPresented: $showWebsite, onDismiss: {
                                        //print("Dismiss")
                                    }, content: {
                                        TabForumFB(
                                            wkProcessPool: wkProcessPool,
                                            url: .constant(""),
                                            showWebsite: $showWebsite
                                        )
                                    })
                            }
                        }.frame(maxHeight: 30, alignment: .top)
                        List(mpData.objects, selection: $selection) {mp in
                                MasterpiecesRow(mp:mp)
                        }
                        .listStyle(PlainListStyle())
                        .onReceive(mpData.$objects, perform: {objects in
                            
                            if objects.count > 0 {
                                mpData.pages = []
                                objects.forEach { object in
                                    mpData.pages.append(
                                        MasterpiecePhotos(
                                            wkProcessPool: wkProcessPool,
                                            mp: object
                                        )
                                    )
                                }
                            }
                        })
                        .refreshable {
                            mpData.webview?.reload()
                        }
                    } detail: {
                        ZStack {
                            if let index = selection {
                                MasterpiecesPhotos(
                                    wkProcessPool: wkProcessPool,
                                    pages: mpData.pages,
                                    currentPage: index
                                )
                                .id(index)
                                // workaround: https://developer.apple.com/forums/thread/707924?answerId=741647022#741647022
                            }
                        }
                    }

                }.onReceive(memoryWarningPublisher) { _ in
                    SDImageCache.shared.clearMemory()
                }
            MasterpiecesWebView(
                wkProcessPool: wkProcessPool,
                mpData: mpData,
                showLoginButton: $showLoginButton
            ).hidden()
        }
    }
}

class MPData: ObservableObject {
    @Published var objects: [Masterpiece] = []
    var webview: WKWebView?
    @Published var pages: [MasterpiecePhotos] = []
}

struct MasterpiecesWebView: UIViewRepresentable {
    var wkProcessPool: WKProcessPool
    @StateObject var mpData: MPData
    @Binding var showLoginButton: Bool

    func makeUIView(context: Context) -> WKWebView {
        let topTenUrl = "http://www.hkml.net/Discuz/toptendetails.php?colNum=10"

        let config = WKWebViewConfiguration()
        //let wkProcessPool = self.wkProcessPool
        config.processPool = wkProcessPool
        let userContentController = WKUserContentController()
        config.userContentController = userContentController
        userContentController.add(context.coordinator, name: "hkmlApp")
        
        let webview = WKWebView(frame: CGRect.zero, configuration: config)
        
        mpData.webview = webview

        webview.navigationDelegate = context.coordinator
        webview.load(URLRequest(url:URL(string: topTenUrl)!))
        let hkmlAppJs = "https://raw.githubusercontent.com/richso/hkmlApp/master/public_html/getTopModels.js"
        
        let filePath = Bundle.main.path(forResource: "jquery-1.12.4.min", ofType: "js")
        var jquery = try? String(contentsOfFile: filePath!, encoding:String.Encoding.utf8)
        
        jquery = (jquery!) + " $j=jQuery.noConflict();";
        let jqScript = WKUserScript(source: jquery!, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        config.userContentController.addUserScript(jqScript)
        
        let cfEnc = CFStringEncodings.big5_HKSCS_1999
        let nsEnc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
        let big5encoding = String.Encoding(rawValue: nsEnc) // String.Encoding
        
        let scriptURL = hkmlAppJs + "?" + String(arc4random())
        var scriptContent = try? String(contentsOf: URL(string: scriptURL)!, encoding: big5encoding)
        if (scriptContent == nil) {
            let scriptPath = Bundle.main.path(forResource: "getTopModels", ofType: "js")
            scriptContent = try? String(contentsOfFile: scriptPath!, encoding:big5encoding)
        }

        let script = WKUserScript(source: scriptContent!, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        config.userContentController.addUserScript(script)
        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.webView = uiView
        //uiView.reload()
    }

    func makeCoordinator() -> WebViewCoordinator {
        return WebViewCoordinator(view: self)
    }
}

class WebViewCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
    let path_prefix = "http://www.hkml.net/Discuz/"
    var parent: MasterpiecesWebView
    var webView: WKWebView? = nil

    init(view: MasterpiecesWebView) {
        self.parent = view
        super.init()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive: WKScriptMessage) {
        
        if (didReceive.name == "hkmlApp") {
            
            // receive the jsondata
            if let d = didReceive.body as? [String:Any] {
                
                if d["loggedIn"] != nil {
                    let loggedIn = (d["loggedIn"] as? Bool)!
                    if loggedIn {
                        self.parent.showLoginButton = false
                    } else {
                        self.parent.showLoginButton = true
                    }
                } else {
                    // for backward compatibility
                    self.parent.showLoginButton = true
                }
                
                if let models = d["billboard"] as? [Any] {
                    var objects = [Masterpiece]()
                    
                    for i in 0...39 {
                        let model = models[i]
                        if let modelSpec = model as? [String:Any] {
                            NSLog(path_prefix + (modelSpec["img"] as? String)!)
                            
                            let t_title = (modelSpec["title"] as? String)!
                            
                            objects.append(Masterpiece(
                                id: i,
                                name: t_title.decodingHTMLEntities(),
                                image: path_prefix + (modelSpec["img"] as? String)!,
                                href: path_prefix + (modelSpec["href"] as? String)!,
                                author: (modelSpec["author"] as? String)!,
                                author_href: path_prefix + (modelSpec["author_href"] as? String)!
                            ))
                        }
                    }
                    
                    self.parent.mpData.objects = objects
                }
            }
            
        }

    }
}

struct MasterpiecesList_Previews: PreviewProvider {
    static var previews: some View {
        MasterpiecesList(wkProcessPool: WKProcessPool())
    }
}
