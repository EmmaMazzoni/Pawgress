//
//  Challenge.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/17/26.
//
import SwiftData
import Foundation

enum ChallengeType: String, Codable {
    case prCount
    case workoutCount
    case foodLog
    case hydration
    case streak
}

@Model
class Challenge{
    var title: String
    var descriptionText: String?
    var type: ChallengeType
    var progress: Int
    var goal: Int               //amount of TYPE you want
    
    var isCompleted: Bool = false
    var xpReward: Int
    
    var badge: Badge?
    var accessoryReward: Accessory?
    
    init(
        title: String,
        descriptionText: String = "",
        type: ChallengeType,
        goal: Int,
        xpReward: Int,
        badge: Badge? = nil,
        accessoryReward: Accessory? = nil
    ) {
        self.title = title
        self.descriptionText = descriptionText
        self.type = type
        self.goal = goal
        self.xpReward = xpReward
        self.badge = badge
        self.accessoryReward = accessoryReward
        self.progress = 0
        self.isCompleted = false
    }
}

@Model
class Badge{
    var name: String
    var dateEarned: Date?
    var imageName: String
    
    init(name: String, dateEarned: Date? = nil, imageName: String) {
        self.name = name
        self.dateEarned = dateEarned
        self.imageName = imageName
    }
}
