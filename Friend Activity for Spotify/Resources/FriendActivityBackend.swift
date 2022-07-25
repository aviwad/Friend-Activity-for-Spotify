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
//import SwiftKeychainWrapper

@MainActor final class FriendActivityBackend: ObservableObject{
    static let shared = FriendActivityBackend()
    let monitor = NWPathMonitor()
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
                    Task {
                        self.GetFriendActivity
                        
                    }
                    withAnimation {
                        self.networkUp = true
                        
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
        let accessToken = try? keychain.get("accessToken")
        //let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        if (accessToken != nil) {
            self.loggedOut = false
            let friendArrayInitial: Welcome
            do {
                if (networkUp) {
                    friendArrayInitial = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken.unsafelyUnwrapped)", httpField: "Authorization")
                    print("testing123: friendarrayinitial")
                    //youHaveNoFriends = false
                    withAnimation(){
                        friendArray = friendArrayInitial.friends.reversed()
                        WidgetCenter.shared.reloadAllTimelines()
                    }
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
                        await GetAccessToken()
                        await GetFriendActivity()
                        print("LOGGED \(errorMessage)")
                        //self.keychain["accessToken"] = nil
                        //self.keychain["spDcCookie"] = nil
                        //loggedOut = true
                    }
                    catch {
                    }
                }
            }
        }
        else {
            print("LOGGED OUT ACCESSTOKEN IS NIL")
            self.loggedOut = true
        }
        //print("testing123: \(friendArray.unsafelyUnwrapped)")
        //return friendArrayInitial.friends.reversed()
    }
    
    func GetFriendActivityNoAnimation() async {
        let accessToken = try? keychain.get("accessToken")
        //let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        if (accessToken != nil) {
            self.loggedOut = false
            let friendArrayInitial: Welcome
            do {
                if (networkUp) {
                    friendArrayInitial = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken.unsafelyUnwrapped)", httpField: "Authorization")
                    print("testing123: friendarrayinitial")
                    //youHaveNoFriends = false
                    friendArray = friendArrayInitial.friends.reversed()
                    WidgetCenter.shared.reloadAllTimelines()
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
                        print("LOGGED \(errorMessage)")
                        await GetAccessToken()
                        await GetFriendActivityNoAnimation()
                        //self.keychain["accessToken"] = nil
                        //self.keychain["spDcCookie"] = nil
                        //loggedOut = true
                    }
                    catch {
                    }
                }
            }
        }
        else {
            print("LOGGED OUT ACCESSTOKEN IS NIL")
            self.loggedOut = true
        }
        //print("testing123: \(friendArray.unsafelyUnwrapped)")
        //return friendArrayInitial.friends.reversed()
    }
}
