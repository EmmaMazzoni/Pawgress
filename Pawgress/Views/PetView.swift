//
//  PetView.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/15/26.
//
import SwiftUI
import SwiftData

struct PetView: View{
    @State var viewModel: PetViewModel
    @State var showHearts: Bool = false
    @State var heartScale: CGFloat = 0.1
    
    var body: some View {
        
        //MARK: - Pet itself
        ZStack{
            
            //SHADOW
            VStack{
                Spacer()
                Image("dog_shadow")
                    .resizable()
                    .frame(width:274, height: 17)
            }
            
            HeartPopup()
                .opacity(showHearts ? 1 : 0)
                .scaleEffect(showHearts ? 1.4 : 0.6)
                .animation(.spring(response: 0.35, dampingFraction: 0.45), value: showHearts)
            //MARK: back accessories
            if let back = viewModel.equippedAccessory(namedLike: "back") {
                Image(back)
                    .resizable()
            }
            
            
            //MARK: BODY
            ZStack{
                viewModel.bodyColor
                
                if let pet = viewModel.pet {
                    ForEach(0..<pet.patterns.count, id: \.self) { i in
                        let pColor = Color(hue: pet.patternHues[i]/360,saturation: pet.patternSaturations[i], brightness: pet.patternLightnesses[i])
                                        
                            // Mask the color to the pattern shape
                            pColor.mask(Image("pattern_\(pet.patterns[i])").resizable())
                    }
                }
            }
            .mask(Image(viewModel.bodyImageName).resizable())
            viewModel.bodyColorDarker
                .mask(Image(viewModel.bodyLinesImageName).resizable())
            
            //MARK: TAIL
            ZStack{
                viewModel.tailColor.mask(Image(viewModel.tailImageName).resizable())
                viewModel.tailColorDarker.mask(Image(viewModel.tailLinesImageName).resizable())
            }
            
            //MARK: EARS
            ZStack{
                viewModel.earColor.mask(Image(viewModel.earImageName).resizable())
                viewModel.earColorDarker.mask(Image(viewModel.earLinesImageName).resizable())
            }
            
            //MARK: FACE
            Image(showHearts ? "happy_face" : "face").resizable()
            
            //MARK: foreground accessories
            if let hat = viewModel.equippedAccessory(namedLike: "hat") {
                Image(hat)
                    .resizable()
            }
                        
            if let collar = viewModel.equippedAccessory(namedLike: "collar") {
                Image(collar)
                    .resizable()
            }

        }
        .frame(width: 285, height: 356)
        .onTapGesture {
            showHearts = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showHearts = false
            }
        }
        .padding(0)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Pet.self, Accessory.self, configurations: config)
    
    // Create the VM on the MainActor
    let viewModel = PetViewModel(modelContext: container.mainContext)
    
    return PetView(viewModel: viewModel)
        .modelContainer(container) // Pass the container into the environment
}
