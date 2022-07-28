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
            VStack (spacing: 20){
                Spacer()
                VStack (spacing: 15) {
                    //Image("Icon")
                    Image("Icon")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .foregroundColor(.green)
                        .font(.system(size: 40))
                        .cornerRadius(10)
                }
                .padding(.bottom,50)
                //Image("Icon")
                  //  .cornerRadius(10)
                    //.padding(.bottom,50)
                Text("Welcome to Friends (for Spotify™)")
                    .font(.custom("montserrat", size: 27))
                    //.font(.system(size: 30))
                    .multilineTextAlignment(.center)
                Spacer()
                //Button{
                //FriendActivityBackend.shared.loggedOut = false
                //}
                //label: {
                NavigationLink(destination: GoogleViewLogin()) {
                        Text("Log in to Spotify")
                            .font(.custom("montserrat",size: 20))
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                    }
                Button(action: {
                    FriendActivityBackend.shared.debugLog.append("logged, opening debug log\n")
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
                //}
                Spacer()
                VStack {
                    Text("App made by Avi Wadhwa")
                        .font(.custom("montserrat", size: 16))
                    Text("https://www.github.com/aviwad")
                        .font(.custom("montserrat", size: 16))
                    Text("Logo design by Aadi Khurana")
                        .font(.custom("montserrat", size: 15))
                }
                .padding(.vertical)
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
