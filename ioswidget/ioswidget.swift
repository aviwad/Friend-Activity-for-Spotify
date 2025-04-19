//
//  iosWidget.swift
//  iosWidget
//
//  Created by Avi Wadhwa on 2022-04-25.
//

import WidgetKit
import SwiftUI
import SDWebImage
import SwiftOTP

struct Provider: TimelineProvider {
    var friendArray : [Friend]?
    
    func fetch<T: Decodable>(urlString: String, httpValue: String, httpField: String, getOrPost: GetOrPost, fakeSpotifyUserAgentSession: URLSession) async throws -> T {
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
        //FriendActivityBackend.logger.debug(" LOGGED \(data.debugDescription)")
        let json = try JSONDecoder().decode(T.self, from: data)
        return json
    }
    
    func favoriteFriendFromApp(friends: [Friend], DownloadAlbumArt: Bool) -> ([Friend],[UIImage],UIImage?) {
        if let favorite = UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")!.string(forKey: "favoriteId"), let favoriteFriend = friends.first(where: {$0.id == favorite}) {
            let newFriendArray = [favoriteFriend]
            let imageArray = imageArrayFromFriends(newFriendArray)
            let albumArt: UIImage?
            if DownloadAlbumArt {
                albumArt = getAlbumArt(DownloadAlbumArt: DownloadAlbumArt, Friend: favoriteFriend)
            } else {
                albumArt = nil
            }
            return (newFriendArray,imageArray,albumArt)
        }
        else {
            return ([],[],nil)
        }
    }
    
    func imageArrayFromFriends(_ friends: [Friend]) -> ([UIImage]) {
        var imageArray : [UIImage] = []
        for friend in friends {
            if (friend.user.imageURL == nil) {
                imageArray.append(UIImage(named: "person.png")!)
            } else {

                imageArray.append(UIImage(data: try! Data.ReferenceType(contentsOf: friend.user.imageURL!) as Data)!)
            }
        }
        return imageArray
    }
    
    func getAlbumArt(DownloadAlbumArt: Bool, Friend: Friend?) -> UIImage? {
        let albumArt: UIImage?
        if DownloadAlbumArt {
            if let firstFriend = Friend, let imageUrl = firstFriend.track.imageURL, let data = try? Data.ReferenceType(contentsOf: imageUrl) as Data {
                albumArt = UIImage(data: data)
            } else {
                albumArt = UIImage(systemName: "music.microphone.circle")
            }
        } else {
            albumArt = nil
        }
        return albumArt
    }
    
    func friendsFromApp(_ DownloadAlbumArt: Bool, _ pickFavorite: Bool) async -> ([Friend],[UIImage],UIImage?){
        
        let lastUpdated = UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")!.integer(forKey: "lastSavedTime")
        print(lastUpdated.distance(to: Int(CACurrentMediaTime())))
        print("TEST")
        if (lastUpdated.distance(to: Int(CACurrentMediaTime())) > 600) {
//        if true {
            // query online
            print("Running Get Friends online")
            return await GetFriends(DownloadAlbumArt,pickFavorite)
        }
        let encodedData  = UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")!.object(forKey: "friendArray") as? Data
        /* Decoding it using JSONDecoder*/
        
        if let friendEncoded = encodedData {
             let friendDecoded = try? JSONDecoder().decode([Friend].self, from: friendEncoded)
            if let friendArray2 = friendDecoded{
                if pickFavorite {
                    return favoriteFriendFromApp(friends: friendArray2, DownloadAlbumArt: DownloadAlbumArt)
                }
                let friendArray = Array(friendArray2.prefix(4))
                let imageArray : [UIImage] = imageArrayFromFriends(friendArray)
                
                // Only for systemSmall widget, download first friend's track's album art
                let albumArt: UIImage? = getAlbumArt(DownloadAlbumArt: DownloadAlbumArt, Friend: friendArray.first)
                
                return (friendArray,imageArray, albumArt)
                // You successfully retrieved your car object!
            }
        }
        return ([],[],nil)
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
    func GetFriends(_ DownloadAlbumArt: Bool = false, _ pickFavorite: Bool = false) async -> ([Friend],[UIImage],UIImage?){
        let fakeSpotifyUserAgentconfig = URLSessionConfiguration.default
        let fakeSpotifyUserAgentSession: URLSession
        fakeSpotifyUserAgentconfig.httpAdditionalHeaders = ["User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_7_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.3 Safari/605.1.15"]
        fakeSpotifyUserAgentSession = URLSession(configuration: fakeSpotifyUserAgentconfig)
        guard let cookie = UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")?.string(forKey: "spDcCookie") else {
            // error
            return ([],[],nil)
        }
        do {
            var accessToken: accessTokenJSON?
            var repeatCount = 0
            repeat {
                if repeatCount == 3 {
                    throw AccessTokenError.toomanytries
                }
                print("starting while, accesstoken is \(accessToken?.accessToken)")
                let serverTimeRequest = URLRequest(url: .init(string: "https://open.spotify.com/server-time")!)
                let serverTimeData = try await fakeSpotifyUserAgentSession.data(for: serverTimeRequest).0
                let serverTime = try JSONDecoder().decode(SpotifyServerTime.self, from: serverTimeData).serverTime
                
                if let totp = TOTPGenerator.generate(serverTimeSeconds: serverTime), let url = URL(string: "https://open.spotify.com/get_access_token?reason=transport&productType=web-player&totp=\(totp)&totpServer=\(Int(Date().timeIntervalSince1970))&totpVer=5&sTime=\(serverTime)&cTime=\(serverTime)") {
                    
                    var request = URLRequest(url: url)
                    request.setValue("sp_dc=\(cookie)", forHTTPHeaderField: "Cookie")
                    let accessTokenData = try await fakeSpotifyUserAgentSession.data(for: request)
                    print(String(decoding: accessTokenData.0, as: UTF8.self))
                    
                    do {
                        let fakeAccessToken = try JSONDecoder().decode(accessTokenJSON.self, from: accessTokenData.0)
                        accessToken = fakeAccessToken
                        print("ACCESS TOKEN IS SAVED")
                    } catch {
                        return ([],[],nil)
                    }
                }
                repeatCount += 1
            } while accessToken?.accessToken.range(of: "[-_]", options: .regularExpression) == nil
            do {
                guard let accessToken else {
                    return ([],[],nil)
                }
                print("access token ")
                let friendArrayInitial: Welcome = try await fetch(urlString: "https://spclient.wg.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken.accessToken)", httpField: "Authorization", getOrPost: .get, fakeSpotifyUserAgentSession: fakeSpotifyUserAgentSession)
                if pickFavorite {
                    return favoriteFriendFromApp(friends: friendArrayInitial.friends, DownloadAlbumArt: DownloadAlbumArt)
                }
                let friendArray = Array(friendArrayInitial.friends.reversed().prefix(4))
                let imageArray : [UIImage] = imageArrayFromFriends(friendArray)
                let albumArt: UIImage? = getAlbumArt(DownloadAlbumArt: DownloadAlbumArt, Friend: friendArray.first)
                return (friendArray,imageArray, albumArt)
            }
            catch {
                return ([],[],nil)
            }
        }
        catch {
            print("error for token")
            print(error)
            return ([],[],nil)
            // NOTIFICATION THAT ERROR OCCURRED
        }

    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), friends: ([],[UIImage(systemName: "person.fill")!,UIImage(systemName: "person.fill")!,UIImage(systemName: "person.fill")!,UIImage(systemName: "person.fill")!],nil))
    }
    
    func isSmallWidget(_ context: Context) -> Bool {
        return context.family == .systemSmall
    }
    
    func isFavouriteWidget(_ context: Context) -> Bool {
        if #available(iOSApplicationExtension 16.0, *) {
            return context.family == .systemSmall || context.family == .accessoryRectangular
        } else {
            // Fallback on earlier versions
            return context.family == .systemSmall
        }
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Task {
            let entry = await SimpleEntry(date: Date(), friends: self.friendsFromApp(isSmallWidget(context),isFavouriteWidget(context)))
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let entry = await SimpleEntry(date: Date(), friends: self.friendsFromApp(isSmallWidget(context),isFavouriteWidget(context)))
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }

}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let friends: (friends:[Friend],pfp:[UIImage],albumart: UIImage?)
//    let albumArt: UIImage?
}

