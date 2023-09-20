//
//  ForumWebviewSwiftUIAdaptor.swift
//  HkmlApp
//
//  Created by Richard So on 4/9/2023.
//

import SwiftUI
import WebKit
import SKPhotoBrowser

struct ForumWebviewSwiftUIView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ForumWebviewController
    var wkProcessPool: WKProcessPool = WKProcessPool()
    var url: String = ""
    var parentView: TabForumFB?
    @Binding var tabSelection: Int
    @ObservedObject var jumpManager: JumpManager
    
    func selectTab(_ int: Int) {
        
        NSLog("@@selectedTab: %d", int)
        
        self.tabSelection = int
    }
    
    func makeUIViewController(context: Context) -> ForumWebviewController {
        //return ForumWebviewController(nibName: "main", bundle: nil)
        let storyboard = UIStoryboard(name: "main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(identifier: "ForumWebViewContainer") as ForumWebviewController
        controller.wkProcessPool = wkProcessPool
        controller.parentView = self
        controller.jumpManager = jumpManager
        
        NSLog("@Forum URL: " + url)
        
        if url != "" {
            controller.targetUrl = url
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ForumWebviewController, context: Context) {
        // nothing
    }
    
}
