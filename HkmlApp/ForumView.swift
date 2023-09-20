//
//  ForumView.swift
//  HkmlApp
//
//  Created by Richard So on 4/9/2023.
//

import SwiftUI
import SKPhotoBrowser
import WebKit

struct Message: Identifiable {
    var id: String {title + ":" + message}
    let title: String
    let message: String
}

struct ForumView: View {
    var wkProcessPool: WKProcessPool
    var url: String = ""
    @Binding var tabSelection: Int

    var body: some View {
        VStack {
            ZStack {
                ForumWebviewSwiftUIView(wkProcessPool: wkProcessPool, url: url, tabSelection: $tabSelection)
            }
        }
    }
}

struct ForumView_Previews: PreviewProvider {
    static var previews: some View {
        ForumView(wkProcessPool: WKProcessPool(), url: "", tabSelection: .constant(1))
    }
}
