//
//  FriendRow.swift
//  SpotPlayerFriendActivitytest
//
//  Created by Avi Wadhwa on 2022-04-23.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

// struct FriendRowMenuStyle: ButtonStyle {

//  func makeBody(configuration: Self.Configuration) -> some View {
//    configuration.label
//      .padding()
//      .foregroundColor(.white)
//      .background(configuration.isPressed ? Color.green : Color.accentColor)
//      .cornerRadius(8.0)
//  }
//
//}
//


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
                }
            label: {
                HStack {
                    ZStack {
                        if (friend.user.imageURL.isEmpty) {
                            Image(systemName: "person.fill")
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } else{
                            WebImage(url: URL(string: friend.user.imageURL)) //{
                                .placeholder(Image(systemName: "person.fill").resizable())
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50, alignment: .center)
                                .clipShape(Circle())
                            if (friend.humanTimestamp.nowOrNot){
                                Circle()
                                    .frame(width: 11, height: 11)
                                    .foregroundColor(Color.blue)
                                    .offset(x: 16, y: -16)
                            }
                                
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
                            WebImage(url: URL(string: friend.track.imageURL)) //{
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 30, alignment: .trailing)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .foregroundColor(Color.white)
                .contentShape(Rectangle())
        }
    }
}
