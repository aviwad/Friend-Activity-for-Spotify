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
                // .aspectRatio(contentMode: .fill)
            //Image(systemName: "person.fill")
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            //KFImage(URL(string: friend.user.imageURL))
              //  .placeholder{Image(systemName: "person.fill")}
               // .resizable()
                //.frame(width: 40, height: 40)
                //.clipShape(Circle())
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text("\(friend.user.name)")
                        //.minimumScaleFactor(0.8)
                        .font(.bold(.custom("montserrat", size: 16))())
                        .lineLimit(1)
                    Spacer()
                }
                    //.minimumScaleFactor(0.8)
                HStack (spacing: 2){
                    Text("\(friend.track.name) *•* \(friend.track.artist.name)")
                        .lineLimit(1)
                //Text(" • ").bold() +
                    //.minimumScaleFactor(0.8)
                //Text("\(friend.track.artist.name)")//"\($0.user.description)")
                    //.minimumScaleFactor(0.8)
                    .font(.custom("montserrat", size: 14))
                    //.lineLimit(1)
                }
                //.minimumScaleFactor(0.8)
                HStack (spacing: 5){
                    if (friend.track.context.name == friend.track.album.name) {
                        Image(systemName: "record.circle")
                    }
                    else if (friend.track.context.name == friend.track.artist.name) {
                        Image(systemName: "person")
                    }
                    else {
                        Image(systemName: "music.note")
                    }
                    Text("\(friend.track.context.name)")//"\($0.user.description)")
                        //.minimumScaleFactor(0.8)
                        .font(.custom("montserrat", size: 14))
                        .lineLimit(1)
                }
                   // .minimumScaleFactor(0.8)
            }
        } //.minimumScaleFactor(0.85)
    }
}
