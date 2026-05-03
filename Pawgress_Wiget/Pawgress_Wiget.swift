//
//  Pawgress_Wiget.swift
//  Pawgress_Wiget
//
//  Created by Emma Mazzoni on 4/28/26.
//

import WidgetKit
import SwiftUI

//MARK: - shared data reader
struct PetWidgetData{
    let streak: Int
    let level: Int
    let bodyType: Int
    let earType: Int
    let tailType: Int
    let bodyHue: Double
    let bodySaturation: Double
    let bodyLightness: Double
    let earHue: Double
    let earSaturation: Double
    let earLightness: Double
    let tailHue: Double
    let tailSaturation: Double
    let tailLightness: Double
    let patterns: [Int]
    let patternHues: [Double]
    let patternSaturations: [Double]
    let patternLightnesses: [Double]
    let accessories: [String]
    
    static let placeholder = PetWidgetData(
        streak: 0,
        level: 1,
        bodyType: 1,
        earType: 1,
        tailType: 1,
        bodyHue: 19,
        bodySaturation: 0.42,
        bodyLightness: 0.81,
        earHue: 19,
        earSaturation: 0.42,
        earLightness: 0.81,
        tailHue: 19,
        tailSaturation: 0.42,
        tailLightness: 0.81,
        patterns: [],
        patternHues: [],
        patternSaturations: [],
        patternLightnesses: [],
        accessories: []
    )
    
    static func fromDefaults() -> PetWidgetData {
        let d = UserDefaults(suiteName: "group.edu.psu.ejm6249.Pawgress")
        return PetWidgetData(
            streak: d?.integer(forKey: "streak") ?? 0,
            level: d?.integer(forKey: "level") ?? 1,
            bodyType: d?.integer(forKey: "bodyType") ?? 1,
            earType: d?.integer(forKey: "earType") ?? 1,
            tailType: d?.integer(forKey: "tailType") ?? 1,
            bodyHue: d?.double(forKey: "bodyHue") ?? 19,
            bodySaturation: d?.double(forKey: "bodySaturation") ?? 0.42,
            bodyLightness: d?.double(forKey: "bodyLightness") ?? 0.81,
            earHue: d?.double(forKey: "earHue") ?? 19,
            earSaturation: d?.double(forKey: "earSaturation") ?? 0.42,
            earLightness: d?.double(forKey: "earLightness") ?? 0.81,
            tailHue: d?.double(forKey: "tailHue") ?? 19,
            tailSaturation: d?.double(forKey: "tailSaturation") ?? 0.42,
            tailLightness: d?.double(forKey: "tailLightness") ?? 0.81,
            patterns: d?.array(forKey: "patterns") as? [Int] ?? [],
            patternHues: d?.array(forKey: "patternHues") as? [Double] ?? [],
            patternSaturations: d?.array(forKey: "patternSaturations") as? [Double] ?? [],
            patternLightnesses: d?.array(forKey: "patternLightnesses") as? [Double] ?? [],
            accessories: d?.array(forKey: "accessories") as? [String] ?? []
        )
    }
}

//MARK: - timeline entry
struct PetEntry: TimelineEntry{
    let date: Date
    let petData: PetWidgetData
}

