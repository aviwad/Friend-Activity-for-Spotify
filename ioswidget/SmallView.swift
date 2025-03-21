//
//  SmallView.swift
//  Friend Activity for Spotify
//
//  Created by Avi Wadhwa on 2025-02-15.
//
import WidgetKit
import SwiftUI

struct SmallView: View {
    var entry: SimpleEntry
    @Environment(\.displayScale) var displayScale
    
    var body: some View {
        Group {
            if let firstFriend = entry.friends.0.first, let firstFriendImage = entry.friends.1.first, let albumArt = entry.friends.albumart {
                VStack {
                    VStack (spacing: 0) {
                        HStack() {
                            Image(uiImage: firstFriendImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                                .clipShape(Circle())
                            Text(firstFriend.user.name)
                                .foregroundColor(Color("WhiteColor"))
                                .lineLimit(1)
//                                .frame(width: 80, height: 30)
                                .font(.custom("montserrat",size: 13))
                            Spacer()
                        }
                    }
                    .preferredColorScheme(.dark)
                    .frame(maxWidth: .infinity, // Full Screen Width
                                //maxHeight: .infinity, // Full Screen Height
                                alignment: .topLeading) // Align To top
                    VStack(alignment: .trailing) {
                        ZStack {
                            Rectangle()
                       .foregroundStyle(.gray)
                            Image(uiImage: albumArt)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .cornerRadius(5)
                            .frame(width: 70, height: 70)
                        Text(firstFriend.track.name)
                            .foregroundColor(Color("WhiteColor"))
                            .lineLimit(1)
                        Text(firstFriend.track.artist.name)
                            .font(.custom("montserrat", size: 11))
                            .lineLimit(1)
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity, // Full Screen Width
                                //maxHeight: .infinity, // Full Screen Height
                           alignment: .bottomTrailing) // Align To top
                    .preferredColorScheme(.dark)
                    .font(.custom("montserrat",size: 13))
//                    .border(.brown)
                }
                .padding(16)
            }
            else {
                VStack (spacing: 10) {
                    Image(systemName: "person.fill.xmark")
                        .font(.system(size: 40))
                        .foregroundColor(Color("WhiteColor"))
                    VStack {
                        Text("Set a favorite friend")
                            .font(.bold(.system(size: 15))())
                            .foregroundColor(Color("WhiteColor"))
                        Text("(i've updated! click to re-login maybe?)")
                            .font(.bold(.system(size: 15))())
                            .foregroundColor(Color("WhiteColor"))
                    }
                }
    //                .frame(maxHeight: .infinity)
            }
        }
        .widgetBackground(backgroundView: Color("WidgetBackground"))
            
    }
//        .widgetBackground(backgroundView: Color("WidgetBackground"))
}