struct iosWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    var body: some View {
        if (widgetFamily == .systemLarge) {
            LargeView(entry: entry)
        } else if (widgetFamily == .systemSmall) {
            SmallView(entry: entry)
        } else if #available(iOSApplicationExtension 16.0, *), (widgetFamily == .accessoryRectangular) {
            AccessoryRectangularView(entry: entry)
        } else {
            MediumView(entry: entry)
        }
    }
}

@main
struct iosWidget: Widget {
    let kind: String = "iosWidget"

    var body: some WidgetConfiguration {
	StaticConfiguration(kind: kind, provider: Provider()) { entry in
    	iosWidgetEntryView(entry: entry)
        }
    .adaptedSupportedFamilies()
    .contentMarginsDisabled()
//    .supportedFamilies(adaptedSupportedFamilies())//[.systemMedium,.systemLarge,.systemSmall,.accessoryRectangular])
        .configurationDisplayName("Friend Activity")
        .description("See what your friends are listening to at a glance.")
    }
}

extension View {
    func widgetBackground(backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}

extension WidgetConfiguration {
    func adaptedSupportedFamilies() -> some WidgetConfiguration {
        if #available(iOS 16, *) {
            return self.supportedFamilies([
                .systemSmall,
                .systemMedium,
                .systemLarge,
                .accessoryRectangular,
                
            ])
        } else {
            return self.supportedFamilies([
                .systemSmall,
                .systemMedium,
                .systemLarge,
                .systemSmall
            ])
        }
    }
}

enum AccessTokenError: Error {
    case toomanytries
}
