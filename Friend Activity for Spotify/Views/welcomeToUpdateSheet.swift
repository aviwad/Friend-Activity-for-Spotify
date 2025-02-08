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
        NavigationView {
            VStack {
                Text("Welcome to update 1.7. I've fixed the 2 year old bug that kept logging you out. Thanks for using my app!")
                    .font(.custom("montserrat", size: 23))
                HStack {
                    Spacer()
                    Text("- avi")
                        .font(.custom("montserrat", size: 26))
                }
                .padding(.horizontal)
//                    .frame(alignment: .trailing)
                

            }
                .padding(.horizontal)
                .toolbar {
                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                            .bold()
                    }
                }
        }
    }
}
