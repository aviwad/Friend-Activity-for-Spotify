//
//  TextLink.swift
//  SpotPlayer
//
//  Created by Avi Wadhwa on 2022-05-16.
//

import SwiftUI

struct TextLink: View {
    @State var underline: Bool = false
    var text: String
    var linkUrl: URL
    var body: some View {
        Text(text)
            .underline(underline)
            .onHover { inside in
                underline.toggle()
            }
            .lineLimit(1)
            .onTapGesture {
                globalURLOpener(URL: linkUrl)
            }
    }
}

// can't see underline on translucent Zstack. hence we indicate clickable link with NSCursor change instead of underline
struct TextLinkBottomBar: View {
    var text: String
    var linkUrl: URL
    var body: some View {
        Text(text)
            .lineLimit(1)
            .onTapGesture {
                globalURLOpener(URL: linkUrl)
            }
    }
}

