//
//  WidgetDataWriter.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/28/26.
//
import WidgetKit
import Foundation

struct WidgetDataWriter{
    static let suiteName = "group.edu.psu.ejm6249.Pawgress"
    
    static func write(pet: Pet) {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        defaults.set(pet.currentStreak, forKey: "streak")
        defaults.set(pet.level, forKey: "level")
        // Appearance for rendering the pet
        defaults.set(pet.bodyType, forKey: "bodyType")
        defaults.set(pet.earType, forKey: "earType")
        defaults.set(pet.tailType, forKey: "tailType")
        defaults.set(pet.bodyHue, forKey: "bodyHue")
        defaults.set(pet.bodySaturation, forKey: "bodySaturation")
        defaults.set(pet.bodyLightness, forKey: "bodyLightness")
        defaults.set(pet.earHue, forKey: "earHue")
        defaults.set(pet.earSaturation, forKey: "earSaturation")
        defaults.set(pet.earLightness, forKey: "earLightness")
        defaults.set(pet.tailHue, forKey: "tailHue")
        defaults.set(pet.tailSaturation, forKey: "tailSaturation")
        defaults.set(pet.tailLightness, forKey: "tailLightness")
        defaults.set(pet.patterns, forKey: "patterns")
        defaults.set(pet.patternHues, forKey: "patternHues")
        defaults.set(pet.patternSaturations, forKey: "patternSaturations")
        defaults.set(pet.patternLightnesses, forKey: "patternLightnesses")
        // accessories (just names)
        let accessoryNames = pet.accessories.map { $0.name }
        defaults.set(accessoryNames, forKey: "accessories")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
