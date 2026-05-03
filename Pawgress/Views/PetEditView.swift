//
//  PetEditView.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/12/26.
//
import SwiftUI
import SwiftData

struct PetEditView: View {
    
    enum TopTab{
        case accessory
        case body
    }
    
    @State private var viewModel: PetViewModel
    
    init(modelContext: ModelContext){
        _viewModel = State(initialValue: PetViewModel(modelContext: modelContext))
    }
    
    @State private var selectedTab: TopTab = .accessory
    
    var body: some View {
        ZStack(alignment: .top){
            Color("Cream")
                .ignoresSafeArea()
            VStack{
                //MARK: - TopNav
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color("LightBlue").opacity(0.5))
                        .shadow(color: Color("Peach").opacity(0.3), radius: 1, x: 3, y: 3)
                    
                    // Navigate to accessories edit
                    HStack(spacing: 30){
                        Button(action:{
                            withAnimation{
                                selectedTab = .accessory
                            }
                        }){
                            Image(systemName: "hanger")
                                .font(.system(size: 45))
                                .foregroundStyle(selectedTab == .accessory ? Color("DarkBlue") : Color("DarkBlue").opacity(0.6))
                        }
                        
                        //navigate to body edit (patterns, colors, hair etc.)
                        
                        Button(action:{
                            withAnimation{
                            selectedTab = .body
                        }
                        }){
                            Image(systemName: "paintbrush.pointed.fill")
                                .font(.system(size: 45))
                                .rotationEffect(.degrees(180))
                                .foregroundStyle(selectedTab == .body ? Color("DarkBlue") : Color("DarkBlue").opacity(0.6))
                        }
                    }
                }
                .frame(width: 305, height: 67)
                
                //MARK: -  Pet itself
                PetView(viewModel: viewModel)
                
                Spacer()
                    .frame(height: 30)
                
                if selectedTab == .accessory{
                    PetAccessories(viewModel: viewModel)
                } else if selectedTab == .body{
                    PetBody(viewModel: viewModel)
                } else{
                    Text("Camera")
                }
                
                
            }
            .padding(.top, 20)
            .padding(.leading, 20)
            .padding(.trailing, 20)
        }
    }
}


struct PetAccessories:View{
    
    @ObservedObject var viewModel: PetViewModel
    
    enum AccessTab{
        case hat
        case collar
        case back
    }
    @State private var selectedTab: AccessTab = .hat
    
    var body: some View{
        ScrollView(){
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color("LightBlue"))
                
                //MARK: - Heading sections
                VStack{
                    HStack(spacing: 40){
                        
                        //select hats
                        Button(action:{
                            selectedTab = .hat
                        }){
                            Text("Hats")
                                .font(.custom("Arial Rounded MT Bold", size: 21))
                                .foregroundStyle(selectedTab == .hat ? Color("DarkBlue") : Color("DarkBlue").opacity(0.5))
                        }
                        
                        //select collars
                        Button(action:{
                            selectedTab = .collar
                        }){
                            Text("Collars")
                                .font(.custom("Arial Rounded MT Bold", size: 21))
                                .foregroundStyle(selectedTab == .collar ? Color("DarkBlue") : Color("DarkBlue").opacity(0.5))
                        }
                        
                        //select back bling (wings mainly)
                        Button(action:{
                            selectedTab = .back
                        }){
                            Text("Back")
                                .font(.custom("Arial Rounded MT Bold", size: 21))
                                .foregroundStyle(selectedTab == .back ? Color("DarkBlue") : Color("DarkBlue").opacity(0.5))
                        }
                        
                    }
                    
                    //MARK: - actual accessories
                    optionsView(viewModel: viewModel, category: selectCategoryName,itemCount: 3)
                    Spacer()
                }
                .padding(20)
            }
            .frame(minHeight: 270)
        }
    }
    
    //MARK: - helpers
    private var selectCategoryName: String{
        switch selectedTab {
        case .hat:
            return "hat"
        case .collar:
            return "collar"
        case .back:
            return "back"
        }
    }
}


