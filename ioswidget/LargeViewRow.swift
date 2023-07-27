//
//  LargeView.swift
//  macWidgetExtension
//
//  Created by Avi Wadhwa on 2022-04-25.
//

import SwiftUI
//import Kingfisher

struct LargeViewRow: View {
    var friend: Friend
    var image: UIImage
    var body: some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text("\(friend.user.name)")
                        .font(.bold(.custom("montserrat", size: 16))())
                        .lineLimit(1)
                    Spacer()
                }
                HStack (spacing: 2){
                    Text("\(friend.track.name) *•* \(friend.track.artist.name)")
                        .lineLimit(1)
                    .font(.custom("montserrat", size: 14))
                }
                HStack (spacing: 5){
                    let symbol: String = {
                        if (friend.track.context.name == friend.track.album.name) {
                            return "record.circle"
                        }
                        else if (friend.track.context.name == friend.track.artist.name) {
                            return "person"
                        }
                        return "music.note"
                    }()
                    Text("\(Image(systemName: symbol)) \(friend.track.context.name)")
                        .font(.custom("montserrat", size: 14))
                        .lineLimit(1)
                }
            }
        }
    }
}
