//
//  ChallengeView.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/16/26.
//
import SwiftUI
import SwiftData

struct ChallengeView: View{
    @Query(sort: \Challenge.title) private var allChallenges: [Challenge]
    
    enum TopTab{
        case progress
        case complete
    }
    
    @State private var selectedTab: TopTab = .progress
    // challenge pop up in completed
    @State private var selectedChallenge: Challenge?
    
    var inProgressChallenges: [Challenge]{
        allChallenges.filter{!$0.isCompleted}
    }
    
    var completedChallenges: [Challenge]{
        allChallenges.filter{$0.isCompleted}
    }
    
    
    var body: some View{
        ZStack{
            Color("Cream")
                .ignoresSafeArea()
            ScrollView(){
                VStack{
                    
                    Text("CHALLENGES")
                        .font(.custom("Mega Champs", size: 40))
                        .foregroundStyle(Color("DarkBlue"))
                    
                    //MARK: - page tabs in progress and complete
                    HStack{
                        Button(action:{
                            withAnimation{
                                selectedTab = .progress
                            }
                        }){
                            Text("In Progress")
                                .font(.custom("Arial Rounded MT Bold", size: 22))
                                .foregroundStyle(selectedTab == .progress ? Color("FireOrange") : Color("RegOrange"))
                                .lineSpacing(-10)
                        }
                        Spacer()
                        Button(action:{
                            withAnimation{
                                selectedTab = .complete
                            }
                        }){
                            Text("Complete")
                                .font(.custom("Arial Rounded MT Bold", size: 22))
                                .foregroundStyle(selectedTab == .complete ? Color("FireOrange") : Color("RegOrange"))
                                .lineSpacing(-10)
                        }
                    }
                    
                    //MARK: -  progress or challenge view
                    if selectedTab == .progress{
                        ChallengeProgress(challenges: inProgressChallenges)
                    }else{
                        ChallengeComplete(challenges: completedChallenges, selectedChallenge: $selectedChallenge)
                    }
                }
                .padding(35)
            }
            // challenge pop up overlay
            if let challenge = selectedChallenge {
                //dim background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { selectedChallenge = nil }
                
                ChallengePopUpView(challenge: challenge) {
                    selectedChallenge = nil
                }
                .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.spring(), value: selectedChallenge)
    }
}

//MARK: - In Progress Challenges View
struct ChallengeProgress: View{
    let challenges: [Challenge]
    
    var body: some View{
        VStack(spacing: 15){
            if challenges.isEmpty{
                Text("You have completed all active challenges! Stay tuned for more :)")
                    .font(.custom("Arial Rounded MT Bold", size: 20))
                    .foregroundStyle(Color("DarkBlue"))
                    .padding(.top, 40)
            } else {
                ForEach(challenges){ challenge in
                    ChallengeCard(challenge: challenge)
                }
            }
        }
        //.padding(20)
    }
}

//MARK: - Challenge Card for In Progress View
struct ChallengeCard: View{
    let challenge: Challenge

    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color("GradPeach"), Color("GradFireOrange")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            HStack(){
                Image(challenge.badge?.imageName ?? "default")
                    .resizable()
                    .frame(width: 114, height: 114)
                    
                VStack(alignment: .leading, spacing: 10){
                    Text(challenge.title)
                        .font(.custom("Arial Rounded MT Bold", size: 25))
                        .foregroundStyle(Color("FireText"))
                    if let desc = challenge.descriptionText {
                        Text(desc)
                            .font(.custom("Arial Rounded MT Bold", size: 20))
                            .foregroundStyle(Color("FireText"))
                    }
                    Text("\(challenge.progress)/\(challenge.goal)")
                        .font(.custom("Arial Rounded MT Bold", size: 15))
                        .foregroundStyle(Color("FireText"))
                    
                }
                Spacer()
                
            }
            .padding(5)
        }
        .frame(width: 339, height: 127)
    }
}

//MARK: - Completed Challenges
// only show as the badges not cards
struct ChallengeComplete: View{
    let challenges: [Challenge]
    @Binding var selectedChallenge: Challenge?

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View{
        LazyVGrid(columns: columns, spacing: 20){
            ForEach(challenges){ challenge in
                if let badge = challenge.badge{
                    Image(badge.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .onTapGesture {
                            withAnimation{
                                selectedChallenge = challenge
                            }
                        }
                }
            }
        }
        .padding(.top, 20)
    }
}

#Preview {
    ChallengeView()
}
