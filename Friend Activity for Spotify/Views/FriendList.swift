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
//    @State private var showAlert = false;
    private var timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
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
                //Text(viewModel.tappedRow)
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
                                ScrollView {
                                    ForEach(viewModel.friendArray!) { friend in
                                        VStack {
                                            FriendRow(friend: friend)
                                            Divider()
                                        }
                                    
                                    }
                                }
                                //hi
//                                List(viewModel.friendArray!) { friend in
//                                    FriendRow(friend: friend)
//                                    //.onTapGesture {
//                                    //  let impactMed = UIImpactFeedbackGenerator(style: .light)
//                                    //impactMed.impactOccurred()
//                                    //}
//                                        .swipeActions(edge: .leading){
//                                            Button {
//                                                globalURLOpener(URL: friend.user.url)
//                                            } label: {
//                                                Label("View Profile", systemImage: "person")
//                                            }
//                                            .tint(.accentColor)
//                                        }
//                                        .swipeActions(edge: .trailing){
//                                            Button {
//                                                globalURLOpener(URL: friend.track.album.url)
//                                            } label: {
//                                                Label("View Album", systemImage: "play.circle.fill")
//                                            }
//                                            .tint(.accentColor)
//                                        }
//                                }
                                //hi
//                                .actionSheet(isPresented: $showAlert) {
//                                    ActionSheet(title: Text("Resume Workout Recording"),
//                                                message: Text("Choose a destination for workout data"),
//                                                buttons: [
//                                                    .cancel(),
//                                                    .default(Text("Play Song \" \"")) {
//                                                        print("hi")
//                                                    },
//                                                    .default(Text("Open Artist ")) {
//
//                                                    },
//                                                    .default(Text("Open Album")) {
//
//                                                    },
//                                                    .default(Text("Open Profile")) {
//
//                                                    }
//                                                ]
//                                    )
//                                }
                                //.popover
                                //hi.listStyle(.plain)
                                .refreshable {
                                    print("logged, getfriendactivitynoanimation called from refreshing friendlist")
                                    await viewModel.GetFriendActivity(animation: true)
//                                    withAnimation {
//                                        viewModel.friendArray?.shuffle()
//                                    }
                                    
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
                                    await viewModel.GetFriendActivity(animation: true)
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
                                    Text("TestFlight Debug: Current Status")
                                    Text("Logged out status: \(viewModel.loggedOut.description)")
                                    Text("Friend Array Size: \(viewModel.friendArray?.count.description ?? "nil")")
                                    Text("Network Up: \(viewModel.networkUp.description)")
                                    Text("Tab Selection: \(viewModel.tabSelection)")
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
                if (!viewModel.loggedOut) {
                    Task {
                        print("timer works")
                        await getFriends()
                    }
                }
                else {
                    print("timer worked but it's logged out so nothign happened")
                }
            }
        }
    }
    
}
