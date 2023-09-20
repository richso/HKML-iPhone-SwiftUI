//
//  FBWebviewSwiftUIAdaptor.swift
//  HkmlApp
//
//  Created by Richard So on 4/9/2023.
//

import SwiftUI
import WebKit
import SKPhotoBrowser

struct FBWebviewSwiftUIView: UIViewControllerRepresentable {
    typealias UIViewControllerType = FBWebviewController
    @Binding var tabSelection: Int
    @ObservedObject var jumpManager: JumpManager

    func makeUIViewController(context: Context) -> FBWebviewController {
        let storyboard = UIStoryboard(name: "main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(identifier: "FBViewContainer") as FBWebviewController
        controller.targetUrl = jumpManager.fb_url
        
        NSLog("@@@@makeUIViewController: " + jumpManager.fb_url)
        return controller
    }
    
    func updateUIViewController(_ controller: FBWebviewController, context: Context) {
        
        var eff_url = jumpManager.fb_url
        if eff_url == "" {
            eff_url = controller.mainUrl
        }
        if ((controller.webView) != nil) {
            controller.webView.load(URLRequest(url:URL(string:eff_url)!))
        } else {
            controller.targetUrl = eff_url
        }
        
    }
    
}
