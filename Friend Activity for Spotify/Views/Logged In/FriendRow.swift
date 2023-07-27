//
//  FriendRow.swift
//  SpotPlayerFriendActivitytest
//
//  Created by Avi Wadhwa on 2022-04-23.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI


struct FriendRow: View {
    var friend: Friend
    var body: some View {
            Menu {
                Link(destination: friend.track.url) {
                    Label("Play Song", systemImage: "play")
                }
                Link(destination: friend.user.url) {
                    Label("View Profile", systemImage: "person")
                }
                Link(destination: friend.track.artist.url) {
                    Label("View Artist", systemImage: "music.mic.circle")
                }
                Link(destination: friend.track.album.url) {
                    Label("View Album", systemImage: "record.circle")
                }
                if (friend.track.context.name != friend.track.artist.name && friend.track.context.name != friend.track.album.name) {
                    Link(destination: friend.track.context.url) {
                        Label("View Playlist", systemImage: "music.note")
                    }
                }
            
                #if DEBUG
                if let userImage = friend.user.imageURL {
                    Link(destination: userImage) {
                        Label("View User Image", systemImage: "person.circle.fill")
                    }
                }
                if let albumArt = friend.track.imageURL {
                    Link(destination: albumArt) {
                        Label("View Album Art", systemImage: "play.square")
                    }
                }
                #endif
            }
            label: {
                HStack {
                    ZStack {
                        WebImage(url: friend.user.imageURL) //{
                            .placeholder {
                                Image(systemName: "person.fill")
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50, alignment: .center)
                            .animation(.default, value: friend.user.imageURL)
                            .transition(.fade)
                            .clipShape(Circle())
                        if (friend.humanTimestamp.nowOrNot){
                            Circle()
                                .frame(width: 11, height: 11)
                                .foregroundColor(Color.blue)
                                .offset(x: 16, y: -16)
                                .transition(.scale)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(friend.user.name)
                                .lineLimit(1)
                                .font(.bold(.custom("montserrat", size: 15))())
                            Spacer()
                            Text(LocalizedStringKey(friend.humanTimestamp.humanTimestamp))
                                .font(.custom("montserrat", size: 15))
                        }
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                HStack (spacing: 2){
                                    Text(friend.track.name)
                                        .lineLimit(1)
                                        .font(.custom("montserrat", size: 15))
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 4))
                                    Text(friend.track.artist.name)
                                        .lineLimit(1)
                                        .font(.custom("montserrat", size: 15))
                                }
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
                                    Text(friend.track.context.name)
                                        .lineLimit(1)
                                        .font(.custom("montserrat", size: 15))
                                }
                            }
                            Spacer()
                            WebImage(url: friend.track.imageURL) //{
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 30, alignment: .trailing)
                                .animation(.default)
                                .transition(.fade)
                        }
                    }
                    .transition(.opacity)
                    Spacer()
                }
                .padding(.horizontal)
                .foregroundColor(Color.white)
                .contentShape(Rectangle())
        }
    }
}
