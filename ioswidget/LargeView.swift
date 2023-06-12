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
        
        if #available(iOSApplicationExtension 17.0, *) {
            VStack (spacing: 0){
                VStack (spacing: 0) {
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
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color("HeaderColor"))
                    //.clipped()
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
                ForEach(0..<entry.friends.0.count, id: \.self){ friend in
                    LargeViewRow(friend: entry.friends.0[friend], image: entry.friends.1[friend])
                        .foregroundColor(Color("WhiteColor"))
                        .frame(maxHeight: .infinity)
                }
                .padding(.horizontal, 16)
            }
            .environment(\.sizeCategory, .large)
                .containerBackground(for: .widget) {
                    Color("WidgetBackground")
                }
        } else {
            // Fallback on earlier versions
            ZStack {
                Color("WidgetBackground")
                VStack (spacing: 0){
                    VStack (spacing: 0) {
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
                        //TODO.padding(.top, 5)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color("HeaderColor"))
                        .clipped()
                        //Divider()
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
                    ForEach(0..<entry.friends.0.count, id: \.self){ friend in
                        LargeViewRow(friend: entry.friends.0[friend], image: entry.friends.1[friend])
                            .foregroundColor(Color("WhiteColor"))
                            .frame(maxHeight: .infinity)
                    }
                    .padding(.horizontal, 16)
                }
            }

            .environment(\.sizeCategory, .large)
        }
    }
}
