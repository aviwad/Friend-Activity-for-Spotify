//
//  getTime.swift
//  SpotPlayerFriendActivitytest
//
//  Created by Avi Wadhwa on 2022-04-24.
//

import Foundation

func timePlayer(initialTimeStamp: Int) -> (humanTimestamp: String, nowOrNot: Bool) {
    let timeStamp = Int(abs(Date.init(timeIntervalSince1970: TimeInterval((initialTimeStamp/1000))).timeIntervalSinceNow)/60)
    var timeString: String
    var nowOrNot = false
    if (timeStamp > (24 * 60)) {
        timeString = "\(timeStamp / (24 * 60)) d"
    }
    else if (timeStamp > 60){
        timeString = "\(timeStamp / 60) hr"
    }
    else if (timeStamp > 5){
        timeString = "\(timeStamp) m"
    }
    else{
        timeString = "now"; nowOrNot = true
    }
    return (timeString, nowOrNot)

}
