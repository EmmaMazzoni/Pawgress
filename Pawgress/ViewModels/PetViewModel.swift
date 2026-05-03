//
//  PetViewModel.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/20/26.
//
import SwiftUI
import SwiftData
import Combine


@MainActor
class PetViewModel: ObservableObject{
    @Published var pet: Pet?
    private var modelContext: ModelContext
    
    //streak manager
    private let streakManager: StreakManager
    
    //track which body part we are sliding
    enum EditTarget{
        case body, ears, tail, pattern
    }
    
    // pop up visability
    @Published var showLevelUp: Bool = false
    @Published var showChallengeComplete: Bool = false
    @Published var lastCompletedChallenge: Challenge?
    @Published var currentLevel: Int = 1
    
    var activeTarget: EditTarget = .body
    var activePatternIndex: Int = 0
    
    init(modelContext: ModelContext){
        self.modelContext = modelContext
        self.streakManager = StreakManager(modelContext: modelContext)
        fetchOrCreatePet()
        self.currentLevel = pet?.level ?? 1
    }
        
    //MARK: - streak logic
    func checkAndRefreshStreak(){
        guard let pet = pet else {return}
        
        streakManager.refreshStreak(for: pet)
        
        //notify UI that pet object changed
        objectWillChange.send()
        
        //save the update streak/lastActivityDate to swiftdata
        try? modelContext.save()
        WidgetDataWriter.write(pet: pet)
        
    }
    
    //MARK: - asset selection
    var bodyImageName: String{"body_base_\(pet?.bodyType ?? 1)"}
    var earImageName: String{"ear_base_\(pet?.earType ?? 1)"}
    var tailImageName: String{"tail_base_\(pet?.tailType ?? 1)"}
    var bodyLinesImageName: String{"body_lines_\(pet?.bodyType ?? 1)"}
    var earLinesImageName: String{"ear_lines_\(pet?.earType ?? 1)"}
    var tailLinesImageName: String{"tail_lines_\(pet?.tailType ?? 1)"}
    
    //MARK: -accessories

    func equippedAccessory(namedLike category: String) -> String? {
        // looks through the pet's accessory array for a specific type
        return pet?.accessories.first(where: { $0.name.contains(category) })?.name
    }
    
