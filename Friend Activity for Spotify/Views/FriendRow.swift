//
//  FriendRow.swift
//  SpotPlayerFriendActivitytest
//
//  Created by Avi Wadhwa on 2022-04-23.
//

import Foundation
import SwiftUI
import Nuke
import NukeUI

struct FriendRowMenuStyle: ButtonStyle {

  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .padding()
      .foregroundColor(.white)
      .background(configuration.isPressed ? Color.green : Color.accentColor)
      .cornerRadius(8.0)
  }

}



struct FriendRow: View {
    @StateObject var viewModel: FriendActivityBackend
    var friend: Friend
    //@State private var profilePictureHover = false
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
                let transition = AnyTransition.asymmetric(insertion: .slide, removal: .scale).combined(with: .opacity)
                ZStack {
                    if (FriendActivityBackend.shared.showProfilePic) {
                        Group {
                            if (friend.user.imageURL.isEmpty) {
                                Image(systemName: "person.fill")
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else{
                                LazyImage(url: URL(string: friend.user.imageURL)!) { state in
                                    if let image = state.image {
                                        image // Displays the loaded image
                                    } else {
                                        Image(systemName: "person.fill") // Indicates an error
                                    }
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                            }
                            if (friend.humanTimestamp.nowOrNot){
                                Circle()
                                    .frame(width: 11, height: 11)
                                    .foregroundColor(Color.blue)
                                    .offset(x: 16, y: -16)
                            }
                        }
                        .transition(transition)
                        //.scaleEffect(viewModel.showProfilePic ? 1.0 : 0.1)
                    }
                    else {
                        LazyImage(url: URL(string: friend.track.imageURL)!) { state in
                            if let image = state.image {
                                image // Displays the loaded image
                            }
                        }
                        .transition(transition)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        //.scaleEffect(viewModel.showProfilePic ? 0.1 : 1)
                    }
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(friend.user.name)
                            .lineLimit(1)
                            //.font(.custom("montserrat", size: 15))
                            .font(.bold(.custom("montserrat", size: 15))())
                        Spacer()
                        Text(friend.humanTimestamp.humanTimestamp)
                            .font(.custom("montserrat", size: 15))
                    }
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
            }
            .transition(.opacity)
            .foregroundColor(Color.white)
            .contentShape(Rectangle())
        }
        /*.contextMenu{
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
        }*/
    }
}
