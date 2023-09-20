//
//  SKPhotoBrowserController.swift
//  HkmlApp
//
//  Ref: https://github.com/suzuki-0000/SKPhotoBrowser/issues/403
//

import SwiftUI
import SKPhotoBrowser

struct SKPhotoViewerController: UIViewControllerRepresentable {
    var viewerImages:[SKPhoto]
    var currentPageIndex: Int
    @Binding var showing: Bool
    
    func makeUIViewController(context: Context) -> SKPhotoBrowser {
        SKPhotoBrowserOptions.displayHorizontalScrollIndicator = false
        let browser = SKPhotoBrowser(photos: viewerImages)
        browser.initializePageIndex(currentPageIndex)
        browser.delegate = context.coordinator
        return browser
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIViewController(_ browser: SKPhotoBrowser, context: Context) {
        browser.photos = viewerImages
        browser.currentPageIndex = currentPageIndex
    }
    
    class Coordinator: NSObject, SKPhotoBrowserDelegate {
        
        var control: SKPhotoViewerController
        
        init(_ control: SKPhotoViewerController) {
            self.control = control
        }
        
        func didShowPhotoAtIndex(_ browser: SKPhotoViewerController) {
            //self.control.currentPageIndex = browser.currentPageIndex
        }
        
        func willDismissAtPageIndex(_ index: Int) {
            // when PhotoBrowser will be dismissed
            self.control.showing = false
        }
        
    }
}
