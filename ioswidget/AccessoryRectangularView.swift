//
//  AccessoryRectangularView.swift
//  Friend Activity for Spotify
//
//  Created by Avi Wadhwa on 2025-02-15.
//

import SwiftUI
import WidgetKit


#Preview {
//    AccessoryRectangularView()
}


@available(iOSApplicationExtension 16.0, *)
struct AccessoryRectangularView: View {
    var entry: SimpleEntry
    
    var body: some View {
        Group {
            if let firstFriend = entry.friends.0.first, let firstFriendImage = entry.friends.pfp.first {
                HStack {
                    Image(uiImage: firstFriendImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())
//                        .padding(.trailing, 2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(firstFriend.user.name)
                            .font(.system(size: 14,weight: .bold))
                        Text(firstFriend.track.name)
                        .font(.system(size: 13,weight: .regular))
                        Text(firstFriend.track.artist.name)
                        .font(.system(size: 13,weight: .regular))
                        .opacity(0.5)
                    }
                    .lineLimit(1)
                    Spacer()
//                    Spacer()
                }
            }
            else {
                HStack {
                    Text("Select a favorite friend!")
                    Spacer()
                }
            }
        }
//        .frame(alignment: .leading)
        .widgetBackground(backgroundView: EmptyView())
    }
}
