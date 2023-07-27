//
//  TempNotification.swift
//  Friend Activity for Spotify
//
//  Created by Avi Wadhwa on 28/05/23.
//

import SwiftUI

struct TempNotification: View {
    @EnvironmentObject var viewModel: FriendActivityBackend
    
    var body: some View {
        if let errorMessage = viewModel.errorMessage {
            ZStack {
                Color.red
                    .frame(height: 60)
                    .cornerRadius(20)
                
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                        .padding(.leading, 16)
                    
                    Text(errorMessage)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .font(.system(size: 16, weight: .medium))
                    
                    Spacer()
                    
                    #if DEBUG
                    Button(action: {
                        viewModel.showDebugAlert = true
                    }, label: {
                        Text("Details")
                            .foregroundColor(.white)
                        
                    })
                    #endif
                    Button(action: {
                        withAnimation {
                            viewModel.errorMessage = nil
                            viewModel.tempNotificationSwipeOffset = CGSize.zero
                        }
                    }, label: {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                            .padding(.trailing, 16)
                        
                    })
                }
            }
            .padding(.horizontal, 20)
            .transition(.move(edge: .top))
            .offset(y: viewModel.tempNotificationSwipeOffset.height)
            .gesture(
                DragGesture(coordinateSpace: .local)
                    .onChanged { gesture in
                        viewModel.tempNotificationSwipeOffset.height = min(0, gesture.translation.height)
                    }
                    .onEnded { _ in
                        if viewModel.tempNotificationSwipeOffset.height < -50 {
                            // remove the notification
                            viewModel.errorMessage = nil
                        }
                        viewModel.tempNotificationSwipeOffset = CGSize.zero
                    }
            )
        }
    }
}