struct optionsView: View {
    @ObservedObject var viewModel: PetViewModel
    let category: String
    let itemCount: Int
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
        
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20){
            ForEach(1...itemCount, id: \.self){index in
                let imageName = "\(category)_\(index)_preview"
                let unlocked = isUnlocked(id: index)
                
                VStack{
                    ZStack{
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 90, height: 120)
                            .cornerRadius(10)
                            .grayscale(unlocked ? 0: 1.0)
                            .opacity(unlocked ? 1.0 : 0.5)
                        
                        if !unlocked{
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.white)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("DarkBlue"), lineWidth: 2)
                        // should highlight selected item
                            .opacity(isEquipped(id: index) ? 1 : 0)
                    )
                    
                }
                .onTapGesture {
                    viewModel.select(id: index, in: category)
                }
            }
        }
        
    }
    
    //MARK: -helper function
    private func isEquipped(id: Int)->Bool{
        switch category{
        case "body": return viewModel.pet?.bodyType == id
        case "ear": return viewModel.pet?.earType == id
        case "tail": return viewModel.pet?.tailType == id
        case "pattern": return viewModel.pet?.patterns.contains(id) ?? false
        case "hat", "collar", "back":
            return viewModel.equippedAccessory(namedLike: category) == "\(category)_\(id)"
        default: return false
        }
    }
    
    private func isUnlocked(id: Int)->Bool{
        if ["body","ear","tail","pattern"].contains(category){
            return true
        }
        return viewModel.isUnlocked(category: category, id: id)
    }
    
}

//TODO: all options for pet body should include a hue saturation and lightness slider with a check mark option to match for all parts (body, ears, tails)
struct PetBody:View{
    @ObservedObject var viewModel: PetViewModel
    
    enum AccessTab{
        case body
        case ears
        case tail
        case pattern
    }
    
    @State private var selectedTab: AccessTab = .body
    
    var body: some View{
        ScrollView(){
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color("LightBlue"))
                
                //MARK: - Heading sections
                VStack{
                    HStack(spacing: 35){
                        
                        //select body fluff
                        Button(action:{
                            selectedTab = .body
                            viewModel.select(id: viewModel.pet?.bodyType ?? 1, in: "body")
                        }){
                            Text("Body")
                                .font(.custom("Arial Rounded MT Bold", size: 21))
                                .foregroundStyle(selectedTab == .body ? Color("DarkBlue") : Color("DarkBlue").opacity(0.5))
                        }
                        
                        //select ears
                        Button(action:{
                            selectedTab = .ears
                            viewModel.select(id: viewModel.pet?.earType ?? 1, in: "ear")
                        }){
                            Text("Ears")
                                .font(.custom("Arial Rounded MT Bold", size: 21))
                                .foregroundStyle(selectedTab == .ears ? Color("DarkBlue") : Color("DarkBlue").opacity(0.5))
                        }
                        
                        //select tail options (wings mainly)
                        Button(action:{
                            selectedTab = .tail
                            viewModel.select(id: viewModel.pet?.tailType ?? 1, in: "tail")
                        }){
                            Text("Tail")
                                .font(.custom("Arial Rounded MT Bold", size: 21))
                                .foregroundStyle(selectedTab == .tail ? Color("DarkBlue") : Color("DarkBlue").opacity(0.5))
                        }
                        
                        //select patterns
                        //TODO: should be able to select multiple patterns ONLY
                        Button(action:{
                            selectedTab = .pattern
                        }){
                            Text("Pattern")
                                .font(.custom("Arial Rounded MT Bold", size: 21))
                                .foregroundStyle(selectedTab == .pattern ? Color("DarkBlue") : Color("DarkBlue").opacity(0.5))
                        }
                        
                    }
                    
                    //MARK: - actual options
                    optionsView(viewModel: viewModel , category: selectCategoryName2, itemCount: itemCount)
                    
                    //hue sat lightness control
                    VStack{
                        HueSlider(hue: $viewModel.currentHue)
                        SaturationSlider(saturation: $viewModel.currentSaturation, hue: viewModel.currentHue, brightness: viewModel.currentLightness)
                        BrightnessSlider(brightness: $viewModel.currentLightness)
                    }
                    
                    //match colors buttons
                    Button(action: {
                        withAnimation{
                            viewModel.syncAllColors()
                        }
                    }){
                        HStack{
                            Image(systemName: "link")
                            Text("Match All")
                        }
                        .font(.custom("Arial Rounded MT Bold", size: 20))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color("DarkBlue").opacity(0.1))
                        .foregroundStyle(Color("DarkBlue"))
                        .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                }
                .padding(20)
            }
            .frame(minHeight: 270)
        }
    }
    private var selectCategoryName2: String{
        switch selectedTab {
        case .body:
            return "body"
        case .ears:
            return "ear"
        case .tail:
            return "tail"
        case .pattern:
            return "pattern"
        }
    }
    
    private var itemCount: Int {
        switch selectedTab {
        case .pattern: return 4
        default: return 3
        }
    }
}

