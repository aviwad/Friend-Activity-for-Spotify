//
//  iosWidget.swift
//  iosWidget
//
//  Created by Avi Wadhwa on 2022-04-25.
//

import WidgetKit
import SwiftUI
import KeychainAccess
import SDWebImage

struct Provider: TimelineProvider {
    var friendArray : [Friend]?
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
        //FriendActivityBackend.logger.debug(" LOGGED \(data.debugDescription)")
        let json = try JSONDecoder().decode(T.self, from: data)
        return json
    }
    
    func friendsFromApp() async -> ([Friend],[UIImage]){
        SDImageCache.defaultDiskCacheDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")?.appendingPathComponent("SDImageCache").path
        let lastUpdated = UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")!.integer(forKey: "lastSavedTime")
        print(lastUpdated.distance(to: Int(CACurrentMediaTime())))
        if (lastUpdated.distance(to: Int(CACurrentMediaTime())) > 300) {
            // query online
            return await GetFriends()
        }
        let encodedData  = UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")!.object(forKey: "friendArray") as? Data
        /* Decoding it using JSONDecoder*/
        if let friendEncoded = encodedData {
             let friendDecoded = try? JSONDecoder().decode([Friend].self, from: friendEncoded)
            if let friendArray2 = friendDecoded{
                let friendArray = Array(friendArray2.prefix(4))
                var imageArray : [UIImage] = []
                for friend in friendArray {
                    if (friend.user.imageURL.isEmpty) {
                        imageArray.append(UIImage(named: "person.png")!)
                    } else {
                        let key = SDWebImageManager.shared.cacheKey(for: URL(string: friend.user.imageURL))
                        if let image = SDImageCache.shared.imageFromDiskCache(forKey: key) {
                            imageArray.append(image)
                        }
                        else if let image = UIImage(data: try! Data.ReferenceType(contentsOf: URL(string: friend.user.imageURL)!) as Data) {
                            imageArray.append(image)
                        }
                        else {
                            imageArray.append(UIImage(named: "person.png")!)
                        }
                        //imageArray.append(UIImage(data: try! Data.ReferenceType(contentsOf: URL(string: friend.user.imageURL)!) as Data)!)
                    }
                }
                return (friendArray,imageArray)
                // You successfully retrieved your car object!
            }
        }
        return ([],[])
    }
    
    func GetFriends() async -> ([Friend],[UIImage]){
        //guard let cookie = keychain["spDcCookie"] else {
        guard let cookie = UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")?.string(forKey: "spDcCookie") else {
            // error
            return ([],[])
        }
        do {
            let accessTokenJson: accessTokenJSON = try await fetch(urlString: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player", httpValue: "sp_dc=\(cookie)", httpField: "Cookie", getOrPost: .get)
            let accessToken:String = accessTokenJson.accessToken
            do {
                print("access token ")
                let friendArrayInitial: Welcome = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken)", httpField: "Authorization", getOrPost: .get)
                let friendArray = Array(friendArrayInitial.friends.reversed().prefix(4))
                var imageArray : [UIImage] = []
                for friend in friendArray {
                    if (friend.user.imageURL.isEmpty) {
                        imageArray.append(UIImage(systemName: "person.png")!)
                    } else {
                        let key = SDWebImageManager.shared.cacheKey(for: URL(string: friend.user.imageURL))
                        if let image = SDImageCache.shared.imageFromDiskCache(forKey: key) {
                            imageArray.append(image)
                        }
                        else {
                            imageArray.append(UIImage(named: "person.png")!)
                        }
                        //imageArray.append(UIImage(data: try! Data.ReferenceType(contentsOf: URL(string: friend.user.imageURL)!) as Data)!)
                    }
                }
                return (friendArray,imageArray)
//                    UserDefaults(suiteName:
//                                    "group.aviwad.Friend-Activity-for-Spotify")!.set(friendArray!, forKey: "friendArray")
//                    WidgetCenter.shared.reloadAllTimelines()
                //}
                // CONTINUE
            }
            catch {
                return ([],[])
            }
        }
        catch {
            print("error for token")
            print(error)
            return ([],[])
            // NOTIFICATION THAT ERROR OCCURRED
        }

    }
    

