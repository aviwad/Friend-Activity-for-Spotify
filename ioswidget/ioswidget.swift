//
//  iosWidget.swift
//  iosWidget
//
//  Created by Avi Wadhwa on 2022-04-25.
//

import WidgetKit
import SwiftUI
import KeychainAccess
import Intents
import SDWebImage

struct Provider: IntentTimelineProvider {
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
    
    private func entryForPlaceholder(friends: [Friend]) -> ([Friend],[UIImage],Bool) {
        let friends = Array(friends.prefix(4))
        let images = [UIImage(named: "person.png")!,UIImage(named: "person.png")!,UIImage(named: "person.png")!,UIImage(named: "person.png")!]
        return (friends,images,false)
    }
    
    private func entryFromFriends(friends: [Friend], config: SelectFriendsConfigIntent) -> ([Friend],[UIImage],Bool) {
        let friendArray = {
            if let selectedFriends = config.friends, config.showAll?.boolValue == false {
                return friends.filter { friend in
                    selectedFriends.contains { configFriend in
                        configFriend.identifier == friend.id
                    }
                }
            }
            return Array(friends.prefix(4))
        }()
        var imageArray : [UIImage] = []
        for friend in friendArray {
            let key = SDWebImageManager.shared.cacheKey(for: friend.user.imageURL)
            if let image = SDImageCache.shared.imageFromDiskCache(forKey: key) {
                imageArray.append(image)
            }
            else {
                imageArray.append(UIImage(named: "person.png")!)
            }
        }
        return (friendArray,imageArray, config.showAll?.boolValue == false)
    }
    
    func friendsFromApp(_ configuration: SelectFriendsConfigIntent) async -> ([Friend],[UIImage],Bool){
        SDImageCache.defaultDiskCacheDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")?.appendingPathComponent("SDImageCache").path
        let lastUpdated = UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")!.integer(forKey: "lastSavedTime")
        print(lastUpdated.distance(to: Int(CACurrentMediaTime())))
        if (lastUpdated.distance(to: Int(CACurrentMediaTime())) > 300) {
            // query online
            return await GetFriends(configuration)
        }
        let encodedData  = UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")!.object(forKey: "friendArray") as? Data
        /* Decoding it using JSONDecoder */
        if let friendEncoded = encodedData, let friendDecoded = try? JSONDecoder().decode([Friend].self, from: friendEncoded) {
            return entryFromFriends(friends: friendDecoded, config: configuration)
        }
        return ([],[],false)
    }
    
    func GetFriends(_ configuration: SelectFriendsConfigIntent) async -> ([Friend],[UIImage],Bool){
        guard let cookie = UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")?.string(forKey: "spDcCookie") else {
            // error
            return ([],[],false)
        }
        do {
            let accessTokenJson: accessTokenJSON = try await fetch(urlString: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player", httpValue: "sp_dc=\(cookie)", httpField: "Cookie", getOrPost: .get)
            let accessToken:String = accessTokenJson.accessToken
            do {
                print("access token ")
                let friendArrayInitial: Welcome = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken)", httpField: "Authorization", getOrPost: .get)
                return entryFromFriends(friends: friendArrayInitial.friends, config: configuration)
            }
            catch {
                return ([],[],false)
            }
        }
        catch {
            print("error for token")
            print(error)
            return ([],[],false)
            // NOTIFICATION THAT ERROR OCCURRED
        }

    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        let encodedData  = UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")!.object(forKey: "friendArray") as? Data
        /* Decoding it using JSONDecoder*/
        if let friendEncoded = encodedData, let friendDecoded = try? JSONDecoder().decode([Friend].self, from: friendEncoded) {
            return SimpleEntry(date: .now, friends: entryForPlaceholder(friends: friendDecoded))
        }
        return SimpleEntry(date: Date(), friends: ([],[],false))
    }
    
    func getSnapshot(for configuration: SelectFriendsConfigIntent, in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        Task {
            let entry = await SimpleEntry(date: Date(), friends: self.friendsFromApp(configuration))
            completion(entry)
        }
    }
    
    func getTimeline(for configuration: SelectFriendsConfigIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        Task {
            let entry = await SimpleEntry(date: Date(), friends: self.friendsFromApp(configuration))
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }

}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let friends: ([Friend],[UIImage],Bool)
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
        IntentConfiguration(kind: kind, intent: SelectFriendsConfigIntent.self, provider: Provider()) { entry in
            if #available(iOSApplicationExtension 17.0, *) {
                iosWidgetEntryView(entry: entry)
                .transition(.push(from: .bottom))
            } else {
                iosWidgetEntryView(entry: entry)
            }
            
        }
        .contentMarginsDisabled()
        .supportedFamilies([.systemMedium,.systemLarge])
        .configurationDisplayName("Spotify Friend Activity")
        .description("See what your friends are listening to, at a glance.")
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
