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
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        VStack (spacing: 0){
            VStack (spacing: 0) {
                HStack() {
                    Image(systemName: "person.3")
                        .foregroundColor(Color("WhiteColor"))
                        .font(.system(size: 15))
                    Text(entry.friends.2 ? "Best Friends on Spotify" : "Friend Activity for Spotify")
                        .font(.bold(.system(size: 15))())
                        .foregroundColor(Color("WhiteColor"))
                    Spacer()
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color("HeaderColor"))
            }
            .frame(maxWidth: .infinity, // Full Screen Width
                        //maxHeight: .infinity, // Full Screen Height
                        alignment: .topLeading) // Align To top
            if (entry.friends.0.isEmpty) {
                VStack (spacing: 10) {
                    Image(systemName: "person.fill.xmark")
                        .font(.system(size: 40))
                        .foregroundColor(Color("WhiteColor"))
                    Text("No friends available")
                        .font(.bold(.system(size: 20))())
                        .foregroundColor(Color("WhiteColor"))
                }
                    .frame(maxHeight: .infinity)
            }
            ForEach(Array(entry.friends.0.enumerated()), id: \.element.id) { index, friend in
                LargeViewRow(friend: friend, image: entry.friends.1[index])
                    .foregroundColor(Color("WhiteColor"))
                    .frame(maxHeight: .infinity)
            }
            .padding(.horizontal, 16)
        }
        .environment(\.sizeCategory, .large)
        .widgetBackground(backgroundView: Color("WidgetBackground"))
    }
}
