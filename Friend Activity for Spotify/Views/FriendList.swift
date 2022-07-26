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

struct FriendRowList: View {
    @StateObject var viewModel: FriendActivityBackend
    private var timer = Timer.publish(every: 120, on: .main, in: .common).autoconnect()
    //@State var friendArray: [Friend] = []
    
    init() {
        self._viewModel = StateObject(wrappedValue: FriendActivityBackend.shared)
    }
    
    func getFriends() async {
        if viewModel.networkUp {
            print("logged, getfriendactivity called from getfriends function")
            await viewModel.GetFriendActivity(animation: true)
        }
        // if data is empty: state text that says 0 friends
        // check monitor connected
        //withAnimation(){
          //  friendArray = data
        //}
    }
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
                                        Task {
                                            await getFriends()
                                        }
                                    } label: {
                                        Text("Refresh")
                                            .font(.custom("montserrat", size: 30))
                                    }
                                }
                            }
                            else {
                                List(viewModel.friendArray!) { friend in
                                    FriendRow(friend: friend)
                                    //.onTapGesture {
                                    //  let impactMed = UIImpactFeedbackGenerator(style: .light)
                                    //impactMed.impactOccurred()
                                    //}
                                    
                                        .swipeActions(edge: .leading){
                                            Button {
                                                globalURLOpener(URL: friend.user.url)
                                            } label: {
                                                Label("View Profile", systemImage: "person")
                                            }
                                            .tint(.accentColor)
                                        }
                                        .swipeActions(edge: .trailing){
                                            Button {
                                                globalURLOpener(URL: friend.track.album.url)
                                            } label: {
                                                Label("View Album", systemImage: "play.circle.fill")
                                            }
                                            .tint(.accentColor)
                                        }
                                }
                                .listStyle(.plain)
                                .refreshable {
                                    print("logged, getfriendactivitynoanimation called from refreshing friendlist")
                                    await viewModel.GetFriendActivity(animation: false)
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
                                    await viewModel.GetFriendActivity(animation: true)
                                }
                                VStack {
                                    Button{
                                        Task {
                                            print("logged, getfriendactivity called from shimmering placeholder")
                                            await viewModel.GetFriendActivity(animation: true)
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
                                    await getFriends()
                                }
                            }
                        }
                        .onChange(of: viewModel.friendArray?.count) { change in
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                    }
                }
                .fullScreenCover(isPresented: $viewModel.loggedOut) {
                    loginSheet()
                }
            }
            .onReceive(timer) { _ in
                Task {
                    print("timer works")
                    await getFriends()
                }
            }
        }
    }
    
}
