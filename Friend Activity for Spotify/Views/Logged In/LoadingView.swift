//
//  LoadingView.swift
//  Friend Activity for Spotify
//
//  Created by Avi Wadhwa on 23/07/23.
//

import SwiftUI

struct LoadingView: View {
    @EnvironmentObject var viewModel: FriendActivityBackend
    
    var body: some View {
        ZStack {
            List {
                FriendRowPlaceholder()
                    .redacted(reason: .placeholder)
                FriendRowPlaceholder()
                    .redacted(reason: .placeholder)
                FriendRowPlaceholder()
                    .redacted(reason: .placeholder)
                FriendRowPlaceholder()
                    .redacted(reason: .placeholder)
                FriendRowPlaceholder()
                    .redacted(reason: .placeholder)
                FriendRowPlaceholder()
                    .redacted(reason: .placeholder)
                FriendRowPlaceholder()
                    .redacted(reason: .placeholder)
                FriendRowPlaceholder()
                    .redacted(reason: .placeholder)
                FriendRowPlaceholder()
                    .redacted(reason: .placeholder)
                FriendRowPlaceholder()
                    .redacted(reason: .placeholder)
            }
            .shimmering(active: viewModel.friendArray == nil)
            .listStyle(.plain)
            VStack {
                Button{
                    Task {
                        print("logged, getfriendactivity called from shimmering placeholder")
                        URLSession.shared.delegateQueue.cancelAllOperations()
                        URLSession.shared.invalidateAndCancel()
                        URLSession.shared.getAllTasks { tasks in
                            for task in tasks where task.state == .running {
                                task.cancel()
                            }
                        }
                        await viewModel.actor.getFriends()
                    }
                } label: {
                    Text("Refresh")
                        .font(.custom("montserrat",size: 20))
                        .bold()
                        .padding(10)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
}

