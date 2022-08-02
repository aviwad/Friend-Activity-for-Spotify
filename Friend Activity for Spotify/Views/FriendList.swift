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
    private var imageSwitchTimer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
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
                                    FriendRow(viewModel: viewModel, friend: friend)
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
                                    FriendRowPlaceholder()
                                        .redacted(reason: .placeholder)
                                        .shimmering()
                                    FriendRowPlaceholder()
                                        .redacted(reason: .placeholder)
                                        .shimmering()
                                }
                                .listStyle(.plain)
                                .refreshable {
                                    print("logged, getfriendactivity called from refreshing the shimmering placeholder")
                                    await viewModel.GetFriendActivity(animation: true)
                                }
                                VStack {
                                    Button{
                                        Task {
                                            //viewModel.debugLog.append("logged, getfriendactivitynoanimation called from shimmering placeholder \n")
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
            /*.onAppear {
                Task {
                    viewModel.debugLog.append("logged, on vstack appear \n")
                    print("on appear of vstack")
                    await getFriends()
                }
            }*/
            .onReceive(timer) { _ in
                Task {
                    print("timer works")
                    await getFriends()
                }
            }
            .onReceive(imageSwitchTimer) { _ in
                print("logged image switch timer called")
                withAnimation(.easeInOut(duration: 0.5)) {
                    viewModel.showProfilePic.toggle()
                    print(viewModel.showProfilePic)
                }
            }
           /* if (FriendActivityBackend.shared.currentError != nil) {
                Text("An error occurred \(FriendActivityBackend.shared.currentError!)")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .foregroundColor(.red)
                    .background(.white)
                    .cornerRadius(5)
                    .frame(maxHeight: .infinity, alignment: .top)
            }*/
        }
    }
    
}
