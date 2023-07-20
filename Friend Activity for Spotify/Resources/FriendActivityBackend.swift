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
import SDWebImage

@MainActor final class FriendActivityBackend: ObservableObject{
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FriendActivityBackend.self)
    )
    static let shared = FriendActivityBackend()
    let actor = MyActor()
    let monitor = NWPathMonitor()
    let keychain = Keychain(service: "aviwad.Friend-Activity-for-Spotify", accessGroup: "38TP6LZLJ5.sharing")
        .accessibility(.afterFirstUnlock)
    @Published var tabSelection = 1
    @Published var networkUp: Bool = true
    @Published var friendArray: [Friend]? = nil
    @Published var loggedOut: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    init() {
        SDImageCache.defaultDiskCacheDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")?.appendingPathComponent("SDImageCache").path
        SDImageCache.shared.config.maxDiskAge = -1
        FriendActivityBackend.logger.debug(" friendactivitybackend initialized")
        monitor.start(queue: DispatchQueue.main)
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                switch path.status {
                    case .satisfied:
                        FriendActivityBackend.logger.debug(" logged satisfied in initialization")
                        if (!self.loggedOut) {
                            withAnimation {
                                self.networkUp = true
                                self.isLoading = true
                                Task {
                                    FriendActivityBackend.logger.debug(" LOGGED getfriendactivitycalled from .satisfied of network up")
                                    await self.actor.getFriends()
                                } // Aksy das yrwr
                            }
                        }
                        else {
                            FriendActivityBackend.logger.debug(" logged .satisfied canceled (logged out: \(self.loggedOut)")
                        }
                    default:
                        withAnimation {self.networkUp = false}
                }
            }
        }
    }
    func fetch<T: Decodable>(urlString: String, httpValue: String, httpField: String, getOrPost: GetOrPost) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        if (getOrPost == .get) {
            request.httpMethod = "GET"
        } else {
            request.httpMethod = "POST"
        }
        request.setValue(httpValue, forHTTPHeaderField: httpField)
         let (data, _) = try await URLSession.shared.data(for: request)
        let jsonText = try! JSONSerialization.jsonObject(with: data, options: [.allowFragments])
        print(jsonText)
        let json = try JSONDecoder().decode(T.self, from: data)
        return json
    }

    

    func checkIfLoggedIn() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            FriendActivityBackend.logger.debug(" LOGGED dispatch queue is working (check if logged in function is running)")
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                cookies.forEach { cookie in
                    if (cookie.name == "sp_dc") {
                        FriendActivityBackend.logger.debug(" sp_dc cookie was found! the value is \(cookie.value) and loggedout will be set to false")
                        UserDefaults(suiteName:
                                        "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")!.set(cookie.value, forKey: "spDcCookie")
                        FriendActivityBackend.shared.tabSelection = 1
                        FriendActivityBackend.shared.loggedOut = false
                        FriendActivityBackend.shared.isLoading = true
                        Task {
                            FriendActivityBackend.logger.debug(" getfriendactivity called from checkifloggedin")
                            await FriendActivityBackend.shared.actor.getFriends()
                        }
                    }
                }
            }
        }
    }
    
    func logout() {
        loggedOut = true
        UserDefaults(suiteName:
                        "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")!.set(nil, forKey: "spDcCookie")
        errorNotification(newErrorMessage: "Logged out.")
    }
    
    func errorNotification(newErrorMessage: String) {
        withAnimation() {
            errorMessage = newErrorMessage
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
               withAnimation {
                   self.errorMessage = ""
               }
           }
    }
    
    func updateWidget() {
        let friendData = try! JSONEncoder().encode(friendArray ?? [])
        UserDefaults(suiteName:
                        "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")!.set(friendData, forKey: "friendArray")
        UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")!.set(Int(CACurrentMediaTime()), forKey: "lastSavedTime")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func GetFriends() async {
        guard let cookie = UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")?.string(forKey: "spDcCookie") else {
            guard let cookie = keychain["spDcCookie"] else {
                logout()
                isLoading = false
                return
            }
            UserDefaults(suiteName:
                            "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")!.set(cookie, forKey: "spDcCookie")
            isLoading = false
            return
        }
        do {
            let accessTokenJson: accessTokenJSON = try await fetch(urlString: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player", httpValue: "sp_dc=\(cookie)", httpField: "Cookie", getOrPost: .get)
            let accessToken:String = accessTokenJson.accessToken
            do {
                print("access token ")
                let friendArrayInitial: Welcome = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken)", httpField: "Authorization", getOrPost: .get)
                var tempFriendArray = friendArrayInitial.friends
                tempFriendArray.reverse()
                withAnimation() {
                    friendArray = tempFriendArray
                }
                var count = UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")?.integer(forKey: "successCount") ?? 0
                count += 1
                UserDefaults(suiteName:
                                "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")!.set(count, forKey: "successCount")
                
                
                // increase success count
                // if count is 50 then show the popup
                // CONTINUE
            }
            catch let error as DecodingError {
                print("decoding error for frienddata. token is fucked or i haven't accounted for something")
                print(error)
                do {
                    let errorWrap: ErrorWrapper = try await fetch(urlString: "https://spclient.wg.spotify.com/find-friends/v1/friends", httpValue: "Bearer \(accessToken)", httpField: "Authorization", getOrPost: .post)
                    
                    if (errorWrap.error.status == 401) {
                        logout()
                    }
                    else if (errorWrap.error.status == 429) {
                        errorNotification(newErrorMessage: "Too many requests. Try again later")
                    }
                    // LOGOUT
                }
                catch let error as DecodingError {
                    print("i have not decoded the friend json properly. should never happen")
                    print(error)
                    errorNotification(newErrorMessage: "Error: \(error.localizedDescription)")
                }
                catch let error as URLError {
                    print("url error. idk why. network error")
                    print(error)
                    errorNotification(newErrorMessage: "Error: \(error.localizedDescription)")
                }
                catch {
                    print("something else")
                    print(error)
                    errorNotification(newErrorMessage: "Error: \(error.localizedDescription)")
                }
            }
            catch let error as URLError {
                print("urlerror for frienddata. network is down or incorrect URL")
                print(error)
                if error.errorCode != -999 {
                    errorNotification(newErrorMessage: "Error: \(error.localizedDescription)")
                }
            }
            catch {
                print("error for friend data")
                print(error)
                errorNotification(newErrorMessage: "Error: \(error.localizedDescription)")
            }
        }
        catch let error as DecodingError {
            do {
                let errorWrap: spDcErrorWrapper = try await fetch(urlString: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player", httpValue: "sp_dc=\(cookie)", httpField: "Cookie", getOrPost: .get)
                
                if (errorWrap.error.code == 401) {
                    logout()
                }
                else if (errorWrap.error.code == 429) {
                    errorNotification(newErrorMessage: "Too many requests. Try again later")
                }
            }
            catch {
                print(error)
                errorNotification(newErrorMessage: "Error: \(error.localizedDescription)")
            }
            print("decoding error for token. cookie was probably fucked")
        }
        catch let error as URLError {
            print("url error for token. network is down or incorrect url")
            print(error)
            if error.errorCode != -999 {
                errorNotification(newErrorMessage: "Error: \(error.localizedDescription)")
            }
        }
        catch {
            print("error for token")
            print(error)
            errorNotification(newErrorMessage: "Error: \(error.localizedDescription)")
        }
        isLoading = false
    }
}

actor MyActor {
    var running = false
    //@Published var latestResult: Date?
    func getFriends() async {
        if !running {
            running = true
            await FriendActivityBackend.shared.GetFriends()
            running = false
        }
        return
    }
}
