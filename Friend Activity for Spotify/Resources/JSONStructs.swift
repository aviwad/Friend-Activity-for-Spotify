//
//  StructsForJSON.swift
//  SpotPlayerFriendActivity
//
//  Created by Avi Wadhwa on 2022-04-16.
//

import Foundation

// access token json
struct accessTokenJSON: Codable {
    let accessToken: String
    let isAnonymous: Bool
}


// MARK: - Welcome
struct Welcome: Codable {
    let friends: [Friend]
}

// MARK: - Friend
struct Friend: Codable, Identifiable {
    let humanTimestamp : (humanTimestamp: String, nowOrNot: Bool) //{timePlayer(initialTimeStamp: timestamp)}
    let timestamp: Int
    let user: User
    let track: Track
    let id : String

    struct Track: Codable, Identifiable {
        let id: String
        let uri, name: String
        let url: URL
        let imageURL: URL?
        let album, artist: Album
        let context: Context

        
        enum CodingKeys: String, CodingKey {
            case uri, name
            //case url
            case imageURL = "imageUrl"
            case album, artist
            case context
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.uri = try container.decode(String.self, forKey: .uri)
            self.name = try container.decode(String.self, forKey: .name)
            self.imageURL = try {
                if let imageUrl = try container.decodeIfPresent(String.self, forKey: .imageURL) {
                    return URL(string: "https" + imageUrl.dropFirst(4))
                }
                return nil
            }()
            self.album = try container.decode(Friend.Album.self, forKey: .album)
            self.artist = try container.decode(Friend.Album.self, forKey: .artist)
            self.context = try container.decode(Friend.Context.self, forKey: .context)
            self.url = getSpotifyUrl(initialUrl: self.uri)
            self.id = self.uri
        }
    }
    
    struct Album: Codable, Identifiable {
        let uri, name: String
        let url: URL
        let id: String
        
        
        private enum CodingKeys: String, CodingKey {
            case uri, name
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.uri = try container.decode(String.self, forKey: .uri)
            self.name = try container.decode(String.self, forKey: .name)
            self.url = getSpotifyUrl(initialUrl: self.uri)
            self.id = self.uri
        }
    }
    
    struct Context: Codable, Identifiable {
        let uri, name: String
        let index: Int
        let url: URL
        let id: String
        
        private enum CodingKeys: String, CodingKey {
            case uri, name
            case index
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.uri = try container.decode(String.self, forKey: .uri)
            self.name = try container.decode(String.self, forKey: .name)
            self.index = try container.decode(Int.self, forKey: .index)
            self.url = getSpotifyUrl(initialUrl: self.uri)
            self.id = self.uri
        }
    }
    struct User: Codable, Identifiable {
        let uri, name: String
        let imageURL: URL?
        let url: URL
        let id: String

        private enum CodingKeys: String, CodingKey {
            case uri,name
            case imageURL = "imageUrl"
            // case url
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.uri = try container.decode(String.self, forKey: .uri)
            self.name = try container.decode(String.self, forKey: .name)
            self.imageURL = try {
                if let imageUrl = try container.decodeIfPresent(String.self, forKey: .imageURL) {
                    return URL(string: imageUrl)
                }
                return nil
            }()
            self.url = getSpotifyUserUrl(initialUrl: self.uri)
            self.id = self.uri
        }
    }
    
    enum CodingKeys: String, CodingKey {
        //case humanTimestamp
        case timestamp
        case user
        case track
        // case id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.timestamp = try container.decode(Int.self, forKey: .timestamp)
        self.user = try container.decode(Friend.User.self, forKey: .user)
        self.track = try container.decode(Friend.Track.self, forKey: .track)
        self.humanTimestamp = timePlayer(initialTimeStamp: self.timestamp)
        self.id = self.user.uri
    }
    
    
}

struct TokenError: Codable {
    let status: Int
    let message: String
}
struct ErrorWrapper: Codable {
    let error: TokenError
}

enum GetOrPost {
    case get,post
}
