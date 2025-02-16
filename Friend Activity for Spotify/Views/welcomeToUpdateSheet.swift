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
                    Text("Version 1.7")
                        .bold()
                    Spacer()
                    Button(action: {dismiss()}, label: {
                        Image(systemName: "xmark")
                    })
                    .font(Font.title.weight(.bold))
                }
                .font(.custom("montserrat", size: 25))
                .padding(.top, 30)
                
                Text("I've fixed the 2 year old bug that kept logging you out :)")
                    .bold()
                    .font(.custom("montserrat", size: 20))
                
                Divider()
                
                Text("You can now pin a **favorite friend to the lockscreen**...")
                    .font(.custom("montserrat", size: 18))
                    .padding(.top, 10)
                
                HStack {
                    Spacer()
                    Image(.lockscreenWidget)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 220)
                        .cornerRadius(15)
                    Spacer()
                }
                
                
                Text("... and onto a new **small widget!**")
                    .font(.custom("montserrat", size: 18))
                    .padding(.top, 10)
                HStack {
                    Spacer()
                    Image(.smallWidget)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180)
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
