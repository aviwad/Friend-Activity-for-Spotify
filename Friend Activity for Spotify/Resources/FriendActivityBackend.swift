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
    @Published var debug = ""
    @Published var error = ""
    @Published var networkUp: Bool = true
    @Published var friendArray: [Friend]? = nil
    @Published var loggedOut: Bool = false
    //@Published var youHaveNoFriends: Bool = false
    var spDcCookie = "" 
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
            let accessToken: accessTokenJSON =  try await fetch(urlString: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player", httpValue: "sp_dc=\(spDcCookie)", httpField: "Cookie")
            keychain["accessToken"] = accessToken.accessToken
        }
        catch {
            spDcCookie = ""
            self.loggedOut = false
            self.loggedOut = true
            debug = "logged out in access token"
            self.error = error.localizedDescription
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
                debug = "logged out cuz of friendarrayinitial error"
                self.error = error.localizedDescription
                print("LOGGED \(accessToken.unsafelyUnwrapped)")
                print("LOGGED Error info: \(error)")
                print("LOGGED OUT CUZ OF FRIENDARRAYINITIAL ERROR")
                if (networkUp) {
                    do {
                        let errorMessage: WelcomeError
                        errorMessage = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken.unsafelyUnwrapped)", httpField: "Authorization")
                        debug = "logged out through errorJSON (access token is fucked)"
                        self.error = errorMessage.error.message
                        print("LOGGED \(errorMessage)")
                        self.keychain["accessToken"] = nil
                        loggedOut = true
                    }
                    catch {
                        debug = debug+"AND errorJSON"
                        self.error = self.error+" AND "+error.localizedDescription
                    }
                }
            }
        }
        else {
            debug = "logged out cuz accesstoken is nil"
            self.error = "none"
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
                debug = "logged out cuz of friendarrayinitial error no animation"
                self.error = error.localizedDescription
                print("LOGGED \(accessToken.unsafelyUnwrapped)")
                print("LOGGED Error info: \(error)")
                print("LOGGED OUT CUZ OF FRIENDARRAYINITIAL ERROR no animation")
                if (networkUp) {
                    do {
                        let errorMessage: WelcomeError
                        errorMessage = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken.unsafelyUnwrapped)", httpField: "Authorization")
                        debug = "logged out through errorJSON (access token is fucked) (no animation)"
                        self.error = errorMessage.error.message
                        print("LOGGED \(errorMessage)")
                        self.keychain["accessToken"] = nil
                        loggedOut = true
                    }
                    catch {
                        debug = debug+"AND errorJSON (no animation)"
                        self.error = self.error+" AND "+error.localizedDescription
                    }
                }
            }
        }
        else {
            debug = "logged out cuz accesstoken is nil no animation"
            self.error = "none"
            print("LOGGED OUT ACCESSTOKEN IS NIL no animation")
            self.loggedOut = true
        }
        //print("testing123: \(friendArray.unsafelyUnwrapped)")
        //return friendArrayInitial.friends.reversed()
    }
}
