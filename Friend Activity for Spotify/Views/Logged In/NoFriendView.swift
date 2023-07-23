//
//  NoFriendView.swift
//  Friend Activity for Spotify
//
//  Created by Avi Wadhwa on 23/07/23.
//

import SwiftUI

struct NoFriendView: View {
    @EnvironmentObject var viewModel: FriendActivityBackend
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "person.fill.xmark")
                .font(.system(size: 100))
            Text("You have no friends (on Spotify)!\nAdd someone and refresh")
                .font(.custom("montserrat", size: 30))
                .bold()
                .multilineTextAlignment(.center)
            Button {
                viewModel.isLoading = true
                Task {
                    await viewModel.actor.getFriends()
                }
            } label: {
                Text("Refresh")
                    .font(.custom("montserrat", size: 30))
            }
        }
    }
}
