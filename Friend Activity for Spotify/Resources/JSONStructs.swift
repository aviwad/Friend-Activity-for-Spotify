//
//  StructsForJSON.swift
//  SpotPlayerFriendActivity
//
//  Created by Avi Wadhwa on 2022-04-16.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

// access token json
struct accessTokenJSON: Codable {
    let accessToken: String
    let isAnonymous: Bool
}

// getfriendactivity: error struct

/*struct ErrorContainer: Codable {
    let error: [Error]
}

struct Error: Codable {
    let status: Int
    let message: String
}*/

// MARK: - Welcome
struct Welcome: Codable {
    let friends: [Friend]
}

// MARK: - Friend
struct Friend: Codable, Identifiable     {
    let humanTimestamp : (humanTimestamp: String, nowOrNot: Bool) //{timePlayer(initialTimeStamp: timestamp)}
    let timestamp: Int
    let user: User
    let track: Track
    let id : String
    //let id = self.user
    
    struct Track: Codable {
        let uri, name: String
        let url: URL
        let imageURL: String
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
            self.imageURL = try container.decode(String.self, forKey: .imageURL)
            self.album = try container.decode(Friend.Album.self, forKey: .album)
            self.artist = try container.decode(Friend.Album.self, forKey: .artist)
            self.context = try container.decode(Friend.Context.self, forKey: .context)
            self.url = getSpotifyUrl(initialUrl: self.uri)
        }
        
        
        /*enum CodingKeys: String, CodingKey {
            case uri, name
            case imageURL = "imageUrl"
            case album, artist, context
        }*/
    }
    
    struct Album: Codable {
        let uri, name: String
        let url: URL
        
        
        private enum CodingKeys: String, CodingKey {
            case uri, name
            // case url
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.uri = try container.decode(String.self, forKey: .uri)
            self.name = try container.decode(String.self, forKey: .name)
            self.url = getSpotifyUrl(initialUrl: self.uri)
        }
    }
    
    struct Context: Codable {
        let uri, name: String
        let index: Int
        let url: URL
        //var url: URL {getSpotifyUrl(initialUrl: uri)}
        
        private enum CodingKeys: String, CodingKey {
            case uri, name
            case index
            // case url
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.uri = try container.decode(String.self, forKey: .uri)
            self.name = try container.decode(String.self, forKey: .name)
            self.index = try container.decode(Int.self, forKey: .index)
            self.url = getSpotifyUrl(initialUrl: self.uri)
        }
    }
    struct User: Codable {
        let uri, name: String
        let imageURL: String
        let url: URL
        //var url: URL {getSpotifyUserUrl(initialUrl: uri)}

        private enum CodingKeys: String, CodingKey {
            case uri,name
            case imageURL = "imageUrl"
            // case url
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.uri = try container.decode(String.self, forKey: .uri)
            self.name = try container.decode(String.self, forKey: .name)
            if let imageUrl = try container.decodeIfPresent(String.self, forKey: .imageURL) {
                  self.imageURL = imageUrl
              }
            else {
                self.imageURL = ""
            }
            //self.imageURL = try container.decode(String.self, forKey: .imageURL)
            self.url = getSpotifyUrl(initialUrl: self.uri)
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
        self.id = self.user.name
    }
    
    
}

// MARK: - WelcomeError
struct WelcomeError: Codable {
    let error: Error
}

// MARK: - Error
struct Error: Codable {
    let status: Int
    let message: String
}
