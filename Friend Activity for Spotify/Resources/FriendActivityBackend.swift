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
import os

@MainActor final class FriendActivityBackend: ObservableObject{
    //var currentlyRunning = false
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FriendActivityBackend.self)
    )
    static let shared = FriendActivityBackend()
    let monitor = NWPathMonitor()
    let keychain = Keychain(service: "aviwad.Friend-Activity-for-Spotify", accessGroup: "38TP6LZLJ5.sharing")
        .accessibility(.afterFirstUnlock)
    //var debugLog = ""
    @Published var tabSelection = 1
    @Published var networkUp: Bool = true
    @Published var friendArray: [Friend]? = nil
    @Published var loggedOut: Bool = false
    //@Published var tappedRow: Int = 3
    //@Published var youHaveNoFriends: Bool = false
    init() {
        FriendActivityBackend.logger.debug(" friendactivitybackend initialized")
        monitor.start(queue: DispatchQueue.main)
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                switch path.status {
                    case .satisfied:
                    //self.debugLog.append("LOGGED SATISFIED\n")
                        FriendActivityBackend.logger.debug(" logged satisfied in initialization")
                        //Nprint("LOGGED SATISFIED")
                    if (!self.loggedOut) {
                        withAnimation {
                            self.networkUp = true
                            Task {
                                FriendActivityBackend.logger.debug(" LOGGED getfriendactivitycalled from .satisfied of network up")
                                //self.debugLog.append("LOGGED getfriendactivitycalled from .satisfied of network up\n")
                                //Nprint("LOGGED getfriendactivitycalled from .satisfied of network up")
                                await self.GetFriendActivity(animation: true)
                            }
                        }
                    }
                    else {
                        //FriendActivityBackend.logger.debug(" logged .satisfied canceled (currently running: \(self.currentlyRunning) and logged out: \(self.loggedOut)")
                        FriendActivityBackend.logger.debug(" logged .satisfied canceled (logged out: \(self.loggedOut)")

                        //Nprint("logged .satisfied canceled")
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
        FriendActivityBackend.logger.debug(" LOGGED \(data.debugDescription)")
        //Nprint("LOGGED \(data)")
        let json = try JSONDecoder().decode(T.self, from: data)
        return json
    }
    
    func fetchData(urlString: String, httpValue: String, httpField: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(httpValue, forHTTPHeaderField: httpField)
        // URLSession.shared.configuration =
         let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
    
    
    func checkIfLoggedIn() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //self.debugLog.append("LOGGED dispatch queue is working\n")
            FriendActivityBackend.logger.debug(" LOGGED dispatch queue is working (check if logged in function is running)")
            //Nprint("LOGGED dispatch queue is working")
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                cookies.forEach { cookie in
                    //self.debugLog.append("logged checkingiflogged in cookie \(cookie.name) is \(cookie.value)")
                    if (cookie.name == "sp_dc") {
                        //self.debugLog.append("LOGGED sp_dc is \(cookie.value)\n")
                        FriendActivityBackend.logger.debug(" sp_dc cookie was found! the value is \(cookie.value) and loggedout will be set to false")
                        //Nprint("LOGGED sp_dc is \(cookie.value)")
                        FriendActivityBackend.shared.keychain["spDcCookie"] = cookie.value
                        FriendActivityBackend.shared.tabSelection = 1
                        FriendActivityBackend.shared.loggedOut = false
                        Task {
                            //self.debugLog.append("logged, getfriendactivity called from checkifloggedin\n")
                            //Nprint("logged, getfriendactivity called from checkifloggedin")
                            FriendActivityBackend.logger.debug(" getfriendactivity called from checkifloggedin")
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
        FriendActivityBackend.logger.debug(" in getfriendactivity")
            let accessToken = try? keychain.get("accessToken")
            //let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
            if (accessToken != nil) {
                //self.debugLog.append("LOGGED ACCESS TOKEN FOUND\n")
                FriendActivityBackend.logger.debug(" access token found")
                //Nprint("LOGGED ACCESS TOKEN FOUND")
                self.loggedOut = false
                let friendArrayInitial: Welcome
                do {
                    if (networkUp) {
                        //self.debugLog.append("LOGGED NETWORK UP, FRIENDARRAYINITIAL CALLED \n")
                        FriendActivityBackend.logger.debug(" network is up in friendarrayinitial")
                        //Nprint("LOGGED NETWORK UP, FRIENDARRAYINTIAL CALLED")
                        friendArrayInitial = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken.unsafelyUnwrapped)", httpField: "Authorization")
                        //self.debugLog.append("testing123: friendarrayinitial \n")
                        FriendActivityBackend.logger.debug(" testing123: friendarrayinitial")
                        //Nprint("testing123: friendarrayinitial")
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
                        FriendActivityBackend.logger.debug(" logged timed out")
                        //Nprint("logged timed out!")
                        //FriendActivityBackend.shared.friendArray =
                        //FriendActivityBackend.shared.networkUp = false
                        // Handle session timeout
                    }
                    else {
                        
                        //self.debugLog.append("LOGGED \(accessToken.unsafelyUnwrapped) \n LOGGED Error info: \(error) \n LOGGED OUT CUZ OF FRIENDARRAYINITIAL ERROR")
                        //Nprint("LOGGED \(accessToken.unsafelyUnwrapped)")
                        //Nprint("LOGGED Error info: \(error)")
                        //Nprint("LOGGED OUT CUZ OF FRIENDARRAYINITIAL ERROR")
                        FriendActivityBackend.logger.debug(" the accesstoken is \(accessToken.unsafelyUnwrapped)")
                        FriendActivityBackend.logger.debug(" error info: \(error.localizedDescription)")
                        FriendActivityBackend.logger.debug(" logged out bc of friendarrayinitial error")
                        if (networkUp) {
                            do {
                                //self.debugLog.append("logged, removing brokenaccesstoken from catching the errorjson \n")
                                FriendActivityBackend.logger.debug(" removing broken accesstoken from catching the error json")
                                //Nprint("logged, removing brokenaccesstoken from catching the errorjson")
                                keychain["accessToken"] = nil
                                //self.debugLog.append("logged, getfriendactivity called from catching the errorjson \n")
                                FriendActivityBackend.logger.debug(" calling getfriendactivity from catching errorjson")
                                //Nprint("logged, getfriendactivity called from catching the errorjson")
                                await GetFriendActivity(animation: animation)
                                //self.debugLog.append("LOGGED \(errorMessage)")
                                //Nprint("LOGGED \(errorMessage)")
                                //self.keychain["accessToken"] = nil
                                //self.keychain["spDcCookie"] = nil
                                //loggedOut = true
                            }
                            catch {
                                // serious error
                                withAnimation() {
                                   // self.currentError = error.localizedDescription
                                }
                                //self.debugLog.append("LOGGED \(error.localizedDescription)\n")
                                //Nprint("LOGGED \(error.localizedDescription)")
                                FriendActivityBackend.logger.debug(" serious error \(error.localizedDescription)")
                            }
                        }
                        // network is down
                    }
                }
            }
            else {
                //self.debugLog.append("LOGGED OUT ACCESSTOKEN IS NIL, running logged getaccesstoken due to else clause in getfriendactivity")
                //Nprint("LOGGED OUT ACCESSTOKEN IS NIL")
                //Nprint("logged running getaccesstoken due to else clause in getfriendactivity")
                FriendActivityBackend.logger.debug(" running getaccesstoken due to else clause in getfriendactivity")
                let spDcCookie = keychain["spDcCookie"]
                if networkUp  {
                    do {
                        let spDcCookie = keychain["spDcCookie"]
                        //Nprint("logged: getaccesstoken: spdc cookie is \(keychain["spDcCookie"])")
                        FriendActivityBackend.logger.debug(" getaccesstoken spdc cookie is \(self.keychain["spDcCookie"].debugDescription)")
                        if (spDcCookie != nil) {
                            //self.debugLog.append("logged: spdc is \(spDcCookie.unsafelyUnwrapped)")
                            //self.debugLog.append("logged: getting access token")
                            //Nprint("logged: getting access token")
                            FriendActivityBackend.logger.debug(" getting acccess token")
                            let accessToken: accessTokenJSON =  try await fetch(urlString: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player", httpValue: "sp_dc=\(spDcCookie.unsafelyUnwrapped)", httpField: "Cookie")
                            keychain["accessToken"] = accessToken.accessToken
                            //self.debugLog.append("logged: access token is \(keychain["accessToken"])\n")
                            FriendActivityBackend.logger.debug(" accesstoken is \(self.keychain["accessToken"].debugDescription)")
                            //Nprint("logged: access token is \(keychain["accessToken"])")
                            await GetFriendActivity(animation: animation)
                        }
                        else {
                            // keychain current error will just say spdc is nil, so show previous REAL error
                            keychain["spDcCookie"] = nil
                            self.loggedOut = false
                            self.loggedOut = true
                            //self.debugLog.append("logged out in access token\n")
                            FriendActivityBackend.logger.debug(" logged out in access token")
                            //Nprint("LOGGED OUT IN ACCESS TOKEN")
                            keychain["accessToken"] = nil
                            
                        }
                    }
                    catch {
                        FriendActivityBackend.logger.debug(" error caused \(error.localizedDescription)")
                        //Nprint("error caused \(error)")
                        if (error is URLError) {
                            FriendActivityBackend.logger.debug(" just a network error")
                            //Nprint("ok just a network error, ignore maro")
                        }
                        else {
                            FriendActivityBackend.logger.debug(" not url error")
                            //Nprint("not url error")
                            if (networkUp) {
                                FriendActivityBackend.logger.debug(" removing broken spdc from errorjson")
                                //Nprint("logged, removing broken spdc from catching the errorjson")
                                keychain["spDcCookie"] = nil
                                self.loggedOut = false
                                self.loggedOut = true
                                //self.debugLog.append(
                            }
                        }
                    }
                }
            }
        //print("testing123: \(friendArray.unsafelyUnwrapped)")
        //return friendArrayInitial.friends.reversed()
    }
}
