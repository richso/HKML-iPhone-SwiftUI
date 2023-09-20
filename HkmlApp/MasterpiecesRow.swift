//
//  MasterpiecesRow.swift
//  HkmlApp
//
//  Created by Richard So on 5/9/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct MasterpiecesRow: View {
    let mp: Masterpiece
    
    var body: some View {
        HStack {
            WebImage(url: URL(string: mp.image))
                .placeholder {
                    Rectangle().foregroundColor(.gray)
                }
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 100)
                .padding(.trailing, 10)
            VStack {
                HStack {
                    Text(mp.name).font(.title3)
                    Spacer()
                }
                HStack {
                    Spacer()
                    Text(mp.author)
                }.font(.subheadline)
            }
        }
    }
}

struct MasterpiecesRow_Previews: PreviewProvider {
    static var previews: some View {
        MasterpiecesRow(mp: Masterpiece(id: 1, name: "title", image: "http://www.hkml.net/Discuz/images/headPic/thumb6.jpg", href: "http://www.hkml.net/Discuz/redirect.php?tid=181361&goto=lastpost", author: "author", author_href: "http://www.hkml.net/Discuz/space.php?uid=23723"))
    }
}
