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
        if (!notificationText.isEmpty) {
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
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            notificationText = ""
                        }
                    }, label: {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                            .padding(.trailing, 16)
                            .buttonStyle(.bordered)
                        
                    })
                }
            }
            .padding(.horizontal, 20)
            .transition(.move(edge: .top))
        }
    }
}
