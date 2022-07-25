//
//  loginSheet.swift
//  Friend Activity for Spotify
//
//  Created by Avi Wadhwa on 2022-06-16.
//

import SwiftUI


struct loginSheet: View {
    var body: some View {
        NavigationView(){
            VStack {
                Spacer()
                Image("Icon")
                    .cornerRadius(10)
                    .padding(.bottom,50)
                Text("Welcome to Friends (for Spotify™)")
                    .font(.custom("montserrat", size: 27))
                    //.font(.system(size: 30))
                    .multilineTextAlignment(.center)
                Spacer()
                //Button{
                //FriendActivityBackend.shared.loggedOut = false
                //}
                //label: {
                NavigationLink(destination: WebviewLogin()) {
                        Text("Log in using Spotify")
                            .font(.custom("montserrat",size: 20))
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                    }
                //}
                Spacer()
                Group {
                    Text("Made by Avi Wadhwa")
                    Text("https://www.github.com/aviwad")
                }
            }
            //.navigationTitle("Login to Friend Activity for Spotify")
            //.navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct loginSheet_Previews: PreviewProvider {
    static var previews: some View {
        loginSheet()
    }
}
