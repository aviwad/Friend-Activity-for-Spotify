//
//  LargeView.swift
//  macWidgetExtension
//
//  Created by Avi Wadhwa on 2022-04-25.
//
import WidgetKit
import SwiftUI

struct MediumView: View {
    var entry: SimpleEntry
    @Environment(\.displayScale) var displayScale
    
    var body: some View {
        if #available(iOSApplicationExtension 17.0, *) {
            VStack (spacing: 0){
                VStack (spacing: 0) {
                    HStack() {
                        Image(systemName: "person.3")
                            .foregroundColor(Color("WhiteColor"))
                            .font(.system(size: 12))
                        Text("Friend Activity for Spotify")
                            .font(.bold(.system(size: 12))())
                            .foregroundColor(Color("WhiteColor"))
                        Spacer()
                    }
                    .padding(.vertical, 7)
                    .padding(.horizontal, 20)
                    .background(Color("HeaderColor"))
                    .clipped()
                }
                .frame(maxWidth: .infinity, // Full Screen Width
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
                else {
                    ForEach(Array(entry.friends.0.prefix(2).enumerated()), id: \.element.id) { index, friend in  //0..<entry.friends.0.count){ friend in
                        MediumViewRow(friend: friend, image: entry.friends.1[index])
                            .foregroundColor(Color("WhiteColor"))
                            .frame(maxHeight: .infinity)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .environment(\.sizeCategory, .large)
            .containerBackground(for: .widget) {
                Color("WidgetBackground")
            }
        } else {
            ZStack {
                Color("WidgetBackground")
                VStack (spacing: 0){
                    VStack (spacing: 0) {
                        HStack() {
                            Image(systemName: "person.3")
                                .foregroundColor(Color("WhiteColor"))
                                .font(.system(size: 12))
                            Text("Friend Activity for Spotify")
                                .font(.bold(.system(size: 12))())
                                .foregroundColor(Color("WhiteColor"))
                            Spacer()
                        }
                        .padding(.vertical, 7)
                        .padding(.horizontal, 20)
                        .background(Color("HeaderColor"))
                        .clipped()
                    }
                    .frame(maxWidth: .infinity, // Full Screen Width
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
                    if (entry.friends.0.count > 1) {
                        ForEach(0..<2, id: \.self){ friend in
                            MediumViewRow(friend: entry.friends.0[friend], image: entry.friends.1[friend])
                                .foregroundColor(Color("WhiteColor"))
                                .frame(maxHeight: .infinity)
                        }
                        .padding(.horizontal, 16)
                    }
                    else {
                        ForEach(0..<entry.friends.0.count, id: \.self){ friend in
                            MediumViewRow(friend: entry.friends.0[friend], image: entry.friends.1[friend])
                                .foregroundColor(Color("WhiteColor"))
                                .frame(maxHeight: .infinity)
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .environment(\.sizeCategory, .large)
        }
    }
}
