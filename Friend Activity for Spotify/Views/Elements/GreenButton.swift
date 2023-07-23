//
//  GreenButton.swift
//  Friend Activity for Spotify
//
//  Created by Avi Wadhwa on 24/07/23.
//

import SwiftUI

struct GreenButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("montserrat",size: 20))
      //      .font(.bold(.custom("montserrat", size: 20)))
            .foregroundColor(.white)
            .padding()
            .frame(width: 300)
            .background(Color.accentColor)
            .cornerRadius(10)
    }
}