//MARK: - Provider
struct PetWidgetProvider: TimelineProvider{
    func placeholder(in context: Context) -> PetEntry {
        PetEntry(date: .now, petData: .fromDefaults())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PetEntry) -> Void) {
        completion(PetEntry(date: .now, petData: .fromDefaults()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PetEntry>) -> Void) {
        let entry = PetEntry(date: .now, petData: .fromDefaults())
        //refresh once an hour as fallback
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

//MARK: - pet rendering view, mirror pet view
struct WidgetPetView: View {
    let data: PetWidgetData

    var bodyColor: Color { Color(hue: data.bodyHue / 360, saturation: data.bodySaturation, brightness: data.bodyLightness) }
    var earColor: Color  { Color(hue: data.earHue / 360,  saturation: data.earSaturation,  brightness: data.earLightness)  }
    var tailColor: Color { Color(hue: data.tailHue / 360, saturation: data.tailSaturation, brightness: data.tailLightness) }

    var bodyDarker: Color { Color(hue: data.bodyHue/360, saturation: min(data.bodySaturation+0.1,1), brightness: max(data.bodyLightness-0.4,0)) }
    var earDarker: Color  { Color(hue: data.earHue/360,  saturation: min(data.earSaturation+0.1,1),  brightness: max(data.earLightness-0.4,0))  }
    var tailDarker: Color { Color(hue: data.tailHue/360, saturation: min(data.tailSaturation+0.1,1), brightness: max(data.tailLightness-0.4,0)) }

    var body: some View {
        ZStack {
            // TAIL
            ZStack {
                tailColor.mask(Image("tail_base_\(data.tailType)").resizable())
                tailDarker.mask(Image("tail_lines_\(data.tailType)").resizable())
            }

            // BODY
            ZStack {
                bodyColor

                // Patterns
                ForEach(0..<data.patterns.count, id: \.self) { i in
                    let pColor = Color(
                        hue: (data.patternHues.indices.contains(i) ? data.patternHues[i] : data.bodyHue) / 360,
                        saturation: data.patternSaturations.indices.contains(i) ? data.patternSaturations[i] : data.bodySaturation,
                        brightness: data.patternLightnesses.indices.contains(i) ? data.patternLightnesses[i] : data.bodyLightness
                    )
                    pColor.mask(Image("pattern_\(data.patterns[i])").resizable())
                }
            }
            .mask(Image("body_base_\(data.bodyType)").resizable())
            bodyDarker.mask(Image("body_lines_\(data.bodyType)").resizable())

            // EARS
            ZStack {
                earColor.mask(Image("ear_base_\(data.earType)").resizable())
                earDarker.mask(Image("ear_lines_\(data.earType)").resizable())
            }

            // FACE
            Image("face").resizable()

            // ACCESSORIES
            ForEach(data.accessories, id: \.self) { name in
                Image(name).resizable()
            }
        }
    }
}

//MARK: - widget entry view
struct PawgressWidgetEntryView: View{
    var entry: PetEntry
    var body: some View{
        ZStack{
            WidgetPetView(data: entry.petData)
                .scaleEffect(1.8)
                .frame(height: .infinity)
                .offset(x: 8, y:25)
            VStack(spacing: 0){
                Image("fire")
                    .resizable()
                    .frame(width: 60, height: 75)
                    .offset(x: 40, y:-10)
                    .shadow(color: Color("DarkBlue").opacity(0.6), radius: 1, x: -2)

                Text("\(entry.petData.streak)")
                    .font(.custom("Arial Rounded MT Bold", size: 30))
                    .foregroundStyle(Color("DarkBlue"))
                    .offset(x: 40, y:-10)
                    .shadow(color: Color("DarkBlue").opacity(0.3), radius: 1, x: -2)
                    
            }
                
            
        }
        .aspectRatio(285/356, contentMode: .fit)
    }
}

//MARK: - widget def
struct PawgressWidget: Widget{
    let kind: String = "PawgressWidget"
    
    var body: some WidgetConfiguration{
        StaticConfiguration(kind: kind, provider: PetWidgetProvider()) { entry in
                PawgressWidgetEntryView(entry: entry)
                .containerBackground(Color("LightBlue"), for: .widget)
        }
        .configurationDisplayName("Pawgress Pet")
        .description("See your pet and current streak.")
        .supportedFamilies([.systemSmall])
    }
}


#Preview(as: .systemSmall) {
    PawgressWidget()
} timeline: {
    PetEntry(date: .now, petData: .placeholder)
    PetEntry(date: .now, petData: PetWidgetData(
        streak: 7, level: 3,
        bodyType: 1, earType: 2, tailType: 1,
        bodyHue: 200, bodySaturation: 0.6, bodyLightness: 0.8,
        earHue: 200, earSaturation: 0.6, earLightness: 0.8,
        tailHue: 200, tailSaturation: 0.6, tailLightness: 0.8,
        patterns: [], patternHues: [], patternSaturations: [], patternLightnesses: [],
        accessories: []
    ))
}
