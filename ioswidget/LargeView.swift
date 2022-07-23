//
//  LargeView.swift
//  macWidgetExtension
//
//  Created by Avi Wadhwa on 2022-04-25.
//
import WidgetKit
import SwiftUI

struct LargeView: View {
    var entry: SimpleEntry
    @Environment(\.displayScale) var displayScale
    
    var body: some View {
        ZStack {
            Color("WidgetBackground")
            VStack (spacing: 0){
                HStack() {
                    Image(systemName: "person.3")
                        .foregroundColor(Color("WhiteColor"))
                        .font(.system(size: 15))
                    Text("Friend Activity for Spotify")
                        //.minimumScaleFactor(0.8)
                        .font(.bold(.system(size: 15))())
                        .foregroundColor(Color("WhiteColor"))
                        //.fontWeight(.bold)
                    Spacer()
                }
                .padding(.top, 5)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color("HeaderColor"))
                .clipped()
                Divider()
                if (entry.friends.0.isEmpty) {
                    Spacer()
                    Spacer()
                    Text("No friends available")
                        .font(.bold(.system(size: 20))())
                        .foregroundColor(Color("WhiteColor"))
                }
                Text("DEBUG: \(entry.friends.2 ?? "No error")")
                    .font(.bold(.system(size: 15))())
                    .foregroundColor(Color("WhiteColor"))
                Spacer()
                ForEach(0..<entry.friends.0.count, id: \.self){ friend in
                    LargeViewRow(friend: entry.friends.0[friend], image: entry.friends.1[friend])
                        .foregroundColor(Color("WhiteColor"))
                    //Divider()
                      //  .padding(0)
                }
                .frame(alignment: .center)
                .padding(.horizontal, 20)
                //LargeViewRow(friend: entry.friends[entry.friends.count])
                .padding(.vertical,7)
                //Spacer()
                //Spacer()
            }
            //.padding(.horizontal,20)
        }

        .environment(\.sizeCategory, .large)
        //Text(entry.friends[0].track.name)
    }
}