    func isUnlocked(category: String, id:Int)->Bool{
        let name = "\(category)_\(id)"
        
        // if its equipped its unlocked
        if pet?.accessories.contains(where: {$0.name==name}) == true {return true}
        
        
        let descriptor = FetchDescriptor<Accessory>(predicate: #Predicate { $0.name == name })
        let found = try? modelContext.fetch(descriptor).first
        return found?.isUnlocked ?? false
    }
    
    func selectAccessory(category: String, id: Int) {
        guard let pet = pet else {return}
        let newName = "\(category)_\(id)"
        
        //check ifthe item is unlocked
        guard isUnlocked(category: category, id: id) else {
            print("Item \(newName) is locked!")
            return
        }
        // Remove existing of same type
        if let existingItems = pet.accessories.filter({$0.name.contains(category)}) as [Accessory]? {
            for item in existingItems{
                if let index = pet.accessories.firstIndex(of: item){
                    pet.accessories.remove(at: index)
                    modelContext.delete(item)
                }
            }
        }
        // Add new
        let newAccessory = Accessory(name: newName, isUnlocked: true)
        pet.accessories.append(newAccessory)
        
        objectWillChange.send()
        try? modelContext.save()
        WidgetDataWriter.write(pet: pet)
    }
    
    // MARK: - Pattern Logic
    func togglePattern(id: Int) {
        guard let pet = pet else { return }
        if let index = pet.patterns.firstIndex(of: id) {
            // remove pattern and its color data
            pet.patterns.remove(at: index)
            pet.patternHues.remove(at: index)
            pet.patternSaturations.remove(at: index)
            pet.patternLightnesses.remove(at: index)
        } else {
            // Add new pattern with default colors (matching body color)
            pet.patterns.append(id)
            pet.patternHues.append(pet.bodyHue)
            pet.patternSaturations.append(pet.bodySaturation)
            pet.patternLightnesses.append(pet.bodyLightness)
        }
    }
    
    //MARK: selection logic
    func select(id: Int, in category: String) {
        guard let pet = pet else { return }
        
        switch category {
            // 1. Body Part Logic (Direct Int update)
        case "body":
            pet.bodyType = id
            activeTarget = .body
        case "ear":
            pet.earType = id
            activeTarget = .ears
        case "tail":
            pet.tailType = id
            activeTarget = .tail
            
            // 2. Pattern Logic (Toggle system)
        case "pattern":
            togglePattern(id: id)
            activeTarget = .pattern
            // Set the slider to control the pattern we just touched
            if let index = pet.patterns.firstIndex(of: id) {
                activePatternIndex = index
            }
            
            // accessory Logic (Array management)
        case "hat", "collar", "back":
            let newName = "\(category)_\(id)"
            // check if we are tapping the accessory we already have on
            if equippedAccessory(namedLike: category) == newName{
                //remove it
                if let itemToRemove = pet.accessories.first(where: {$0.name == newName}){
                    pet.accessories.removeAll(where: {$0.name == newName})
                    modelContext.delete(itemToRemove)
                }
                pet.accessories.removeAll(where: {$0.name.contains(category)})
            } else {
                selectAccessory(category: category, id: id)
            }
            
        default:
            break
        }
        WidgetDataWriter.write(pet: pet)
    }
    
    //MARK: - color logic
    var bodyColor: Color {
        Color(hue: (pet?.bodyHue ?? 0) / 360, saturation: pet?.bodySaturation ?? 1, brightness: pet?.bodyLightness ?? 1)
    }
    
    var earColor: Color {
        Color(hue: (pet?.earHue ?? 0) / 360, saturation: pet?.earSaturation ?? 1, brightness: pet?.earLightness ?? 1)
    }
    
    var tailColor: Color {
        Color(hue: (pet?.tailHue ?? 0) / 360, saturation: pet?.tailSaturation ?? 1, brightness: pet?.tailLightness ?? 1)
    }
    
    // line colors
    var bodyColorDarker: Color {
        Color(hue: (pet?.bodyHue ?? 0)/360,
              saturation: min((pet?.bodySaturation ?? 0) + 0.1, 1.0),
              brightness: max((pet?.bodyLightness ?? 0) - 0.4, 0.0))
    }
    
    var earColorDarker: Color {
        Color(hue: (pet?.earHue ?? 0)/360,
              saturation: min((pet?.earSaturation ?? 0) + 0.1, 1.0),
              brightness: max((pet?.earLightness ?? 0) - 0.4, 0.0))
    }
    
    var tailColorDarker: Color {
        Color(hue: (pet?.tailHue ?? 0)/360,
              saturation: min((pet?.tailSaturation ?? 0) + 0.1, 1.0),
              brightness: max((pet?.tailLightness ?? 0) - 0.4, 0.0))
    }
    
    //sync all colors
    func syncAllColors(){
        guard let pet = pet else{return }
        
        //capture the color we are on
        let sourceHue: Double
        let sourceSat: Double
        let sourceLight: Double
        
        switch activeTarget{
        case .body:
            sourceHue = pet.bodyHue
            sourceSat = pet.bodySaturation
            sourceLight = pet.bodyLightness
        case .ears:
            sourceHue = pet.earHue
            sourceSat = pet.earSaturation
            sourceLight = pet.earLightness
        case .tail:
            sourceHue = pet.tailHue
            sourceSat = pet.tailSaturation
            sourceLight = pet.tailLightness
        case .pattern:
            sourceHue = pet.patternHues.indices.contains(activePatternIndex) ? pet.patternHues[activePatternIndex] : pet.bodyHue
            sourceSat = pet.patternSaturations.indices.contains(activePatternIndex) ? pet.patternSaturations[activePatternIndex] : pet.bodySaturation
            sourceLight = pet.patternLightnesses.indices.contains(activePatternIndex) ? pet.patternLightnesses[activePatternIndex] : pet.bodyLightness
        }
        
        // conditional logic: if on body part matches all of those but for patterns matches all patterns
        if activeTarget == .pattern{
            for i in 0..<pet.patternHues.count{
                pet.patternHues[i] = sourceHue
                pet.patternSaturations[i] = sourceSat
                pet.patternLightnesses[i] = sourceLight
            }
        } else {
            //apply to EVERY part
            pet.bodyHue = sourceHue
            pet.bodySaturation = sourceSat
            pet.bodyLightness = sourceLight
            
            pet.earHue = sourceHue
            pet.earSaturation = sourceSat
            pet.earLightness = sourceLight
            
            pet.tailHue = sourceHue
            pet.tailSaturation = sourceSat
            pet.tailLightness = sourceLight
        }
        
        objectWillChange.send()
        
    }
    
    //MARK: - unit conversions, for colors
    var currentHue: Double{
        get{
            guard let pet = pet else {return 0}
            switch activeTarget {
            case .body:
                return pet.bodyHue
            case .ears:
                return pet.earHue
            case .tail:
                return pet.tailHue
            case .pattern:
                return (pet.patternHues.indices.contains(activePatternIndex) ? pet.patternHues[activePatternIndex] : 0)
                
            }
        }
        set {
            switch activeTarget {
            case .body:
                pet?.bodyHue = newValue
            case .ears:
                pet?.earHue = newValue
            case .tail:
                pet?.tailHue = newValue
            case .pattern:
                if pet?.patternHues.indices.contains(activePatternIndex) == true {
                    pet?.patternHues[activePatternIndex] = newValue
                }
            }
        }
    }
    
    var currentSaturation: Double{
        get{
            guard let pet = pet else {return 0}
            switch activeTarget {
            case .body:
                return pet.bodySaturation
            case .ears:
                return pet.earSaturation
            case .tail:
                return pet.tailSaturation
            case .pattern:
                return pet.patternSaturations.indices.contains(activePatternIndex) ? pet.patternSaturations[activePatternIndex] : 1.0
            }
        }
        set {
            switch activeTarget {
            case .body:
                pet?.bodySaturation = newValue
            case .ears:
                pet?.earSaturation = newValue
            case .tail:
                pet?.tailSaturation = newValue
            case .pattern:
                if pet?.patternSaturations.indices.contains(activePatternIndex) == true {
                    pet?.patternSaturations[activePatternIndex] = newValue
                }
            }
        }
    }
    
    var currentLightness: Double{
        get{
            guard let pet = pet else {return 0}
            switch activeTarget {
            case .body:
                return pet.bodyLightness
            case .ears:
                return pet.earLightness
            case .tail:
                return pet.tailLightness
            case .pattern:
                return pet.patternLightnesses.indices.contains(activePatternIndex) ? pet.patternLightnesses[activePatternIndex] : 1.0
                
            }
        }
        set {
            switch activeTarget {
            case .body:
                pet?.bodyLightness = newValue
            case .ears:
                pet?.earLightness = newValue
            case .tail:
                pet?.tailLightness = newValue
            case .pattern:
                if pet?.patternLightnesses.indices.contains(activePatternIndex) == true {
                    pet?.patternLightnesses[activePatternIndex] = newValue
                }
            }
        }
    }
    
    //MARK: - data management
    private func fetchOrCreatePet() {
        let descriptor = FetchDescriptor<Pet>()
        
        // Use a do-catch to handle potential context issues safely
        do {
            if let foundPet = try modelContext.fetch(descriptor).first {
                self.pet = foundPet
            } else {
                let newPet = Pet(name: "My Pet")
                modelContext.insert(newPet)
                // Save immediately to move it from a 'temporary' ID to a 'permanent' one
                try? modelContext.save()
                self.pet = newPet
            }
            if let pet = self.pet{
                WidgetDataWriter.write(pet: pet)
            }
        } catch {
            print("Fetch failed: \(error)")
        }
        
        
    }
}
