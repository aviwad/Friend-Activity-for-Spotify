//
//  NoNetworkView.swift
//  Friend Activity for Spotify
//
//  Created by Avi Wadhwa on 23/07/23.
//

import SwiftUI

struct NoNetworkView: View {
    @EnvironmentObject var viewModel: FriendActivityBackend
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 100))
            VStack {
                Text("Your device is disconnected from the network.")
                    .font(.custom("montserrat", size: 15))
                    .bold()
                    .multilineTextAlignment(.center)
                Text("Try again later.")
                    .font(.custom("montserrat", size: 15))
                    .bold()
                    .multilineTextAlignment(.center)
            }
            Button("Refresh") {
                Task {
                    await viewModel.GetFriends()
                }
            }
        }
    }
}
