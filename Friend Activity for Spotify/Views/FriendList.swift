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
import Shimmer
import StoreKit

struct FriendRowList: View {
    @StateObject var viewModel: FriendActivityBackend
//    @State private var showAlert = false;
    private var timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    //@State var friendArray: [Friend] = []
    init() {
        self._viewModel = StateObject(wrappedValue: FriendActivityBackend.shared)
    }
    
//    func getFriends() async {
//        if viewModel.networkUp {
//            print("logged, getfriendactivity called from getfriends function")
//            await viewModel.GetFriendActivity()
//        }
//        // if data is empty: state text that says 0 friends
//        // check monitor connected
//        //withAnimation(){
//          //  friendArray = data
//        //}
//    }
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    if viewModel.networkUp {
                        if (viewModel.friendArray != nil) {
                            if viewModel.friendArray!.count == 0 {
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
                            else {
                                ScrollView {
                                    ForEach(viewModel.friendArray!) { friend in
                                        VStack {
                                            FriendRow(friend: friend)
                                            Divider()
                                        }

                                    }
                                }
                                .refreshable {
                                    print("logged, getfriendactivitynoanimation called from refreshing friendlist")
                                    await viewModel.actor.getFriends()
                                    let count = UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")?.integer(forKey: "successCount") ?? 0
                                    if (count > 20) {
                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                                            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                                                SKStoreReviewController.requestReview(in: scene)
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                        
                        else {
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
                                .refreshable {
                                    print("logged, getfriendactivity called from refreshing the shimmering placeholder")
                                    URLSession.shared.delegateQueue.cancelAllOperations()
                                    URLSession.shared.invalidateAndCancel()
                                    await viewModel.actor.getFriends()
                                }
                                VStack {
                                    Button{
                                        Task {
                                            print("logged, getfriendactivity called from shimmering placeholder")
                                            URLSession.shared.delegateQueue.cancelAllOperations()
                                            URLSession.shared.invalidateAndCancel()
                                            URLSession.shared.getAllTasks { tasks in
//                                                .filter { $0.state == .running }
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
                    else {
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
                                    await viewModel.actor.getFriends()
                                }
                            }
                        }
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
