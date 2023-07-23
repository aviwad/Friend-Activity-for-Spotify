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
                        Text("Version 1.7")
                            .font(.custom("montserrat", size: 20))
                        Text("App made by Avi Wadhwa")
                            .font(.custom("montserrat", size: 15))
                            .foregroundColor(.gray)
                        Text("Icon design by Aadi Khurana")
                            .font(.custom("montserrat", size: 14))
                            .foregroundColor(.gray)
                    }
                    Button(action: {
                        let url = "https://apps.apple.com/app/id1636288237?action=write-review"
                        guard let writeReviewURL = URL(string: url)
                            else { fatalError("Expected a valid URL") }
                        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
                    }){
                        VStack(spacing: 4) {
                            Label("Rate App", systemImage: "star")
                                .font(.custom("montserrat",size: 20))
                                //.background(in: RoundedRectangle)
                            Text("(Opens App Store)")
                                .font(.custom("montserrat", size: 15))
                        }
                    }
                    .buttonStyle(GreenButton())
                    Button(action: {
                        showAcknowledgements = true
                    }) {
                        Label("Acknowledgements", systemImage: "person.3.fill")
                    }
                    .buttonStyle(GreenButton())
                    Button(action: {
                        print("LOGGED OUT CUZ OF BUTTON")
                        print(" LOGGED OUT AFTER ALL")
                        FriendActivityBackend.shared.logout()
                    }) {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                    .buttonStyle(GreenButton())
                }
            }
            .navigationBarTitle("Settings")
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showAcknowledgements) {
            NavigationView() {
                VStack (spacing: 15){
                    Text("Special Thanks:")
                        .bold()
                    Text("Icon design by Aadi Khurana")
                    Text("Spanish translation by Anel")
                    Text("Other Acknowledgements:")
                        .bold()
                    Text("KeychainAccess by [@kishikawakatsumi](https://github.com/kishikawakatsumi)")
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
