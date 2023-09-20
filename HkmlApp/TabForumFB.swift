//
//  TabForumFB.swift
//  HkmlApp
//
//  Created by Richard So on 4/9/2023.
//

import SwiftUI
import WebKit

class JumpManager : ObservableObject {
    @Published var fb_url: String = ""
}

struct TabForumFB: View {
    @State private var tabSelection = 1
    var wkProcessPool: WKProcessPool // = WKProcessPool()
    @Binding var url: String
    @Binding var showWebsite: Bool
    @StateObject var jumpManager: JumpManager = JumpManager()

    var body: some View {
        VStack {
            Button("Back to photo collection", role: .cancel) {
                self.showWebsite = false
            }
            TabView(selection: $tabSelection) {
                ForumWebviewSwiftUIView(
                    wkProcessPool: wkProcessPool,
                    url: url,
                    parentView: self,
                    tabSelection: $tabSelection,
                    jumpManager: jumpManager
                )
                    .tabItem {
                        Label("Forum", systemImage: "house.fill")
                    }.tag(1)
                
                FBWebviewSwiftUIView(
                    tabSelection: $tabSelection,
                    jumpManager: jumpManager
                )
                    .tabItem {
                        Label("Facebook", systemImage: "f.cursive.circle.fill")
                    }.tag(2)
            }
        }
    }
}

struct TabForumFB_Previews: PreviewProvider {
    static var previews: some View {
        TabForumFB(wkProcessPool: WKProcessPool(),
                   url: .constant(""), showWebsite: .constant(true))
    }
}
