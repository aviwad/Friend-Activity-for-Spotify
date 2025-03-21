//
//  LyricFeverPage.swift
//  Friend Activity for Spotify
//
//  Created by Avi Wadhwa on 2025-03-20.
//

import SwiftUI
import ACarousel

struct Item: Identifiable {
    let id = UUID()
    let image: Image
}
let roles = [ "brat", "ditto","YukikaFull2","sumin","YukikaFull", "YukikaKaraoke"]//, "Chopper", "Robin", "Franky", "Brook"]
struct LyricFeverPage: View {
    let items: [Item] = roles.map { Item(image: Image($0)) }
    var body: some View {
        NavigationView() {
            ScrollView {
                VStack {
                    Text("Here's another app I've been working on that you might like!")
                        .font(.custom("montserrat", size: 18))
                        .padding(.horizontal, 10)
                        .foregroundColor(.gray)
    //                 Carousel view
                    ACarousel(items, spacing: 20, sidesScaling: 1, autoScroll: .active(2.5)) { item in
                                item.image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 220)
                                    .cornerRadius(10)
                            }
                            .frame(height: 250)
                    Image(.lyricFeverIcon)
                        .resizable()
                        .frame(width: 150, height: 150)
                        .cornerRadius(10)
                    Text("Lyric Fever: for macOS")
                        .font(.custom("montserrat", size: 25))
//                        .padding(.horizontal, 10)
                    Text("Menubar, Karaoke, Fullscreen lyrics, with translations!")
                        .font(.custom("montserrat", size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    Text("For Spotify & Apple Music")
                        .font(.custom("montserrat", size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    Text("**https://lyricfever.com**")
                        .font(.custom("montserrat", size: 18))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                }
            }
            .navigationBarTitle("Lyric Fever")
        }
    }
}

