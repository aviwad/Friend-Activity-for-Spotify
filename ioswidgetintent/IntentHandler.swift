//
//  IntentHandler.swift
//  ioswidgetintent
//
//  Created by Avi Wadhwa on 20/07/23.
//

import Intents
import IntentsUI
import SDWebImage

class IntentHandler: INExtension, SelectFriendsConfigIntentHandling {
    func provideFriendsOptionsCollection(for intent: SelectFriendsConfigIntent) async throws -> INObjectCollection<ConfigFriend> {
        let encodedData  = UserDefaults(suiteName: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")!.object(forKey: "friendArray") as? Data
        if let friendEncoded = encodedData, let friendDecoded = try? JSONDecoder().decode([Friend].self, from: friendEncoded) {
            let friends = friendDecoded.map { friend in
                let image: INImage = {
                    SDImageCache.defaultDiskCacheDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.38TP6LZLJ5.aviwad.Friend-Activity-for-Spotify")?.appendingPathComponent("SDImageCache").path
                    let key = SDWebImageManager.shared.cacheKey(for: friend.user.imageURL)
                    if let image = SDImageCache.shared.imageFromDiskCache(forKey: key) {
                        return INImage(uiImage: image)
                    }
                    return INImage(named: "person.png")
                }()
                let configFriend = ConfigFriend(identifier: friend.id, display: friend.user.name, subtitle: nil, image: image)
                return configFriend
            }
            let collection = INObjectCollection(items: friends)
            return collection
        }
        return INObjectCollection(items: [])
    }
    
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
