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
            VStack (spacing: 30){
                VStack (spacing: 15) {
                    Image("Icon")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .cornerRadius(10)
                    Text("Icon designed by Aadi Khurana")
                        .font(.custom("montserrat", size: 15))
                        .foregroundColor(.gray)
                }
                Text("Version 1.0")
                    .font(.custom("montserrat", size: 20))
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
        .sheet(isPresented: $showAcknowledgements) {
            NavigationView() {
                VStack (spacing: 15){
                    Text("Special Thanks:")
                        .bold()
                    Text("Icon design by my close friend Aadi Khurana")
                    Text("Other Acknowledgements:")
                        .bold()
                    Text("Montserrat font by @JulietaUla")
                    Text("KeychainAccess by @kishikawakatsumi")
                    Text("SwiftUI-Shimmer by @markiv")
                    Text("Nuke by @kean")
                    Text("spotify-buddylist by @valeriangalliat")
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

struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPage()
    }
}
