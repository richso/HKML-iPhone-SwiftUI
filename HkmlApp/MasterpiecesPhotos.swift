//
//  MasterpiecesPhotos.swift
//  HkmlApp
//
//  Created by Richard So on 15/9/2023.
//

import SwiftUI
import WebKit

struct MasterpiecesPhotos<Page: View>: View {
    var wkProcessPool: WKProcessPool
    @State var pages: [Page]
    @State var currentPage = 0
    
    var body: some View {
        PageViewController(pages: $pages, currentPage: $currentPage)
    }
}

struct MasterpiecesPhotos_Previews: PreviewProvider {
    static var previews: some View {
        MasterpiecesPhotos(wkProcessPool: WKProcessPool(), pages:[
            MasterpiecePhotos(wkProcessPool: WKProcessPool(), mp: Masterpiece(id: 1, name: "Gundam RX88", image: "http://www.hkml.net/Discuz/images/headPic/thumb6.jpg", href: "http://www.hkml.net/Discuz/redirect.php?tid=181361&goto=lastpost", author: "author", author_href: "http://www.hkml.net/Discuz/space.php?uid=23723")),
            MasterpiecePhotos(wkProcessPool: WKProcessPool(), mp: Masterpiece(id: 1, name: "Gundam RX88", image: "http://www.hkml.net/Discuz/images/headPic/thumb6.jpg", href: "http://www.hkml.net/Discuz/redirect.php?tid=181361&goto=lastpost", author: "author", author_href: "http://www.hkml.net/Discuz/space.php?uid=23723"))
        ])
    }
}
