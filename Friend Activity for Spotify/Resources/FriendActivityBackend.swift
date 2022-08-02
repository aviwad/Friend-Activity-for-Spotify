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
    //var currentlyRunning = false
    static let shared = FriendActivityBackend()
    let monitor = NWPathMonitor()
    var currentlyLoggingIn = false
    let keychain = Keychain(service: "aviwad.Friend-Activity-for-Spotify", accessGroup: "38TP6LZLJ5.sharing")
        .accessibility(.afterFirstUnlock)
    //var debugLog = ""
    //var currentError : String? = nil
    @Published var tabSelection = 1
    @Published var networkUp: Bool = true
    @Published var friendArray: [Friend]? = nil
    @Published var loggedOut: Bool = false
    @Published var currentError: String?
    var currentlyRunning = false
    //@Published var youHaveNoFriends: Bool = false
    init() {
        currentError = keychain["currentError"]
        monitor.start(queue: DispatchQueue.main)
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                switch path.status {
                    case .satisfied:
                    //self.debugLog.append("LOGGED SATISFIED\n")
                        print("LOGGED SATISFIED")
                    if (!self.currentlyRunning) {
                        withAnimation {
                            self.networkUp = true
                            Task {
                                //self.debugLog.append("LOGGED getfriendactivitycalled from .satisfied of network up\n")
                                print("LOGGED getfriendactivitycalled from .satisfied of network up")
                                await self.GetFriendActivity(animation: true)
                            }
                        }
                    }
                    else {
                        print("logged .satisfied canceled")
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
         let (data, _) = try await URLSession.shared.data(for: request)
        //self.debugLog.append("LOGGED \(data)\n")
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
                //self.debugLog.append("LOGGED dispatch queue is working\n")
                print("LOGGED dispatch queue is working")
                WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                    cookies.forEach { cookie in
                        //self.debugLog.append("logged checkingiflogged in cookie \(cookie.name) is \(cookie.value)")
                        if (cookie.name == "sp_dc") {
                            //self.debugLog.append("LOGGED sp_dc is \(cookie.value)\n")
                            print("LOGGED sp_dc is \(cookie.value)")
                            FriendActivityBackend.shared.keychain["spDcCookie"] = cookie.value
                            Task {
                                //self.debugLog.append("logged, getfriendactivity called from checkifloggedin\n")
                                print("logged, getfriendactivity called from checkifloggedin")
                                await FriendActivityBackend.shared.GetFriendActivity(animation: true)
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

//
//    func GetAccessToken() async {
//        do {
//            let spDcCookie = keychain["spDcCookie"]
//            if (spDcCookie != nil) {
//                let accessToken: accessTokenJSON =  try await fetch(urlString: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player", httpValue: "sp_dc=\(spDcCookie.unsafelyUnwrapped)", httpField: "Cookie")
//                keychain["accessToken"] = accessToken.accessToken
//            }
//        }
//        catch {
//            keychain["spDcCookie"] = nil
//            self.loggedOut = false
//            self.loggedOut = true
//            self.debugLog.append("LOGGED OUT IN ACCESS TOKEN\n")
//            print("LOGGED OUT IN ACCESS TOKEN")
//            keychain["accessToken"] = nil
//        }
//        //KeychainWrapper.standard.set(accessToken.accessToken, forKey: "accessToken", withAccessibility: .always)
//        //return accessToken.accessToken
//    }
    
//    func mailto() async{
//        let mailto = "mailto:aviwad@gmail.com?subject=I found a bug! for Friends (for Spotify) Version 1.0&body=My bug (INSERT BUG) \n\n\nDEBUG LOG (Dont delete this)\n\(FriendActivityBackend.shared.debugLog)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//        print("logged, mailto called \(mailto)")
//         if let url = URL(string: mailto!) {
//             print("logged, url \(url) called")
//             await UIApplication.shared.open(url)
//            // globalURLOpener(URL: url)
//         }
//    }
    
    func GetFriendActivity(animation: Bool) async {
        self.currentlyRunning = true
            let accessToken = try? keychain.get("accessToken")
            //let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
            if (accessToken != nil) {
                //self.debugLog.append("LOGGED ACCESS TOKEN FOUND\n")
                print("LOGGED ACCESS TOKEN FOUND")
                self.loggedOut = false
                let friendArrayInitial: Welcome
                do {
                    if (networkUp) {
                        //self.debugLog.append("LOGGED NETWORK UP, FRIENDARRAYINITIAL CALLED \n")
                        print("LOGGED NETWORK UP, FRIENDARRAYINTIAL CALLED")
                        friendArrayInitial = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken.unsafelyUnwrapped)", httpField: "Authorization")
                        //self.debugLog.append("testing123: friendarrayinitial \n")
                        print("testing123: friendarrayinitial")
                        self.currentError = nil
                        keychain["currentError"] = nil
                        //youHaveNoFriends = false
                        if (animation) {
                            withAnimation(){
                                friendArray = friendArrayInitial.friends.reversed()
                                WidgetCenter.shared.reloadAllTimelines()
                            }
                        }
                        else {
                            friendArray = friendArrayInitial.friends.reversed()
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                        //self.currentError = nil
                    }
                }
                catch {
                    //if (error as? URLError)?.code == .timedOut {
                    if(error is URLError) {
                        self.currentError = error.localizedDescription
                        keychain["currentError"] = error.localizedDescription
                        print("logged timed out!")
                        //FriendActivityBackend.shared.friendArray =
                        //FriendActivityBackend.shared.networkUp = false
                        // Handle session timeout
                    }
                    else {
                        //self.debugLog.append("LOGGED \(accessToken.unsafelyUnwrapped) \n LOGGED Error info: \(error) \n LOGGED OUT CUZ OF FRIENDARRAYINITIAL ERROR")
                        print("LOGGED \(accessToken.unsafelyUnwrapped)")
                        print("LOGGED Error info: \(error)")
                        print("LOGGED OUT CUZ OF FRIENDARRAYINITIAL ERROR")
                        if (networkUp) {
                            do {
                                let errorMessage: AccessTokenError
                                errorMessage = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken.unsafelyUnwrapped)", httpField: "Authorization")
                                //self.debugLog.append("logged, removing brokenaccesstoken from catching the errorjson \n")
                                print("logged, removing brokenaccesstoken from catching the errorjson")
                                keychain["accessToken"] = nil
                                //self.debugLog.append("logged, getfriendactivity called from catching the errorjson \n")
                                print("logged, getfriendactivity called from catching the errorjson")
                                await GetFriendActivity(animation: animation)
                                //self.debugLog.append("LOGGED \(errorMessage)")
                                print("LOGGED \(errorMessage)")
                                //self.keychain["accessToken"] = nil
                                //self.keychain["spDcCookie"] = nil
                                //loggedOut = true
                            }
                            catch {
                                self.currentError = error.localizedDescription
                                keychain["currentError"] = error.localizedDescription
                                // serious error
                                withAnimation() {
                                   // self.currentError = error.localizedDescription
                                }
                                //self.debugLog.append("LOGGED \(error.localizedDescription)\n")
                                print("LOGGED \(error.localizedDescription)")
                            }
                        }
                        // network is down
                    }
                }
            }
            else {
                //self.debugLog.append("LOGGED OUT ACCESSTOKEN IS NIL, running logged getaccesstoken due to else clause in getfriendactivity")
                print("LOGGED OUT ACCESSTOKEN IS NIL")
                print("logged running getaccesstoken due to else clause in getfriendactivity")
                let spDcCookie = keychain["spDcCookie"]
                if networkUp  {
                    do {
                        let spDcCookie = keychain["spDcCookie"]
                        print("logged: getaccesstoken: spdc cookie is \(keychain["spDcCookie"])")
                        if (spDcCookie != nil) {
                            //self.debugLog.append("logged: spdc is \(spDcCookie.unsafelyUnwrapped)")
                            //self.debugLog.append("logged: getting access token")
                            print("logged: getting access token")
                            let accessToken: accessTokenJSON =  try await fetch(urlString: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player", httpValue: "sp_dc=\(spDcCookie.unsafelyUnwrapped)", httpField: "Cookie")
                            keychain["accessToken"] = accessToken.accessToken
                            //self.debugLog.append("logged: access token is \(keychain["accessToken"])\n")
                            print("logged: access token is \(keychain["accessToken"])")
                            await GetFriendActivity(animation: animation)
                        }
                        else {
                            self.currentError = keychain["currentError"]
                            if (self.currentError == nil) {
                                keychain["currentError"] = "login token was missing."
                                self.currentError = "login token was missing."
                            }
                            // keychain current error will just say spdc is nil, so show previous REAL error
                            keychain["spDcCookie"] = nil
                            self.loggedOut = false
                            self.loggedOut = true
                            //self.debugLog.append("logged out in access token\n")
                            print("LOGGED OUT IN ACCESS TOKEN")
                            keychain["accessToken"] = nil
                            
                        }
                    }
                    catch {
                        print("error caused \(error)")
                        if (error is URLError) {
                            print("ok just a network error, ignore maro")
                            self.currentError = "just a network error for fetching the cookie"
                            keychain["currentError"] = self.currentError
                        }
                        else {
                            print("not url error")
                            if (networkUp) {
                                do {
                                    let errorMessage: SpDcError
                                    errorMessage =  try await fetch(urlString: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player", httpValue: "sp_dc=\(spDcCookie.unsafelyUnwrapped)", httpField: "Cookie")
                                    //print(String(decoding: errorMessageData, as: UTF8.self))
                                    self.debugLog.append("confirmed, spdccookie is broken")
                                    print("logged, removing broken spdc from catching the errorjson")
                                    keychain["spDcCookie"] = nil
                                    keychain["currentError"] = error.localizedDescription
                                    self.currentError = keychain["currentError"]
                                    self.loggedOut = false
                                    self.loggedOut = true
                                    self.debugLog.append("logged out with broken spdc\n")

                                    //self.keychain["accessToken"] = nil
                                    //self.keychain["spDcCookie"] = nil
                                    //loggedOut = true
                                }
                                catch {
                                    print("another error :( \(error)")
                                    self.currentError = error.localizedDescription
                                    keychain["currentError"] = error.localizedDescription
                                }
                            }
                        }
                    }
                }
            }
        //print("testing123: \(friendArray.unsafelyUnwrapped)")
        //return friendArrayInitial.friends.reversed()
        self.currentlyRunning = false
    }
}