//    func GetFriendActivityWidget() async -> ([Friend],[UIImage], String?) {
//        let keychain = Keychain(service: "aviwad.Friend-Activity-for-Spotify", accessGroup: "38TP6LZLJ5.sharing")
//            .accessibility(.afterFirstUnlock)
//        let accessToken = try? keychain.get("accessToken")
//        //let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
//        if (accessToken != nil) {
//            let friendArrayInitial: Welcome
//            do {
//                friendArrayInitial = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken.unsafelyUnwrapped)", httpField: "Authorization")
//                 print("testing123: friendarrayinitial")
//                let friendArray = Array(friendArrayInitial.friends.reversed().prefix(4))
//                var imageArray : [UIImage] = []
//                for friend in friendArray {
//                    if (friend.user.imageURL.isEmpty) {
//                        imageArray.append(UIImage(systemName: "person.fill")!)
//                    } else {
//                        imageArray.append(UIImage(data: try! Data.ReferenceType(contentsOf: URL(string: friend.user.imageURL)!) as Data)!)
//                    }
//                }
//                return (friendArray,imageArray,nil)
//                 //youHaveNoFriends = false
//
//                 //WidgetCenter.shared.reloadAllTimelines()
//            }
//            catch {
//                return await GetFriendActivityWidgetWithNewToken()
//                //print(error)
//                //return ([],[],error.localizedDescription)
//            }
//        }
//        return ([],[],nil)
//    }

//    func GetFriendActivityWidgetWithNewToken() async -> ([Friend],[UIImage],String?) {
//        let keychain = Keychain(service: "aviwad.Friend-Activity-for-Spotify", accessGroup: "38TP6LZLJ5.sharing")
//            .accessibility(.afterFirstUnlock)
//        //let accessToken = try? keychain.get("accessToken")
//        let spDcCookie = try? keychain.get("spDcCookie")
//        //let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
//        if (spDcCookie != nil) {
//            let friendArrayInitial: Welcome
//            do {
//                let accessToken: accessTokenJSON =  try await fetch(urlString: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player", httpValue: "sp_dc=\(spDcCookie.unsafelyUnwrapped)", httpField: "Cookie")
//                keychain["accessToken"] = accessToken.accessToken
//                friendArrayInitial = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken.accessToken)", httpField: "Authorization")
//                 print("testing123: friendarrayinitial")
//                let friendArray = Array(friendArrayInitial.friends.reversed().prefix(4))
//                var imageArray : [UIImage] = []
//                for friend in friendArray {
//                    if (friend.user.imageURL.isEmpty) {
//                        imageArray.append(UIImage(systemName: "person.fill")!)
//                    } else {
//                        imageArray.append(UIImage(data: try! Data.ReferenceType(contentsOf: URL(string: friend.user.imageURL)!) as Data)!)
//                    }
//                }
//                return (friendArray,imageArray,nil)
//                 //youHaveNoFriends = false
//
//                 //WidgetCenter.shared.reloadAllTimelines()
//            }
//            catch {
//                print(error)
//                return ([],[],error.localizedDescription)
//            }
//        }
//        return ([],[],nil)
//    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), friends: ([],[UIImage(systemName: "person.fill")!,UIImage(systemName: "person.fill")!,UIImage(systemName: "person.fill")!,UIImage(systemName: "person.fill")!]))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Task {
            let entry = await SimpleEntry(date: Date(), friends: self.friendsFromApp())
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let entry = await SimpleEntry(date: Date(), friends: self.friendsFromApp())
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let friends: ([Friend],[UIImage])
}

struct iosWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    var body: some View {
        if (widgetFamily == .systemLarge) {
            LargeView(entry: entry)
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
        .contentMarginsDisabledIfAvailable()
        .supportedFamilies([.systemMedium,.systemLarge])
        .configurationDisplayName("Spotify Friend Activity")
        .description("See what your friends are listening to, at a glance.")
    }
}
extension WidgetConfiguration
{
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration
    {
        if #available(iOSApplicationExtension 17.0, *)
        {
            return self.contentMarginsDisabled()
        }
        else
        {
            return self
        }
    }
}
