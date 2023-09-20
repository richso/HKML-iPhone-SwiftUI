//
//  MainScreen.swift
//  HkmlApp
//
//  Created by Richard So on 19/9/2023.
//

import SwiftUI
import WebKit

struct MainScreen: View {
    @State var isActive = false
    var wkProcessPool = WKProcessPool()
    
    var body: some View {
        ZStack {
            if !isActive {
                SplashScreen()
            } else {
                MasterpiecesList(wkProcessPool: wkProcessPool)
            }
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                isActive = true
            })
        }
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
