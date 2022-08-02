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
                        Text("Version 1.2 DEBUG/TestFlight")
                            .font(.custom("montserrat", size: 20))
                        Text("App made by Avi Wadhwa")
                            .font(.custom("montserrat", size: 15))
                            .foregroundColor(.gray)
                        Text("Icon design by Aadi Khurana")
                            .font(.custom("montserrat", size: 14))
                            .foregroundColor(.gray)
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
                    Button(action: {
                        FriendActivityBackend.shared.debugLog.append("logged cuz of button")
                        print("LOGGED OUT CUZ OF BUTTON")
                        if (!FriendActivityBackend.shared.currentlyLoggingIn) {
                            FriendActivityBackend.shared.debugLog.append("button log confirmed")
                            print(" LOGGED OUT AFTER ALL")
                            FriendActivityBackend.shared.keychain["spDcCookie"] = nil
                            FriendActivityBackend.shared.keychain["accessToken"] = nil
                            FriendActivityBackend.shared.loggedOut = true
                            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(2))) {
                                FriendActivityBackend.shared.tabSelection = 1
                            }
                        }
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
                        print("logged, opening debug log")
                        Task {
                            await FriendActivityBackend.shared.mailto()
                        }
                    }) {
                        Label("I found a bug", systemImage: "ladybug")
                            .font(.custom("montserrat",size: 15))
                            .foregroundColor(.white)
                            .padding(10)
                            .frame(width: 150)
                            .background(.red)
                            .cornerRadius(10)
                            //.background(in: RoundedRectangle)
                    }
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
                    Text("KeychainAccess by [@kishikawakatsumi](https://github.com/kishikawakatsumi)")
                    Text("Montserrat font by [@JulietaUla](https://github.com/JulietaUla)")
                    Text("Nuke by [@kean](https://github.com/kean)")
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

struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPage()
    }
}
