//
//  ContentView.swift
//  Friend Activity for Spotify
//
//  Created by Avi Wadhwa on 2022-06-13.
//

import SwiftUI



struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var viewModel : FriendActivityBackend
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "montserrat", size: 30)!]
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "montserrat", size: 20)!]
        self._viewModel = StateObject(wrappedValue: FriendActivityBackend.shared)
    }
    var body: some View {
        ZStack {
            VStack {
                if (!viewModel.errorMessage.isEmpty) {
                    TempNotification(notificationText: $viewModel.errorMessage)
                        .frame(maxHeight: .infinity, alignment: .top)
                }
                if (!viewModel.internetFetchWarning.isEmpty) {
                    TempNotification(notificationText: $viewModel.internetFetchWarning)
                        .frame(maxHeight: .infinity, alignment: .top)
                        
                }
            }
            .zIndex(1)
            TabView (selection: $viewModel.tabSelection){
                NavigationView{
                    FriendRowList()
                        .task {
                            await viewModel.GetFriends()
                        }
                        .navigationBarTitle("Friend Activity")
                }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .tabItem{
                        Label("Friend Activity", systemImage: "person.3")
                    }
                    .tag(1)
                SettingsPage()
                    .tabItem{
                        Label("Settings", systemImage: "gearshape.2")
                    }
                    .tag(2)
                LyricFeverPage()
                    .tabItem{
                        Label("Lyric Fever", systemImage: "music.note.list")
                    }
                    .tag(3)
            }
            .onChange(of: viewModel.tabSelection) { newValue in
                let impactMed = UIImpactFeedbackGenerator(style: .light)
                impactMed.impactOccurred()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .background {
                    print("BACKGROUND")
                    viewModel.updateWidget()
                }
            }
        }
        .sheet(isPresented: $viewModel.DisplayUpdateAlert) {
            welcomeToUpdateSheet()
        }
    }
            
}
