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
    var humanTimestamp: (humanTimestamp: String, nowOrNot: Bool) {timePlayer(initialTimeStamp: timestamp)}
    let timestamp: Int
    let user: User
    let track: Track
    var id: String {user.name}
    //let id = self.user
    
    struct Track: Codable {
        let uri, name: String
        var url: URL {getSpotifyUrl(initialUrl: uri)}
        let imageURL: String
        let album, artist: Album
        let context: Context

        enum CodingKeys: String, CodingKey {
            case uri, name
            case imageURL = "imageUrl"
            case album, artist, context
        }
    }
    
    struct Album: Codable {
        let uri, name: String
        var url: URL {getSpotifyUrl(initialUrl: uri)}
    }
    
    struct Context: Codable {
        let uri, name: String
        let index: Int
        var url: URL {getSpotifyUrl(initialUrl: uri)}
    }
    struct User: Codable {
        let uri, name: String
        let imageURL: String
        var url: URL {getSpotifyUserUrl(initialUrl: uri)}
        //var image: AsyncImage<Image>

        enum CodingKeys: String, CodingKey {
            case uri, name
            case imageURL = "imageUrl"
            //case image
        }
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
