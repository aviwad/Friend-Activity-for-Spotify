//
//  TempNotification.swift
//  Friend Activity for Spotify
//
//  Created by Avi Wadhwa on 28/05/23.
//

import SwiftUI

struct TempNotification: View {
    @Binding var notificationText: String
    var body: some View {
        ZStack {
            Color.red
                .frame(height: 60)
                .cornerRadius(20)
            
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
                    .padding(.leading, 16)
                
                Text(notificationText)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .font(.system(size: 16, weight: .medium))
                    .disabled(true)
                
                Spacer()
            }
        }
        .padding(.horizontal, 20)
    }
}
