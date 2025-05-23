//
//  SettingsPage.swift
//  Friend Activity for Spotify
//
//  Created by Avi Wadhwa on 2022-06-13.
//

import SwiftUI
//import SwiftKeychainWrapper
struct SettingsPage: View {
    @State var showAcknowledgements : Bool  = false
    @State var showFavorite : Bool  = false
    @AppStorage("favoriteId", store: UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")!) var favoriteId : String?
    var body: some View {
        NavigationView() {
            ScrollView {
                VStack (spacing: 30){
                    Spacer()
                    VStack (spacing: 15) {
                        Image("Icon")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                        Text("Version 1.8")
                            .font(.custom("montserrat", size: 20))
                        Text("App made by Avi Wadhwa")
                            .font(.custom("montserrat", size: 15))
                            .foregroundColor(.gray)
                        Text("Icon design by Aadi Khurana")
                            .font(.custom("montserrat", size: 14))
                            .foregroundColor(.gray)
                    }
                    Button(action: {
                        showFavorite = true
                    }) {
                        VStack(spacing: 4) {
                            Label("Set Favourite", systemImage: "heart")
                                .font(.custom("montserrat",size: 20))
                                //.background(in: RoundedRectangle)
                            Text("(For small and lockscreen widgets)")
                                .font(.custom("montserrat", size: 15))
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300)
                        .background(Color(.heart))
                        .cornerRadius(10)
                    }
                    Button(action: {
                        let url = "https://apps.apple.com/app/id1636288237?action=write-review"
                        guard let writeReviewURL = URL(string: url)
                            else { fatalError("Expected a valid URL") }
                        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
                    }) {
                        VStack(spacing: 4) {
                            Label("Rate App", systemImage: "star")
                                .font(.custom("montserrat",size: 20))
                                //.background(in: RoundedRectangle)
                            Text("(Opens App Store)")
                                .font(.custom("montserrat", size: 15))
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                    }
                    Button(action: {
                        print("LOGGED OUT CUZ OF BUTTON")
                        print(" LOGGED OUT AFTER ALL")
                        FriendActivityBackend.shared.logout()
//                        FriendActivityBackend.shared.keychain["spDcCookie"] = nil
//                        FriendActivityBackend.shared.keychain["accessToken"] = nil
//                        FriendActivityBackend.shared.loggedOut = true
                    }) {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.custom("montserrat",size: 20))
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 300)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                            //.background(in: RoundedRectangle)
                    }
                    Button(action: {
                        showAcknowledgements = true
                    }) {
                        Label("Acknowledgements", systemImage: "person.3.fill")
                            .font(.custom("montserrat",size: 20))
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 300)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                            //.background(in: RoundedRectangle)
                    }
                }
            }
            .navigationBarTitle("Settings")
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showFavorite) {
            NavigationView() {
                VStack{
                    Text("Pick A Favourite Friend!")
                        .bold()
                        .padding(.vertical, 5)
                    List(FriendActivityBackend.shared.friendArray ?? [], selection: $favoriteId) { friend in
                        HStack {
                            if favoriteId == friend.id {
                                Image(systemName: "checkmark.circle")
                            }
                            SelectionFriendRow(friend: friend)
                        }
                    }
                    .animation(.snappy, value: favoriteId)
                }
                .font(.custom("montserrat", size: 16))
                    .toolbar {
                        Button {
                            showFavorite = false
                        } label: {
                            Text("Close")
                                .bold()
                        }
                    }
            }
        }
        .sheet(isPresented: $showAcknowledgements) {
            NavigationView() {
                VStack (spacing: 15){
                    Text("Special Thanks:")
                        .bold()
                    Text("Icon design by Aadi Khurana")
                    Text("Spanish translation by Anel")
                    Text("Other Acknowledgements:")
                        .bold()
                    Text("Montserrat font by [@JulietaUla](https://github.com/JulietaUla)")
                    Text("SDWebImageSwiftUI by [@SDWebImage](https://github.com/SDWebImage)")
                    Text("SwiftUI-Shimmer by [@markiv](https://github.com/markiv)")
                    Text("spotify-buddylist by [@valeriangalliat](https://github.com/valeriangalliat)")
                }
                .font(.custom("montserrat", size: 16))
                    .toolbar {
                        Button {
                            showAcknowledgements = false
                        } label: {
                            Text("Close")
                                .bold()
                        }
                    }
            }
        }
    }
}
