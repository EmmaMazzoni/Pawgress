//
//  Pet.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/17/26.
//

import SwiftData
import Foundation

@Model
class Pet{
    var name: String
    var level: Int
    var xp: Int
    
    //STREAK LOGIC
    var currentStreak: Int = 0
    var lastActiveDate: Date?
    
    //APPEARANCE
    
    //ears
    var earType: Int
    var earHue: Double
    var earSaturation: Double
    var earLightness: Double
    
    //tail
    var tailType: Int
    var tailHue: Double
    var tailSaturation: Double
    var tailLightness: Double
    
    //body
    var bodyType: Int
    var bodyHue: Double
    var bodySaturation: Double
    var bodyLightness: Double
    
    //patterns
    var patterns: [Int] = []
    var patternHues: [Double] = []
    var patternSaturations: [Double] = []
    var patternLightnesses: [Double] = []
    
    //accessories
    var accessories: [Accessory] = []
    
    init(name: String)
    {
        self.name = name
        self.level = 1
        self.xp = 0
        
        //ears
        self.earType = 1
        self.earHue = 19.0
        self.earSaturation = 0.42
        self.earLightness = 0.81
        
        //tail
        self.tailType = 1
        self.tailHue = 19.0
        self.tailSaturation = 0.42
        self.tailLightness = 0.81
        
        //body
        self.bodyType = 1
        self.bodyHue = 19.0
        self.bodySaturation = 0.42
        self.bodyLightness = 0.81
        
    }
}

@Model
class Accessory{
    var name: String
    var isUnlocked: Bool
    
    init(name: String, isUnlocked: Bool) {
        self.name = name
        self.isUnlocked = isUnlocked
    }
}
