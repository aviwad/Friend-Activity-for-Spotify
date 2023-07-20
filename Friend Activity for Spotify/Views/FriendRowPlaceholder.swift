//
//  FriendRow.swift
//  SpotPlayerFriendActivitytest
//
//  Created by Avi Wadhwa on 2022-04-23.
//

import Foundation
import SwiftUI


struct FriendRowPlaceholder: View {
    var body: some View {
            HStack {
                ZStack {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text("demoUserhtatosetnoeasname")
                            .lineLimit(1)
                            .font(.headline)
                        Spacer()
                        Text("now")
                            .font(.subheadline)
                    }
                    HStack (spacing: 2){
                        Text("Glimahstoenahsieotnpse of us")
                            .lineLimit(1)
                            .font(.subheadline)
                        Image(systemName: "circle.fill")
                            .font(.system(size: 4))
                        Text("Jothasotaoeshji")
                            .lineLimit(1)
                            .font(.subheadline)
                    }
                    HStack (spacing: 5){
                        Image(systemName: "music.note")
                        Text("Top hashtoeasitonits")
                            .lineLimit(1)
                            .font(.subheadline)
                    }
                }
                Spacer()
            }
            .transition(.opacity)
            .foregroundColor(Color.white)
            .contentShape(Rectangle())
        }

}
