//
//  FriendRow.swift
//  SpotPlayerFriendActivitytest
//
//  Created by Avi Wadhwa on 2022-04-23.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

// struct FriendRowMenuStyle: ButtonStyle {

//  func makeBody(configuration: Self.Configuration) -> some View {
//    configuration.label
//      .padding()
//      .foregroundColor(.white)
//      .background(configuration.isPressed ? Color.green : Color.accentColor)
//      .cornerRadius(8.0)
//  }
//
//}
//


struct SelectionFriendRow: View {
    var friend: Friend
    var body: some View {
        HStack {
            ZStack {
                if (friend.user.imageURL == nil) {
                    Image(systemName: "person.fill")
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else{
                    WebImage(url: friend.user.imageURL) //{
                        .placeholder(Image(systemName: "person").resizable())
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50, alignment: .center)
                        .clipShape(Circle())
                        
                }
                
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(friend.user.name)
                        .lineLimit(1)
                        .font(.bold(.custom("montserrat", size: 15))())
                }
            }
            Spacer()
        }
        .padding(.horizontal)
        .transition(.opacity)
        .foregroundColor(Color.white)
        .contentShape(Rectangle())
}
}
