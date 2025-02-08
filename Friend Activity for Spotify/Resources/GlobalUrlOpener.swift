//
//  File.swift
//  SpotPlayerFriendActivitytest
//
//  Created by Avi Wadhwa on 2022-04-23.
//

import Foundation
import SwiftUI

func globalURLOpener(URL: URL) -> Void{
    #if os(iOS)
    UIApplication.shared.open(URL)
    #endif
    #if os(macOS)
    NSWorkspace.shared.open(URL)
    #endif
}
