//
//  HomeView.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/12/26.
//
import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var progressionManager: ProgressionManager
    @ObservedObject var petViewModel: PetViewModel

    init(modelContext: ModelContext, petViewModel: PetViewModel) {
        self.petViewModel = petViewModel
    }
    
    @State var showHearts: Bool = false
    @State private var heartScale: CGFloat = 0.1
    @State private var isShowingNameAlert = false
    @State private var newName = ""
    
    private var filledSegments: Int{
        guard let pet = petViewModel.pet else {return 0}
        let progress = Double(pet.xp)/1000.0
        return Int(progress*10)
    }
    
    @Query(filter: #Predicate<Challenge> { $0.isCompleted == true })
    private var completedChallenges: [Challenge]
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color("Cream")
                    .ignoresSafeArea()
                ScrollView(){
                    VStack{
                        //MARK: - Header, petname and settings
                        HStack(alignment: .firstTextBaseline){
                            Button(action: {
                                newName = petViewModel.pet?.name ?? ""
                                isShowingNameAlert = true
                            }){
                                HStack(alignment: .firstTextBaseline){
                                    Text(petViewModel.pet?.name.uppercased() ?? "PETNAME")
                                        .font(.custom("Mega Champs", size: 40))
                                        .foregroundStyle(Color("DarkBlue"))
                                    Image(systemName: "square.and.pencil")
                                        .font(.system(size: 23, weight: .bold))
                                        .foregroundStyle(Color("DarkBlue"))
                                }
                            }
                            
                            Spacer()
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundStyle(Color("DarkBlue"))
                        }
                        .padding(-1)
                        
                        //MARK: - Pet itself
                        PetView(viewModel: petViewModel)
                        
                        //MARK: - Level bar
                        HStack(spacing: -6){
                            ForEach(0..<10){index in
                                Parallelogram(skew: 11)
                                    .fill(index < filledSegments ? Color("DarkBlue") : Color("LightBlue"))
                                    .frame(width: 35, height: 26)
                                    .shadow(color: Color("Peach").opacity(0.3), radius: 1, x: 3, y: 3)
                            }
                        }
                        .padding(.top, 20)
                        
                        //MARK: -actual level and xp count
                        HStack{
                            Text("LVL \(petViewModel.pet?.level ?? 1)")
                                .font(.custom("Arial Rounded MT Bold", size: 18))
                                .foregroundStyle(Color("DarkBlue"))
                            
                            Spacer()
                            Text("\(petViewModel.pet?.xp ?? 0)/ 1000 XP")
                                .font(.custom("Arial Rounded MT Bold", size: 18))
                                .foregroundStyle(Color("DarkBlue"))
                        }
                        .frame(width: 300)
                        
                        //MARK: - Welcome back (in place of where username and friends will go in the future), streak, and badge collection
                        HStack(spacing: 40){
                            VStack{
                                Image("fire")
                                    .resizable()
                                    .frame(width: 118, height: 130)
                                //streak
                                let streak = petViewModel.pet?.currentStreak ?? 0
                                Text("\(streak) \(streak == 1 ? "Day" : "Days")")
                                    .font(.custom("Arial Rounded MT Bold", size: 25))
                                    .foregroundStyle(Color("DarkBlue"))
                            }
                            //MARK: -Badge shelf
                            NavigationLink(destination: ChallengeView()){
                                ZStack{
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color("ShelfBase"))
                                        .stroke(Color("ShelfLine"), lineWidth: 4)
                                        .frame(width: 159, height: 289)
                                    
                                    VStack(spacing: 10){
                                        ForEach(0..<4){row in
                                            ZStack{
                                                Rectangle()
                                                    .fill(Color("ShelfShadow"))
                                                    .stroke(Color("ShelfLine"), lineWidth: 4)
                                                    .frame(width: 135 , height: 58)
                                                HStack{
                                                    ForEach(0..<2){ column in
                                                        let index = (row*2) + column
                                                        if completedChallenges.indices.contains(index){
                                                            Image(completedChallenges[index].badge?.imageName ?? "")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 45, height: 45)
                                                        }
                                                    }
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, 20)
                        
                    }
                    .padding(25)
                }
            }
        }
        .alert("Rename your pet", isPresented: $isShowingNameAlert){
            TextField("New Name", text: $newName)
            Button("Cancel", role: .cancel){}
            Button("Save"){
                petViewModel.pet?.name = newName
                try? modelContext.save()
            }
        } message: {
            Text("Enter a new name for you bestie :)")
        }
        .onAppear{
            if petViewModel.pet != nil {
                petViewModel.checkAndRefreshStreak()
            }
        }
    }
}

struct HeartPopup: View{
    var body: some View {
        ZStack{
            ZStack{
                Image(systemName: "heart.fill")
                    .foregroundStyle(Color("HeartFill"))
                    .font(.system(size: 30))
                Image(systemName: "heart")
                    .foregroundStyle(Color("HeartLine"))
                    .font(.system(size: 30))
            }
            .offset(x: 20, y: -20)
            
            ZStack{
                Image(systemName: "heart.fill")
                    .foregroundStyle(Color("HeartFill"))
                    .font(.system(size: 20))
                Image(systemName: "heart")
                    .foregroundStyle(Color("HeartLine"))
                    .font(.system(size: 20))
            }
        }
        .offset(x: 50, y: -60)
    }
}


#Preview {
    // 1. Setup the mock container with all necessary models
    let schema = Schema([Pet.self, Challenge.self, Badge.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    
    return MainActor.assumeIsolated {
        let context = container.mainContext
        
        // 2. Inject a preview pet if one doesn't exist
        let previewPet = Pet(name: "Buddy")
        context.insert(previewPet)
        
        // 3. Initialize the ViewModels with the mock context
        let petVM = PetViewModel(modelContext: context)
        let progression = ProgressionManager(context: context)
        
        return HomeView(modelContext: context, petViewModel: petVM)
            .modelContainer(container)
            .environmentObject(progression)
    }
}
