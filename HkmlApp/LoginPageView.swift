//
//  ForumWebviewSwiftUIAdaptor.swift
//  HkmlApp
//
//  Created by Richard So on 4/9/2023.
//

import SwiftUI
import WebKit

struct LoginPageView: UIViewControllerRepresentable {
    //typealias UIViewControllerType = LoginViewController
    var wkProcessPool: WKProcessPool = WKProcessPool()
    var url: String = ""
    @Binding var requireLogin: Bool
    
    func makeUIViewController(context: Context) -> LoginViewController {
        let storyboard = UIStoryboard(name: "main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(identifier: "loginViewContainer") as LoginViewController
        controller.wkProcessPool = wkProcessPool
        controller.parentView = self
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: LoginViewController, context: Context) {
        // nothing
    }
    
}
