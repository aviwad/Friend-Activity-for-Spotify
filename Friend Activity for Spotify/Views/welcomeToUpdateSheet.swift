//
//  welcomeToUpdateSheet.swift
//  Friend Activity for Spotify
//
//  Created by Avi Wadhwa on 2025-02-08.
//

import SwiftUI

struct welcomeToUpdateSheet: View{
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 13) {
//                    HStack {
//                        Spacer()
//                        Text("Welcome to update 1.7")
//                            .font(.custom("montserrat", size: 23))
//                        Spacer()
//                    }
                HStack {
                    Text("Version 1.8")
                        .bold()
                    Spacer()
                    Button(action: {dismiss()}, label: {
                        Image(systemName: "xmark")
                    })
                    .font(Font.title.weight(.bold))
                }
                .font(.custom("montserrat", size: 25))
                .padding(.top, 30)
                
                Text("I've fixed the 2 week old \"Data Could Not Be Read\" bug.")
                    .bold()
                    .font(.custom("montserrat", size: 20))
                
                Text("If nothing's loading: please log out and log back in again")
//                    .padding(.top, 20)
                    .font(.custom("montserrat", size: 20))
                
                Divider()
                Text("Spotify changed their login system to break third party apps, including mine :(")
                    .font(.custom("montserrat", size: 18))
                    .padding(.top, 10)
                Text("Truth be told, it's a cat and mouse chase between me and Spotify...")
                    .font(.custom("montserrat", size: 18))
                    .padding(.top, 10)
                
                HStack {
                    Spacer()
                    Image(.tomJerry)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 220)
                        .cornerRadius(15)
                    Spacer()
                }
            
                Text("Thanks for using my app!")
                    .padding(.top, 20)
                    .font(.custom("montserrat", size: 23))
                
                HStack(spacing: 0) {
                    Spacer()
                    Text("- avi")
                        .font(.custom("montserrat", size: 23))
                }
                Text("PS: Give the Lyric Fever page a look 👀")
                    .padding(.top, 20)
                    .font(.custom("montserrat", size: 18))
                
//                .padding(.horizontal)
//                    .frame(alignment: .trailing)
                

            }
            .multilineTextAlignment(.leading)
                .padding(.horizontal)
//                    .navigationTitle("Welcome to update 1.7")
//                    .navigationBarTitleDisplayMode(.inline)
//                    .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                            .bold()
                    }
                }
        }
        .interactiveDismissDisabled()
    }
}
