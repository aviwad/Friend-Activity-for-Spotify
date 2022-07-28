//
//  loginSheet.swift
//  Friend Activity for Spotify
//
//  Created by Avi Wadhwa on 2022-06-16.
//

import SwiftUI


struct googleOrOther: View {
    var body: some View {
        VStack (spacing: 20){
            Spacer()
            if(ProcessInfo().isiOSAppOnMac) {
                NavigationLink(destination: AppleViewLogin()) {
                        Text("Continue with Apple")
                            .font(.custom("montserrat",size: 20))
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                }
                NavigationLink(destination: GoogleViewLogin()) {
                        Text("Continue with Google")
                            .font(.custom("montserrat",size: 20))
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                }
                NavigationLink(destination: WebViewLoginForMac()) {
                        Text("Use Facebook / Email / Phone")
                            .font(.custom("montserrat",size: 20))
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                }
            }
            else {
                NavigationLink(destination: GoogleViewLogin()) {
                        Text("Continue with Google")
                            .font(.custom("montserrat",size: 20))
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                }
                NavigationLink(destination: WebviewLogin()) {
                        Text("Use Facebook / Apple / Email / Phone")
                            .font(.custom("montserrat",size: 20))
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                }
            }
            //}
            Spacer()
            VStack {
                Text("App made by Avi Wadhwa")
                    .font(.custom("montserrat", size: 16))
                Text("https://www.github.com/aviwad")
                    .font(.custom("montserrat", size: 16))
            }
            .padding(.vertical)
        }
            //.navigationTitle("Login to Friend Activity for Spotify")
            //.navigationBarTitleDisplayMode(.inline)
    }
}
