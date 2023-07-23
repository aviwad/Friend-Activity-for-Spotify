//
//  ContentView.swift
//  Friend Activity for Spotify
//
//  Created by Avi Wadhwa on 2022-06-13.
//

import SwiftUI



struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var viewModel = FriendActivityBackend.shared
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "montserrat", size: 30)!]
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "montserrat", size: 20)!]
    }
    
    var body: some View {
        ZStack {
            TempNotification()
            .frame(maxHeight: .infinity, alignment: .top)
            .zIndex(1)
            TabView (selection: $viewModel.tabSelection) {
                NavigationView {
                    FriendRowList()
                    .navigationBarTitle("Friend Activity")
                    .toolbar {
                        if (viewModel.isLoading) {
                            ProgressView()
                        }
                    }
                }
                .navigationViewStyle(.stack)
                .tabItem{
                    Label("Friend Activity", systemImage: "person.3")
                }
                .tag(1)
                SettingsPage()
                .tabItem{
                    Label("Settings", systemImage: "gearshape.2")
                }
                .tag(2)
            }
            .onChange(of: viewModel.tabSelection) { newValue in
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .background {
                    print("BACKGROUND")
                    viewModel.updateWidget()
                }
            }
        }
        .environmentObject(viewModel)
    }
            
}
