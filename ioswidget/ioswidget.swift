//
//  iosWidget.swift
//  iosWidget
//
//  Created by Avi Wadhwa on 2022-04-25.
//

import WidgetKit
import SwiftUI
import KeychainAccess
//import Kingfisher
//import SwiftKeychainWrapper

struct Provider: TimelineProvider {
    var friendArray : [Friend]?
    func fetch<T: Decodable>(urlString: String, httpValue: String, httpField: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(httpValue, forHTTPHeaderField: httpField)
        // URLSession.shared.configuration =
         let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONDecoder().decode(T.self, from: data)
        return json
    }

    func GetFriendActivityWidget() async -> ([Friend],[UIImage], String?) {
        let keychain = Keychain(service: "aviwad.Friend-Activity-for-Spotify", accessGroup: "38TP6LZLJ5.sharing")
            .accessibility(.afterFirstUnlock)
        let accessToken = try? keychain.get("accessToken")
        //let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        if (accessToken != nil) {
            let friendArrayInitial: Welcome
            do {
                friendArrayInitial = try await fetchJson()
                //friendArrayInitial = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken.unsafelyUnwrapped)", httpField: "Authorization")
                 print("testing123: friendarrayinitial")
                let friendArray = Array(friendArrayInitial.friends.reversed().prefix(4))
                var imageArray : [UIImage] = []
                for friend in friendArray {
                    if (friend.user.imageURL.isEmpty) {
                        imageArray.append(UIImage(systemName: "person.fill")!)
                    } else {
                        imageArray.append(UIImage(data: try! Data.ReferenceType(contentsOf: URL(string: friend.user.imageURL)!) as Data)!)
                    }
                }
                return (friendArray,imageArray,nil)
                 //youHaveNoFriends = false
                
                 //WidgetCenter.shared.reloadAllTimelines()
            }
            catch {
                return await GetFriendActivityWidgetWithNewToken()
                //print(error)
                //return ([],[],error.localizedDescription)
            }
        }
        return ([],[],nil)
    }
    
    func fetchJson() async throws -> Welcome {
        let decoder = JSONDecoder()
        let path = Bundle.main.path(forResource: "sampleFriendList", ofType: "json")
        let data = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        let friendList = try? decoder.decode(Welcome.self, from: data)
        return friendList!
    }

    func GetFriendActivityWidgetWithNewToken() async -> ([Friend],[UIImage],String?) {
        let keychain = Keychain(service: "aviwad.Friend-Activity-for-Spotify", accessGroup: "38TP6LZLJ5.sharing")
            .accessibility(.afterFirstUnlock)
        //let accessToken = try? keychain.get("accessToken")
        let spDcCookie = try? keychain.get("spDcCookie")
        //let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        if (spDcCookie != nil) {
            let friendArrayInitial: Welcome
            do {
                let accessToken: accessTokenJSON =  try await fetch(urlString: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player", httpValue: "sp_dc=\(spDcCookie.unsafelyUnwrapped)", httpField: "Cookie")
                keychain["accessToken"] = accessToken.accessToken
                friendArrayInitial = try await fetchJson()
                //friendArrayInitial = try await fetch(urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist", httpValue: "Bearer \(accessToken.accessToken)", httpField: "Authorization")
                 print("testing123: friendarrayinitial")
                let friendArray = Array(friendArrayInitial.friends.reversed().prefix(4))
                var imageArray : [UIImage] = []
                for friend in friendArray {
                    if (friend.user.imageURL.isEmpty) {
                        imageArray.append(UIImage(systemName: "person.fill")!)
                    } else {
                        imageArray.append(UIImage(data: try! Data.ReferenceType(contentsOf: URL(string: friend.user.imageURL)!) as Data)!)
                    }
                }
                return (friendArray,imageArray,nil)
                 //youHaveNoFriends = false
                
                 //WidgetCenter.shared.reloadAllTimelines()
            }
            catch {
                print(error)
                return ([],[],error.localizedDescription)
            }
        }
        return ([],[],nil)
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), friends: ([],[UIImage(systemName: "person.fill")!,UIImage(systemName: "person.fill")!,UIImage(systemName: "person.fill")!,UIImage(systemName: "person.fill")!],nil))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Task {
            let entry = await SimpleEntry(date: Date(), friends: self.GetFriendActivityWidget())
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let entry = await SimpleEntry(date: Date(), friends: self.GetFriendActivityWidget())
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let friends: ([Friend],[UIImage], String?)
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
        .supportedFamilies([.systemMedium,.systemLarge])
        .configurationDisplayName("Friend Activity")
        .description("See what your friends are listening to at a glance.")
    }
}
