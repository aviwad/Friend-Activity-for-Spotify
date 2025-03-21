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
           // .border(.blue)
            //.frame(alignment: .topLeading)
            if (entry.friends.0.isEmpty) {
                VStack (spacing: 10) {
                    Image(systemName: "person.fill.xmark")
                        .font(.system(size: 40))
                        .foregroundColor(Color("WhiteColor"))
                    VStack {
                        Text("No friends available")
                            .font(.bold(.system(size: 15))())
                            .foregroundColor(Color("WhiteColor"))
                        Text("(i've updated! click to re-login maybe?)")
                            .font(.bold(.system(size: 15))())
                            .foregroundColor(Color("WhiteColor"))
                    }
                }
                    .frame(maxHeight: .infinity)
            }
            else  {
                ForEach(Array(entry.friends.0.prefix(4).enumerated()), id: \.element.id) { index, friend in
                    LargeViewRow(friend: friend, image: entry.friends.1[index])
                        .foregroundColor(Color("WhiteColor"))
                        .frame(maxHeight: .infinity)
                }
                .padding(.horizontal, 16)
            }
            //Spacer()
//            ForEach(0..<entry.friends.0.count, id: \.self){ friend in
//                LargeViewRow(friend: entry.friends.0[friend], image: entry.friends.1[friend])
//                    .foregroundColor(Color("WhiteColor"))
//                    .frame(maxHeight: .infinity)
//                   // .border(.red)
//                //Divider()
//                  //  .padding(0)
//            }
            //TODO.frame(alignment: .center)
//            .padding(.horizontal, 16)
            //LargeViewRow(friend: entry.friends[entry.friends.count])
            //.padding(.vertical,7)
            //Spacer()
            //Spacer()
        }
        .widgetBackground(backgroundView: Color("WidgetBackground"))    

        .environment(\.sizeCategory, .large)
        //Text(entry.friends[0].track.name)
    }
}
