//
//  iosWidget.swift
//  iosWidget
//
//  Created by Avi Wadhwa on 2022-04-25.
//

import WidgetKit
import SwiftUI
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
        if (lastUpdated.distance(to: Int(CACurrentMediaTime())) > 600) {
            // query online
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
    
    func GetFriends(_ DownloadAlbumArt: Bool = false, _ pickFavorite: Bool = false) async -> ([Friend],[UIImage],UIImage?){
        guard let cookie = UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")?.string(forKey: "spDcCookie") else {
            // error
            return ([],[],nil)
        }
        do {
            let accessTokenJson: accessTokenJSON = try await fetch(urlString: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player", httpValue: "sp_dc=\(cookie)", httpField: "Cookie", getOrPost: .get)
            let accessToken:String = accessTokenJson.accessToken
            do {
                print("access token ")
                let friendArrayInitial: Welcome = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken)", httpField: "Authorization", getOrPost: .get)
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
                .accessoryRectangular,
                
            ])
        } else {
            return self.supportedFamilies([
                .systemSmall,
                .systemMedium,
                .systemSmall
            ])
        }
    }
}
