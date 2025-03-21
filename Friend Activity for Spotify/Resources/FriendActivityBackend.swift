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
import WebKit
import os
import SDWebImage
import Amplitude_Swift
import SwiftOTP

@MainActor final class FriendActivityBackend: ObservableObject{
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FriendActivityBackend.self)
    )
    static let shared = FriendActivityBackend()
   // let actor = MyActor()
    let monitor = NWPathMonitor()
    @Published var tabSelection = 1
    @Published var networkUp: Bool = true
    @Published var friendArray: [Friend]? = nil
    @Published var loggedOut: Bool = false
    @Published var errorMessage: String = ""
    @Published var internetFetchWarning: String = ""
    @Published var isLoading: Bool = false
    @Published var tempNotificationSwipeOffset = CGSize.zero
    let amplitude: Amplitude
    // Fake Spotify User Agent
    // Spotify's started blocking my app's useragent. A win honestly 🤣
    let fakeSpotifyUserAgentconfig = URLSessionConfiguration.default
    let fakeSpotifyUserAgentSession: URLSession
    var accessToken: accessTokenJSON?
    @Published var DisplayUpdateAlert = false
    #if DEBUG
    @Published var debugError: String? = nil
    @Published var showDebugAlert = false
    #endif
    init() {
//        let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
//        print("Your cookie is \(UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")?.string(forKey: "spDcCookie"))")
        SDImageCache.defaultDiskCacheDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")?.appendingPathComponent("SDImageCache").path
        SDImageCache.shared.config.maxDiskAge = -1
        FriendActivityBackend.logger.debug(" friendactivitybackend initialized")
        amplitude = Amplitude(
            configuration: Configuration(
                apiKey: amplitudeApiKey
            )
        )
        monitor.start(queue: DispatchQueue.main)
        // Display only if it was set to true. It is only set to true for users that have opened 1.7
        // Hide from new users
        if UserDefaults.standard.bool(forKey: "showWelcomeToUpdateAlert") {
            DisplayUpdateAlert = true
            UserDefaults.standard.set(false, forKey: "showWelcomeToUpdateAlert")
        }
        // Set user agents for Spotify
        print("We have set up the fake spotify user agent")
        fakeSpotifyUserAgentconfig.httpAdditionalHeaders = ["User-Agent": "Spotify/121000760 Win32/0 (PC laptop)"]
        fakeSpotifyUserAgentSession = URLSession(configuration: fakeSpotifyUserAgentconfig)
        Task {
            print(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let url = URL(string: "https://spotifyfriend.com/urgentMessage.json")  {
                let request = URLRequest(url: url)
                let urlResponseAndData = try await URLSession(configuration: .ephemeral).data(for: request)
                do {
                    let messageJson = try JSONDecoder().decode(AviMessage.self, from: urlResponseAndData.0)
                    let currentVersion = Double(version)
                    guard let currentVersion else {
                        print("nil")
                        return
                    }
                    if messageJson.upcomingVersion > currentVersion {
                        print("\(messageJson.upcomingVersion) is higher than \(currentVersion)")
                        print("internetFetch warning set to \(messageJson.message)")
                        internetFetchWarning = messageJson.message
                     } else {
                         print("EQUAL")
                     }
                } catch {
                    print(error)
                }
            }
        }
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                switch path.status {
                    case .satisfied:
                        FriendActivityBackend.logger.debug(" logged satisfied in initialization")
                        if (!self.loggedOut) {
                            withAnimation {
                                self.networkUp = true
                            }
                            Task {
                                FriendActivityBackend.logger.debug(" LOGGED getfriendactivitycalled from .satisfied of network up")
                                await self.GetFriends()
                            } // Aksy das yrwr
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
        let (data, _) = try await fakeSpotifyUserAgentSession.data(for: request)
//        print(String(decoding: data, as: UTF8.self))
        #if DEBUG
        debugError = request.debugDescription + String(decoding: data, as: UTF8.self)
       // errorText.append(String(decoding: data, as: UTF8.self))
        #endif
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
                        self.amplitude.track(eventType: "Sign in")
                        Task {
                            FriendActivityBackend.logger.debug(" getfriendactivity called from checkifloggedin")
                            await FriendActivityBackend.shared.GetFriends()
                        }
                    }
                }
            }
        }
    }
    
    func logout() {
        amplitude.track(eventType: "Log out")
        loggedOut = true
        accessToken = nil
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
                   self.tempNotificationSwipeOffset = CGSize.zero
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
    
    // Thanks to Mx-lris
    enum TOTPGenerator {
         static func generate(serverTimeSeconds: Int) -> String? {
             let secretCipher = [12, 56, 76, 33, 88, 44, 88, 33, 78, 78, 11, 66, 22, 22, 55, 69, 54]
             var processed = [UInt8]()
             for (i, byte) in secretCipher.enumerated() {
                 processed.append(UInt8(byte ^ (i % 33 + 9)))
             }
             let processedStr = processed.map { String($0) }.joined()
             guard let utf8Bytes = processedStr.data(using: .utf8) else {
                 return nil
             }
             let secretBase32 = "GU2TANZRGQ2TQNJTGQ4DONBZHE2TSMRSGQ4DMMZQGMZDSMZUG4"//utf8Bytes.base32EncodedString
             guard let secretData = base32DecodeToData(secretBase32) else {
                 return nil
             }
             print("URL IS \(secretData.bytes)")
             print("URL IS \(secretBase32)")
             guard let totp = TOTP(secret: secretData, digits: 6, timeInterval: 30, algorithm: .sha1) else {
                 return nil
             }
             return totp.generate(secondsPast1970: serverTimeSeconds)
         }
     }
    
    func generateAccessToken(cookie: String) async throws {
        guard !cookie.isEmpty else { return }
        
        if accessToken == nil || (accessToken!.accessTokenExpirationTimestampMs <= Date().timeIntervalSince1970 * 1000) {
            while accessToken?.accessToken.range(of: "[-_]", options: .regularExpression) == nil {
                let serverTimeRequest = URLRequest(url: .init(string: "https://open.spotify.com/server-time")!)
                let serverTimeData = try await fakeSpotifyUserAgentSession.data(for: serverTimeRequest).0
                let serverTime = try JSONDecoder().decode(SpotifyServerTime.self, from: serverTimeData).serverTime
                
                if let totp = TOTPGenerator.generate(serverTimeSeconds: serverTime),
                   let url = URL(string: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player&totpVer=5&ts=\(Int(Date().timeIntervalSince1970))&totp=\(totp)") {
                    
                    print("URL IS \(url.absoluteString)")
                    var request = URLRequest(url: url)
                    request.setValue("sp_dc=\(cookie)", forHTTPHeaderField: "Cookie")
                    let accessTokenData = try await fakeSpotifyUserAgentSession.data(for: request)
                    print(String(decoding: accessTokenData.0, as: UTF8.self))
                    
                    do {
                        let fakeAccessToken = try JSONDecoder().decode(accessTokenJSON.self, from: accessTokenData.0)
                        accessToken = fakeAccessToken
                        print("ACCESS TOKEN IS SAVED")
                    } catch {
                        do {
                            let errorWrap = try JSONDecoder().decode(LFErrorWrapper.self, from: accessTokenData.0)
                            if errorWrap.error.code == 401 {
                                logout()
                                return
                            }
                        } catch {
                            // silently fail
                        }
                        print("json error decoding the access token, therefore bad cookie therefore un-onboard")
                    }
                }
            }
        }
    }
    
//    func generateAccessToken(cookie: String) async throws {
//        // NEW: generate TOTP
//        // Thanks to Mxlris-LyricsX-Project
//        /*
//         check if saved access token is bigger than current time, then continue with lyric fetch
//         else
//         check if we have spdc cookie, then access token stuff
//            then save access token in this observable object
//                then continue with lyric fetch
//         otherwise []
//         */
//        if accessToken == nil || (accessToken!.accessTokenExpirationTimestampMs <= Date().timeIntervalSince1970*1000) {
//            let serverTimeRequest = URLRequest(url: .init(string: "https://open.spotify.com/server-time")!)
//            let serverTimeData = try await fakeSpotifyUserAgentSession.data(for: serverTimeRequest).0
//            let serverTime = try JSONDecoder().decode(SpotifyServerTime.self, from: serverTimeData).serverTime
//            if let totp = TOTPGenerator.generate(serverTimeSeconds: serverTime), let url = URL(string: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player&totpVer=5&ts=\(Int(Date().timeIntervalSince1970))&totp=\(totp)"), cookie != "" {
//                print("URL IS \(url.absoluteString)")
//                var request = URLRequest(url: url)
//                request.setValue("sp_dc=\(cookie)", forHTTPHeaderField: "Cookie")
//                let accessTokenData = try await fakeSpotifyUserAgentSession.data(for: request)
//                print(String(decoding: accessTokenData.0, as: UTF8.self))
//                do {
//                    let fakeAccessToken = try JSONDecoder().decode(accessTokenJSON.self, from: accessTokenData.0)
//                    accessToken = fakeAccessToken
//                    print("ACCESS TOKEN IS SAVED")
//                } catch {
//                    do {
//                        let errorWrap = try JSONDecoder().decode(LFErrorWrapper.self, from: accessTokenData.0)
//                        if errorWrap.error.code == 401 {
////                            UserDefaults().set(false, forKey: "hasOnboarded")
//                            logout()
//                        }
//                    } catch {
//                        // silently fail
//                    }
//                    print("json error decoding the access token, therefore bad cookie therefore un-onboard")
//                }
//                
//            }
//        }
//    }
    
    func GetFriends() async {
        if isLoading {
            return
        }
        guard let cookie = UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")?.string(forKey: "spDcCookie") else {
            logout()
            isLoading = false
            return
        }
        try? await generateAccessToken(cookie: cookie)
        guard let accessToken = accessToken?.accessToken else {
            return
        }
        do {
//            print("access token \(accessToken)")
//            print("cookie: \(cookie)")
            let friendArrayInitial: Welcome = try await fetch(urlString: "https://spclient.wg.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken)", httpField: "Authorization", getOrPost: .get)
            var tempFriendArray = friendArrayInitial.friends
            tempFriendArray.reverse()
            withAnimation() {
                self.errorMessage = ""
                self.tempNotificationSwipeOffset = CGSize.zero
                self.friendArray = tempFriendArray
            }
            amplitude.track(eventType: "View Content")
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
        
//        do {
//            let accessTokenJson: accessTokenJSON = try await fetch(urlString: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player", httpValue: "sp_dc=\(cookie)", httpField: "Cookie", getOrPost: .get)
//            let accessToken:String = accessTokenJson.accessToken
////            do {
////                print("access token ")
////                let friendArrayInitial: Welcome = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken)", httpField: "Authorization", getOrPost: .get)
////                var tempFriendArray = friendArrayInitial.friends
////                tempFriendArray.reverse()
////                withAnimation() {
////                    self.errorMessage = ""
////                    self.tempNotificationSwipeOffset = CGSize.zero
////                    self.friendArray = tempFriendArray
////                }
////                amplitude.track(eventType: "View Content")
////                var count = UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")?.integer(forKey: "successCount") ?? 0
////                count += 1
////                UserDefaults(suiteName:
////                                "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")!.set(count, forKey: "successCount")
////                
////                // increase success count
////                // if count is 50 then show the popup
////                // CONTINUE
////            }
////            catch let error as DecodingError {
////                print("decoding error for frienddata. token is fucked or i haven't accounted for something")
////                print(error)
////                do {
////                    let errorWrap: ErrorWrapper = try await fetch(urlString: "https://spclient.wg.spotify.com/find-friends/v1/friends", httpValue: "Bearer \(accessToken)", httpField: "Authorization", getOrPost: .post)
////                    
////                    if (errorWrap.error.status == 401) {
////                        logout()
////                    }
////                    else if (errorWrap.error.status == 429) {
////                        errorNotification(newErrorMessage: "Too many requests. Try again later")
////                    }
////                    // LOGOUT
////                }
////                catch let error as DecodingError {
////                    print("i have not decoded the friend json properly. should never happen")
////                    print(error)
////                    errorNotification(newErrorMessage: "Error: \(error.localizedDescription)")
////                }
////                catch let error as URLError {
////                    print("url error. idk why. network error")
////                    print(error)
////                    errorNotification(newErrorMessage: "Error: \(error.localizedDescription)")
////                }
////                catch {
////                    print("something else")
////                    print(error)
////                    errorNotification(newErrorMessage: "Error: \(error.localizedDescription)")
////                }
////            }
////            catch let error as URLError {
////                print("urlerror for frienddata. network is down or incorrect URL")
////                print(error)
////                if error.errorCode != -999 {
////                    errorNotification(newErrorMessage: "Error: \(error.localizedDescription)")
////                }
////            }
////            catch {
////                print("error for friend data")
////                print(error)
////                errorNotification(newErrorMessage: "Error: \(error.localizedDescription)")
////            }
//        }
//        catch let error as DecodingError {
//            do {
//                let errorWrap: spDcErrorWrapper = try await fetch(urlString: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player", httpValue: "sp_dc=\(cookie)", httpField: "Cookie", getOrPost: .get)
//                
//                if (errorWrap.error.code == 401) {
//                    logout()
//                }
//                else if (errorWrap.error.code == 429) {
//                    errorNotification(newErrorMessage: "Too many requests. Try again later")
//                }
//                else {
//                    errorNotification(newErrorMessage: "Error: \(error.localizedDescription)")
//                }
//            }
//            catch {
//                print(error)
//                errorNotification(newErrorMessage: "Error: \(error.localizedDescription)")
//            }
//            print("decoding error for token. cookie was probably fucked")
//        }
//        catch let error as URLError {
//            print("url error for token. network is down or incorrect url")
//            print(error)
//            if error.errorCode != -999 {
//                errorNotification(newErrorMessage: "Error: \(error.localizedDescription)")
//            }
//        }
//        catch {
//            print("error for token")
//            print(error)
//            errorNotification(newErrorMessage: "Error: \(error.localizedDescription)")
//        }
//        isLoading = false
    }
}

//actor MyActor {
//    var running = false
//    func getFriends() async {
//        if !running {
//            running = true
//            await FriendActivityBackend.shared.GetFriends()
//            running = false
//        }
//        return
//    }
//}
