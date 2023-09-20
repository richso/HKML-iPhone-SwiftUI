//
//  SplashScreen.swift
//  HkmlApp
//
//  Created by Richard So on 19/9/2023.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            Rectangle()
                .background(Color.mint)
                .foregroundColor(Color.mint)
            VStack {
                Spacer()
                Image("hkml-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                Spacer()
                Text(
                    "Open source project sponsored by" + "\n" +
                    "Netrogen Creative, copyright " +
                    String(Calendar.current.component(.year, from: Date()))
                ).fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
