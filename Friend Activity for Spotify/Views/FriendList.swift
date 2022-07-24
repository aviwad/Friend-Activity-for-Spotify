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
    @State var showDebugFriendSheet = false
    private var timer = Timer.publish(every: 120, on: .main, in: .common).autoconnect()
    //@State var friendArray: [Friend] = []
    
    init() {
        self._viewModel = StateObject(wrappedValue: FriendActivityBackend.shared)
    }
    
    func getFriends() async {
        print("testing123: getfriends function called")
        if viewModel.networkUp {
            print("testing123: getfriendactivity called")
            await viewModel.GetFriendActivity()
        }
        // if data is empty: state text that says 0 friends
        // check monitor connected
        //withAnimation(){
          //  friendArray = data
        //}
    }
    var body: some View {
        VStack {
            Group {
                Text("DEBUG: \(viewModel.debug)")
                Text("ERROR: \(viewModel.error)")
                Button("DEBUG: CLICK HERE FOR FRIEND LIST") {
                    showDebugFriendSheet.toggle()
                }
                Button("hsuffle") {
                    withAnimation() {
                        viewModel.friendArray?.shuffle()
                    }
                }
            }
            ZStack {
                if viewModel.networkUp {
                    if (viewModel.friendArray != nil) {
                        if viewModel.friendArray!.count == 0 {
                            VStack(spacing: 30) {
                                Image(systemName: "person.fill.xmark")
                                    .font(.system(size: 100))
                                Text("You have no friends!\nAdd someone and refresh")
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
                            //                            .onReceive(timer) { _ in
                            //                                Task {
                            //                                    print("timer works")
                            //                                    await getFriends()
                            //                                }
                            //                            }
                            .listStyle(.plain)
                            .refreshable {
                                print("refreshable works")
                                await viewModel.GetFriendActivityNoAnimation()
                            }
                        }
                    }
                    
                    else {
                        List {
                            FriendRowPlaceholder()
                                .redacted(reason: .placeholder)
                                .shimmering()
                            FriendRowPlaceholder()
                                .redacted(reason: .placeholder)
                                .shimmering()
                            FriendRowPlaceholder()
                                .redacted(reason: .placeholder)
                                .shimmering()
                            FriendRowPlaceholder()
                                .redacted(reason: .placeholder)
                                .shimmering()
                            FriendRowPlaceholder()
                                .redacted(reason: .placeholder)
                                .shimmering()
                            FriendRowPlaceholder()
                                .redacted(reason: .placeholder)
                                .shimmering()
                            FriendRowPlaceholder()
                                .redacted(reason: .placeholder)
                                .shimmering()
                            FriendRowPlaceholder()
                                .redacted(reason: .placeholder)
                                .shimmering()
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await viewModel.GetFriendActivityNoAnimation()
                        }
                    }
                }
                else {
                    VStack(spacing: 30) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 100))
                        Text("Your device is disconnected from the network.\nTry again later.")
                            .font(.custom("montserrat", size: 15))
                            .bold()
                            .multilineTextAlignment(.center)
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
        .sheet(isPresented: $showDebugFriendSheet) {
            ScrollView {
                let lol = dump(viewModel.friendArray)
                Text(viewModel.friendArray?.debugDescription ?? "no friends loser")
            }
        }
        .onAppear {
            Task {
                print("on appear of vstack")
                await getFriends()
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
