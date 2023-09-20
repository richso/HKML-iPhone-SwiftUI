//
//  MasterpiecePhotos.swift
//  HkmlApp
//
//  Created by Richard So on 7/9/2023.
//

import SwiftUI
import WebKit
import SDWebImageSwiftUI
import UIKit
import SKPhotoBrowser
import SDWebImage

struct MasterpiecePhotos: View {
    var wkProcessPool: WKProcessPool // = WKProcessPool()
    var mp: Masterpiece
    @StateObject var mpData = MPPhotosData()
    @State private var isSharePresented: Bool = false
    @State var askLogin: Bool = false
    @State var showWebsite: Bool = false
    @State var goURL = ""
    @State var showLoginPanel = false

    var body: some View {
        ZStack {
            MasterpieceWebView(wkProcessPool: wkProcessPool, mp: mp, mpData: mpData, askLogin: $askLogin).hidden()
            VStack {
                Group{
                    Text(mp.name + " (" + mp.author + ")")
                        .font(.title3)
                        .scaledToFill()
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                }.frame(maxHeight: 20, alignment: .top)
                if mpData.objects.count == 0 {
                    Spacer()
                    Button("Requires Login", role: .cancel) {
                        showLoginPanel = true
                    }.sheet(isPresented: $showLoginPanel, onDismiss: {
                        //print("Dismiss")
                        mpData.webview?.reload()
                    }, content: {
                        LoginPageView(wkProcessPool: wkProcessPool, requireLogin: $showLoginPanel)
                    })
                    Spacer()
                } else {
                    List(mpData.objects, id: \.id) {photo in
                        WebImage(url: URL(string: photo.img))
                            .resizable()
                            .scaledToFit()
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                            .onTapGesture {
                                var images = [SKPhoto]()
                                for idx in 0...mpData.objects.count-1 {
                                    let photo = SKPhoto.photoWithImageURL(mpData.objects[idx].img)
                                    images.append(photo)
                                    photo.shouldCachePhotoURLImage = true
                                }
                                
                                let browser = SKPhotoBrowser(
                                    photos: images,
                                    initialPageIndex: photo.id)
                                
                                UIApplication
                                    .shared
                                    .connectedScenes
                                    .compactMap { $0 as? UIWindowScene }
                                    .flatMap { $0.windows }
                                    .last { $0.isKeyWindow }?.rootViewController?.present(browser, animated: true, completion: {})

                            }
                    }.listStyle(PlainListStyle())
                        
                }
                Group{
                    HStack {
                        Button(mp.author, role: .cancel) {
                            self.showWebsite = true
                            self.goURL = mp.author_href
                        }.padding(10)
                            .fullScreenCover(
                                isPresented: $showWebsite,
                                onDismiss: {
                                //print("Dismiss")
                            }, content: {
                                TabForumFB(
                                    wkProcessPool: wkProcessPool,
                                    url: $goURL,
                                    showWebsite: $showWebsite
                                )
                            })
                        Spacer()

                        Button(action: {
                            self.isSharePresented = true
                        }, label: {
                            Label("",
                                  systemImage: "square.and.arrow.up"
                            ).foregroundColor(.black)
                        }).padding(10).sheet(isPresented: $isSharePresented, onDismiss: {
                            print("Dismiss")
                        }, content: {
                            let shareUrl =
                                mp.href.replacingOccurrences(
                                    of: "%23",
                                    with: "#"
                                )
                            ActivityViewController(activityItems: [URL(string: shareUrl)!])
                        })
                        Spacer()
                        
                        Button("Website", role: .cancel) {
                            self.showWebsite = true
                            self.goURL = mp.href
                        }.padding(10)
                            .fullScreenCover(
                                isPresented: $showWebsite,
                                onDismiss: {
                                    //print("Dismiss")
                                }, content: {
                                    TabForumFB(
                                        wkProcessPool: wkProcessPool,
                                        url: $goURL,
                                        showWebsite: $showWebsite
                                    )
                                }
                            )
                    }
                }.frame(maxHeight: 30, alignment: .bottom)
            }
        }
    }
}

struct MasterpiecePhotos_Previews: PreviewProvider {
    static var previews: some View {
        MasterpiecePhotos(wkProcessPool: WKProcessPool(), mp: Masterpiece(id: 1, name: "Gundam RX88", image: "http://www.hkml.net/Discuz/images/headPic/thumb6.jpg", href: "http://www.hkml.net/Discuz/redirect.php?tid=181361&goto=lastpost", author: "author", author_href: "http://www.hkml.net/Discuz/space.php?uid=23723"))
    }
}

