//
//  FriendList.swift
//  SpotPlayerFriendActivitytest
//
//  Created by Avi Wadhwa on 2022-04-23.
//

import Foundation
import SwiftUI
import WidgetKit
import Network
import StoreKit

struct FriendRowList: View {
    @EnvironmentObject var viewModel: FriendActivityBackend
    private var timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    if viewModel.networkUp {
                        if let friendArray = viewModel.friendArray {
                            if friendArray.count == 0 {
                                NoFriendView()
                            } else {
                                ScrollView {
                                    ForEach(friendArray) { friend in
                                        VStack {
                                            FriendRow(friend: friend)
                                            Divider()
                                        }

                                    }
                                }
                                .refreshable {
                                    print("logged, getfriendactivitynoanimation called from refreshing friendlist")
                                    Task {
                                        await viewModel.actor.getFriends()
                                        #if RELEASE
                                        let count = UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")?.integer(forKey: "successCount") ?? 0
                                        if (count > 20) {
                                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                                                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                                                    SKStoreReviewController.requestReview(in: scene)
                                                }
                                            }
                                        }
                                        #endif
                                    }
                                }
                            }
                        } else {
                            LoadingView()
                        }
                    }
                    else {
                        NoNetworkView()
                    }
                }
                .fullScreenCover(isPresented: $viewModel.loggedOut) {
                    loginSheet()
                }
            }
            .onReceive(timer) { _ in
                if (!viewModel.loggedOut) {
                    viewModel.isLoading = true
                    Task {
                        print("timer works")
                        await viewModel.actor.getFriends()
                    }
                }
                else {
                    print("timer worked but it's logged out so nothign happened")
                }
            }
        }
    }
}
