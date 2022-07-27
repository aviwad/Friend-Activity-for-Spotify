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
    @Published var tabSelection = 1
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
                        print("LOGGED SATISFIED")
                        withAnimation {
                            self.networkUp = true
                            Task {
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
                print("LOGGED dispatch queue is working")
                WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                    cookies.forEach { cookie in
                        if (cookie.name == "sp_dc") {
                            print("LOGGED sp_dc is \(cookie.value)")
                            FriendActivityBackend.shared.keychain["spDcCookie"] = cookie.value
                            Task {
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
                print("LOGGED ACCESS TOKEN FOUND")
                self.loggedOut = false
                let friendArrayInitial: Welcome
                do {
                    if (networkUp) {
                        print("LOGGED NETWORK UP, FRIENDARRAYINTIAL CALLED")
                        friendArrayInitial = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken.unsafelyUnwrapped)", httpField: "Authorization")
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
                    print("LOGGED \(accessToken.unsafelyUnwrapped)")
                    print("LOGGED Error info: \(error)")
                    print("LOGGED OUT CUZ OF FRIENDARRAYINITIAL ERROR")
                    if (networkUp) {
                        do {
                            let errorMessage: WelcomeError
                            errorMessage = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken.unsafelyUnwrapped)", httpField: "Authorization")
                            print("logged, removing brokenaccesstoken from catching the errorjson")
                            keychain["accessToken"] = nil
                            print("logged, getfriendactivity called from catching the errorjson")
                            await GetFriendActivity()
                            print("LOGGED \(errorMessage)")
                            //self.keychain["accessToken"] = nil
                            //self.keychain["spDcCookie"] = nil
                            //loggedOut = true
                        }
                        catch {
                            print("LOGGED \(error.localizedDescription)")
                        }
                    }
                }
            }
            else {
                print("LOGGED OUT ACCESSTOKEN IS NIL")
                print("logged running getaccesstoken due to else clause in getfriendactivity")
                do {
                    let spDcCookie = keychain["spDcCookie"]
                    print("logged: getaccesstoken: spdc cookie is \(keychain["spDcCookie"])")
                    if (spDcCookie != nil) {
                        print("logged: getting access token")
                        let accessToken: accessTokenJSON =  try await fetch(urlString: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player", httpValue: "sp_dc=\(spDcCookie.unsafelyUnwrapped)", httpField: "Cookie")
                        keychain["accessToken"] = accessToken.accessToken
                        print("logged: access token is \(keychain["accessToken"])")
                        self.currentlyRunning = false
                        await GetFriendActivity()
                    }
                    else {
                        keychain["spDcCookie"] = nil
                        self.loggedOut = false
                        self.loggedOut = true
                        print("LOGGED OUT IN ACCESS TOKEN")
                        keychain["accessToken"] = nil
                        self.currentlyRunning = false
                    }
                }
                catch {
                    keychain["spDcCookie"] = nil
                    self.loggedOut = false
                    self.loggedOut = true
                    print("LOGGED OUT IN ACCESS TOKEN")
                    keychain["accessToken"] = nil
                    self.currentlyRunning = false
                }
            }
        }
        else {
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
                print("LOGGED ACCESS TOKEN FOUND (no animation)")
                self.loggedOut = false
                let friendArrayInitial: Welcome
                do {
                    if (networkUp) {
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
                    print("LOGGED \(accessToken.unsafelyUnwrapped) (no animation)")
                    print("LOGGED Error info: \(error) (no animation)")
                    print("LOGGED OUT CUZ OF FRIENDARRAYINITIAL ERROR (no animation)")
                    if (networkUp) {
                        do {
                            let errorMessage: WelcomeError
                            errorMessage = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken.unsafelyUnwrapped)", httpField: "Authorization")
                            print("logged, removing brokenaccesstoken from catching the errorjson no animation")
                            keychain["accessToken"] = nil
                            print("logged, getfriendactivity called from catching the errorjson no animation")
                            await GetFriendActivity()
                            print("LOGGED \(errorMessage)")
                            //self.keychain["accessToken"] = nil
                            //self.keychain["spDcCookie"] = nil
                            //loggedOut = true
                        }
                        catch {
                            print("LOGGED \(error.localizedDescription)")
                        }
                    }
                    self.currentlyRunning = false
                }
            }
            else {
                print("LOGGED OUT ACCESSTOKEN IS NIL")
                print("logged running getaccesstoken due to else clause in getfriendactivity")
                do {
                    let spDcCookie = keychain["spDcCookie"]
                    print("logged: getaccesstoken: spdc cookie is \(keychain["spDcCookie"])")
                    if (spDcCookie != nil) {
                        print("logged: getting access token")
                        let accessToken: accessTokenJSON =  try await fetch(urlString: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player", httpValue: "sp_dc=\(spDcCookie.unsafelyUnwrapped)", httpField: "Cookie")
                        keychain["accessToken"] = accessToken.accessToken
                        print("logged: access token is \(keychain["accessToken"])")
                        self.currentlyRunning = false
                        await GetFriendActivity()
                    }
                    else {
                        keychain["spDcCookie"] = nil
                        self.loggedOut = false
                        self.loggedOut = true
                        print("LOGGED OUT IN ACCESS TOKEN")
                        keychain["accessToken"] = nil
                        self.currentlyRunning = false
                    }
                }
                catch {
                    keychain["spDcCookie"] = nil
                    self.loggedOut = false
                    self.loggedOut = true
                    print("LOGGED OUT IN ACCESS TOKEN")
                    keychain["accessToken"] = nil
                    self.currentlyRunning = false
                }
            }
        }
        else {
            print("logged, friendactivity declined due to current running process")
        }
        //print("testing123: \(friendArray.unsafelyUnwrapped)")
        //return friendArrayInitial.friends.reversed()
    }
}