struct ImgModel {
    var id: Int
    var title: String
    var img: String
    var href: String
    var author: String
    var author_href: String
    var img_height: CGFloat = 0
}

class MPPhotosData: ObservableObject {
    @Published var objects: [ImgModel] = []
    @Published var loggedIn: Bool = false
    
    var webview: WKWebView?
}

struct MasterpieceWebView: UIViewRepresentable {
    var wkProcessPool: WKProcessPool
    var mp: Masterpiece
    @StateObject var mpData: MPPhotosData
    @Binding var askLogin: Bool
    var last_url = ""

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        
        SKCache.sharedCache.imageCache = SDToSKCache()
        
        //let wkProcessPool = WKProcessPool()
        config.processPool = wkProcessPool
        let userContentController = WKUserContentController()
        config.userContentController = userContentController
        userContentController.add(context.coordinator, name: "hkmlApp")
        
        let webview = WKWebView(frame: CGRect.zero, configuration: config)

        webview.navigationDelegate = context.coordinator
        
        mpData.webview = webview
        
        webview.load(URLRequest(url:URL(string: mp.href)!))
        let hkmlAppJs = "https://raw.githubusercontent.com/richso/hkmlApp/master/public_html/getModelPhotos.js"
        
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
            let scriptPath = Bundle.main.path(forResource: "getModelPhotos.js", ofType: "js")
            scriptContent = try? String(contentsOfFile: scriptPath!, encoding:big5encoding)
        }

        let script = WKUserScript(source: scriptContent!, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        config.userContentController.addUserScript(script)
        return webview
    }

    func updateUIView(_ webview: WKWebView, context: Context) {
        context.coordinator.webView = webview
        
        if context.coordinator.last_url != mp.href {
            webview.load(URLRequest(url:URL(string: mp.href)!))
            context.coordinator.last_url = mp.href
        }
    }

    func makeCoordinator() -> MPWebViewCoordinator {
        return MPWebViewCoordinator(view: self)
    }
}

class MPWebViewCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
    let path_prefix = "http://www.hkml.net/Discuz/"
    var parent: MasterpieceWebView
    var webView: WKWebView? = nil
    var cookie_str = ""
    var last_url = ""

    init(view: MasterpieceWebView) {
        self.parent = view
        super.init()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive: WKScriptMessage) {
        
        if (didReceive.name == "hkmlApp") {
            
            self.cookie_str = ""
            self.webView?.configuration.websiteDataStore.httpCookieStore.getAllCookies({
                    (cookies) in
                        for (cookie) in cookies {
                            self.cookie_str += cookie.name + "=" + cookie.value + "; "
                        }
                
                        // sync the session & other cookies
                        let requestModifier = SDWebImageDownloaderRequestModifier { (request) -> URLRequest? in
                            if (request.url?.host == "www.hkml.net") {
                                var mutableRequest = request
                                mutableRequest.setValue(self.cookie_str, forHTTPHeaderField: "Cookie")
                                return mutableRequest
                            }
                            return request
                        };
                        SDWebImageDownloader.shared.requestModifier = requestModifier
                        
                        // receive the jsondata
                        if let d = didReceive.body as? [String:Any] {
                            if d["loggedIn"] != nil {
                                let loggedIn = d["loggedIn"] as! Bool
                                if !loggedIn {
                                    self.parent.askLogin = true
                                }
                            }
                            
                            if let models = d["photos"] as? [Any] {
                                var objects = [ImgModel]()
                                
                                if models.count > 0 {
                                    for i in 0...models.count-1 {
                                        let model = models[i]
                                        if let modelSpec = model as? [String:Any] {
                                            var imgsrc = modelSpec["img"] as? String
                                            
                                            if (!((imgsrc?.hasPrefix("http:"))! || (imgsrc?.hasPrefix("https:"))!)) {
                                                imgsrc = self.path_prefix + imgsrc!
                                            }
                                            
                                            NSLog("@image url: " + imgsrc!)
                                            
                                            objects.append(ImgModel(
                                                id: i,
                                                title: "",
                                                img: imgsrc!,
                                                href: "",
                                                author: "",
                                                author_href: "",
                                                img_height: 0
                                            ))
                                        }
                                    }
                                }
                                
                                self.parent.mpData.objects = objects
                            }
                        }
            })
        }
    }
}
