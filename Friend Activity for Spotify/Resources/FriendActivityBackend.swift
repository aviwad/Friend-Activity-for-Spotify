//
//  GetFriendActivityBackend.swift
//  SpotPlayerFriendActivitytest
//
//  Created by Avi Wadhwa on 2022-04-23.
//

import Foundation
import Network
import SwiftUI
import WidgetKit
import KeychainAccess
import WebKit
//import SwiftKeychainWrapper

@MainActor final class FriendActivityBackend: ObservableObject{
    var currentlyRunning = false
    static let shared = FriendActivityBackend()
    let monitor = NWPathMonitor()
    var currentlyLoggingIn = false
    let keychain = Keychain(service: "aviwad.Friend-Activity-for-Spotify", accessGroup: "38TP6LZLJ5.sharing")
        .accessibility(.afterFirstUnlock)
    var debugLog = ""
    @Published var tabSelection = 1
    @Published var showDebug = false
    @Published var networkUp: Bool = true
    @Published var friendArray: [Friend]? = nil
    @Published var loggedOut: Bool = false
    //@Published var youHaveNoFriends: Bool = false
    init() {
        monitor.start(queue: DispatchQueue.main)
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                switch path.status {
                    case .satisfied:
                    self.debugLog.append("LOGGED SATISFIED\n")
                        print("LOGGED SATISFIED")
                        withAnimation {
                            self.networkUp = true
                            Task {
                                self.debugLog.append("LOGGED getfriendactivitycalled from .satisfied of network up\n")
                                print("LOGGED getfriendactivitycalled from .satisfied of network up")
                                await self.GetFriendActivity()
                            }
                        }
                    default:
                        withAnimation {self.networkUp = false}
                }
            }
            /*if (path.status == .satisfied) {
                Task {
                    try await self.GetFriendActivity()
                }
                self.networkUp = true
            }
            else {
                self.networkUp = false
            }*/
        }
    }
    func fetch<T: Decodable>(urlString: String, httpValue: String, httpField: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(httpValue, forHTTPHeaderField: httpField)
        // URLSession.shared.configuration = 
         let (data, _) = try await URLSession.shared.data(for: request)
        self.debugLog.append("LOGGED \(data)\n")
        print("LOGGED \(data)")
        let json = try JSONDecoder().decode(T.self, from: data)
        return json
    }
    
    func checkIfLoggedIn() {
        if (!FriendActivityBackend.shared.currentlyLoggingIn) {
            FriendActivityBackend.shared.currentlyLoggingIn = true
            FriendActivityBackend.shared.tabSelection = 1
            FriendActivityBackend.shared.loggedOut = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.debugLog.append("LOGGED dispatch queue is working\n")
                print("LOGGED dispatch queue is working")
                WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                    cookies.forEach { cookie in
                        if (cookie.name == "sp_dc") {
                            self.debugLog.append("LOGGED sp_dc is \(cookie.value)\n")
                            print("LOGGED sp_dc is \(cookie.value)")
                            FriendActivityBackend.shared.keychain["spDcCookie"] = cookie.value
                            Task {
                                self.debugLog.append("logged, getfriendactivity called from checkifloggedin\n")
                                print("logged, getfriendactivity called from checkifloggedin")
                                await FriendActivityBackend.shared.GetFriendActivity()
                            }
                        }
                    }
                }
                //print(cookies)
                //let newCookies = HTTPCookieStorage.shared.cookies
                //newCookies!.forEach { cookie in
                  //  print(cookie.name)
                //}
                FriendActivityBackend.shared.currentlyLoggingIn = false
            }
        }
    }

    
    func GetAccessToken() async {
        do {
            let spDcCookie = keychain["spDcCookie"]
            if (spDcCookie != nil) {
                let accessToken: accessTokenJSON =  try await fetch(urlString: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player", httpValue: "sp_dc=\(spDcCookie.unsafelyUnwrapped)", httpField: "Cookie")
                keychain["accessToken"] = accessToken.accessToken
            }
        }
        catch {
            keychain["spDcCookie"] = nil
            self.loggedOut = false
            self.loggedOut = true
            self.debugLog.append("LOGGED OUT IN ACCESS TOKEN\n")
            print("LOGGED OUT IN ACCESS TOKEN")
            keychain["accessToken"] = nil
        }
        //KeychainWrapper.standard.set(accessToken.accessToken, forKey: "accessToken", withAccessibility: .always)
        //return accessToken.accessToken
    }
    
    func GetFriendActivity() async {
        if (!self.currentlyRunning) {
            self.currentlyRunning = true
            let accessToken = try? keychain.get("accessToken")
            //let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
            if (accessToken != nil) {
                self.debugLog.append("LOGGED ACCESS TOKEN FOUND\n")
                print("LOGGED ACCESS TOKEN FOUND")
                self.loggedOut = false
                let friendArrayInitial: Welcome
                do {
                    if (networkUp) {
                        self.debugLog.append("LOGGED NETWORK UP, FRIENDARRAYINITIAL CALLED \n")
                        print("LOGGED NETWORK UP, FRIENDARRAYINTIAL CALLED")
                        friendArrayInitial = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken.unsafelyUnwrapped)", httpField: "Authorization")
                        self.debugLog.append("testing123: friendarrayinitial \n")
                        print("testing123: friendarrayinitial")
                        //youHaveNoFriends = false
                        withAnimation(){
                            friendArray = friendArrayInitial.friends.reversed()
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                        self.currentlyRunning = false
                    }
                }
                catch {
                    self.debugLog.append("LOGGED \(accessToken.unsafelyUnwrapped) \n LOGGED Error info: \(error) \n LOGGED OUT CUZ OF FRIENDARRAYINITIAL ERROR")
                    print("LOGGED \(accessToken.unsafelyUnwrapped)")
                    print("LOGGED Error info: \(error)")
                    print("LOGGED OUT CUZ OF FRIENDARRAYINITIAL ERROR")
                    if (networkUp) {
                        do {
                            let errorMessage: WelcomeError
                            errorMessage = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken.unsafelyUnwrapped)", httpField: "Authorization")
                            self.debugLog.append("logged, removing brokenaccesstoken from catching the errorjson \n")
                            print("logged, removing brokenaccesstoken from catching the errorjson")
                            keychain["accessToken"] = nil
                            self.debugLog.append("logged, getfriendactivity called from catching the errorjson \n")
                            print("logged, getfriendactivity called from catching the errorjson")
                            await GetFriendActivity()
                            self.debugLog.append("LOGGED \(errorMessage)")
                            print("LOGGED \(errorMessage)")
                            //self.keychain["accessToken"] = nil
                            //self.keychain["spDcCookie"] = nil
                            //loggedOut = true
                        }
                        catch {
                            self.debugLog.append("LOGGED \(error.localizedDescription)\n")
                            print("LOGGED \(error.localizedDescription)")
                        }
                    }
                }
            }
            else {
                self.debugLog.append("LOGGED OUT ACCESSTOKEN IS NIL, running logged getaccesstoken due to else clause in getfriendactivity")
                print("LOGGED OUT ACCESSTOKEN IS NIL")
                print("logged running getaccesstoken due to else clause in getfriendactivity")
                do {
                    let spDcCookie = keychain["spDcCookie"]
                    print("logged: getaccesstoken: spdc cookie is \(keychain["spDcCookie"])")
                    if (spDcCookie != nil) {
                        self.debugLog.append("logged: getting access token")
                        print("logged: getting access token")
                        let accessToken: accessTokenJSON =  try await fetch(urlString: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player", httpValue: "sp_dc=\(spDcCookie.unsafelyUnwrapped)", httpField: "Cookie")
                        keychain["accessToken"] = accessToken.accessToken
                        self.debugLog.append("logged: access token is \(keychain["accessToken"])\n")
                        print("logged: access token is \(keychain["accessToken"])")
                        self.currentlyRunning = false
                        await GetFriendActivity()
                    }
                    else {
                        keychain["spDcCookie"] = nil
                        self.loggedOut = false
                        self.loggedOut = true
                        self.debugLog.append("logged out in access token\n")
                        print("LOGGED OUT IN ACCESS TOKEN")
                        keychain["accessToken"] = nil
                        self.currentlyRunning = false
                    }
                }
                catch {
                    keychain["spDcCookie"] = nil
                    self.loggedOut = false
                    self.loggedOut = true
                    self.debugLog.append("logged out in access token\n")
                    print("LOGGED OUT IN ACCESS TOKEN")
                    keychain["accessToken"] = nil
                    self.currentlyRunning = false
                }
            }
        }
        else {
            self.debugLog.append("logged, friendactivity declined due to current running process \n")
            print("logged, friendactivity declined due to current running process")
        }
        //print("testing123: \(friendArray.unsafelyUnwrapped)")
        //return friendArrayInitial.friends.reversed()
    }
    
    func GetFriendActivityNoAnimation() async {
        if (!self.currentlyRunning) {
            self.currentlyRunning = true
            let accessToken = try? keychain.get("accessToken")
            //let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
            if (accessToken != nil) {
                self.debugLog.append("LOGGED ACCESS TOKEN FOUND (no animation)\n")
                print("LOGGED ACCESS TOKEN FOUND (no animation)")
                self.loggedOut = false
                let friendArrayInitial: Welcome
                do {
                    if (networkUp) {
                        self.debugLog.append("LOGGED NETWORK UP, FRIENDARRAYINTIAL CALLED (no animation)\n")
                        print("LOGGED NETWORK UP, FRIENDARRAYINTIAL CALLED (no animation)")
                        friendArrayInitial = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken.unsafelyUnwrapped)", httpField: "Authorization")
                        //youHaveNoFriends = false
                        withAnimation(){
                            friendArray = friendArrayInitial.friends.reversed()
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                        self.currentlyRunning = false
                    }
                }
                catch {
                    self.debugLog.append("LOGGED \(accessToken.unsafelyUnwrapped) (no animation)\nLOGGED Error info: \(error) (no animation)\nLOGGED OUT CUZ OF FRIENDARRAYINITIAL ERROR (no animation)")
                    print("LOGGED \(accessToken.unsafelyUnwrapped) (no animation)")
                    print("LOGGED Error info: \(error) (no animation)")
                    print("LOGGED OUT CUZ OF FRIENDARRAYINITIAL ERROR (no animation)")
                    if (networkUp) {
                        do {
                            let errorMessage: WelcomeError
                            errorMessage = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken.unsafelyUnwrapped)", httpField: "Authorization")
                            self.debugLog.append("logged, removing brokenaccesstoken from catching the errorjson no animation\n")
                            print("logged, removing brokenaccesstoken from catching the errorjson no animation")
                            keychain["accessToken"] = nil
                            self.debugLog.append("logged, getfriendactivity called from catching the errorjson no animation\n")
                            print("logged, getfriendactivity called from catching the errorjson no animation")
                            await GetFriendActivity()
                            self.debugLog.append("LOGGED \(errorMessage)\n")
                            print("LOGGED \(errorMessage)")
                            //self.keychain["accessToken"] = nil
                            //self.keychain["spDcCookie"] = nil
                            //loggedOut = true
                        }
                        catch {
                            self.debugLog.append("LOGGED \(error.localizedDescription)\n")
                            print("LOGGED \(error.localizedDescription)")
                        }
                    }
                    self.currentlyRunning = false
                }
            }
            else {
                self.debugLog.append("LOGGED OUT ACCESSTOKEN IS NIL\nlogged running getaccesstoken due to else clause in getfriendactivity\n")
                print("LOGGED OUT ACCESSTOKEN IS NIL")
                print("logged running getaccesstoken due to else clause in getfriendactivity")
                do {
                    let spDcCookie = keychain["spDcCookie"]
                    self.debugLog.append("logged: getaccesstoken: spdc cookie is \(keychain["spDcCookie"])\n")
                    print("logged: getaccesstoken: spdc cookie is \(keychain["spDcCookie"])")
                    if (spDcCookie != nil) {
                        self.debugLog.append("logged: getting access token\n")
                        print("logged: getting access token")
                        let accessToken: accessTokenJSON =  try await fetch(urlString: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player", httpValue: "sp_dc=\(spDcCookie.unsafelyUnwrapped)", httpField: "Cookie")
                        keychain["accessToken"] = accessToken.accessToken
                        self.debugLog.append("logged: access token is \(keychain["accessToken"])\n")
                        print("logged: access token is \(keychain["accessToken"])")
                        self.currentlyRunning = false
                        await GetFriendActivity()
                    }
                    else {
                        keychain["spDcCookie"] = nil
                        self.loggedOut = false
                        self.loggedOut = true
                        self.debugLog.append("LOGGED OUT IN ACCESS TOKEN\n")
                        print("LOGGED OUT IN ACCESS TOKEN")
                        keychain["accessToken"] = nil
                        self.currentlyRunning = false
                    }
                }
                catch {
                    keychain["spDcCookie"] = nil
                    self.loggedOut = false
                    self.loggedOut = true
                    self.debugLog.append("LOGGED OUT IN ACCESS TOKEN\n")
                    print("LOGGED OUT IN ACCESS TOKEN")
                    keychain["accessToken"] = nil
                    self.currentlyRunning = false
                }
            }
        }
        else {
            self.debugLog.append("logged, friendactivity declined due to current running process\n")
            print("logged, friendactivity declined due to current running process")
        }
        //print("testing123: \(friendArray.unsafelyUnwrapped)")
        //return friendArrayInitial.friends.reversed()
    }
}
