//
//  SettingsPage.swift
//  Friend Activity for Spotify
//
//  Created by Avi Wadhwa on 2022-06-13.
//

import SwiftUI
//import SwiftKeychainWrapper
struct SettingsPage: View {
    var body: some View {
        NavigationView() {
            VStack (spacing: 30){
                Image("Icon")
                    .font(.system(size: 40))
                    .cornerRadius(10)
                Text("Version 1.0")
                    .font(.custom("montserrat", size: 20))
                Button(action: {
                    print("LOGGED OUT CUZ OF BUTTON")
                    FriendActivityBackend.shared.keychain["spDcCookie"] = nil
                    FriendActivityBackend.shared.keychain["accessToken"] = nil
                    FriendActivityBackend.shared.loggedOut = true
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
            }
            .navigationBarTitle("Settings")
        }
        .navigationViewStyle(.stack)
    }
}

struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPage()
    }
}
