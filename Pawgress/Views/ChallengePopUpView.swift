//
//  ChallengePopUpView.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/27/26.
//
import SwiftUI
import SwiftData

struct ChallengePopUpView: View {
    let challenge: Challenge
    var onDismiss: () -> Void

    var body: some View {
        ZStack{
            //background
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    colors: [Color("Peach"), Color("FireOrange")],
                    startPoint: .top,
                    endPoint: .bottom
                ).opacity(0.8))
                .shadow( radius: 3, x: 4, y: 4)
            
            // dismiss button
            VStack{
                HStack{
                    Spacer()
                    Button{
                        onDismiss()
                    } label: {
                        Text("X")
                            .foregroundStyle(Color(.white))
                            .font(.custom("Arial Rounded MT Bold", size: 30))
                    }
                }
                Spacer()
            }
            .padding(15)
            
            //challenge information
            VStack(spacing: 1){
                //challenge badge
                if let badgeName = challenge.badge?.imageName{
                    Image(badgeName)
                        .resizable()
                        .frame(width: 242, height: 242)
                        .shadow(color: Color("FireOrange").opacity(0.6), radius: 3, x: 4, y: 4)
                        .shadow(color: Color("Cream").opacity(0.5), radius: 50, x: 4, y: 4)
                }
                //challenge name
                Text(challenge.title.uppercased())
                    .font(.custom("Mega Champs", size: 36))
                    .foregroundStyle(Color(.white))
                    .shadow(color: Color("FireOrange").opacity(0.5), radius: 3, x: 4, y: 4)
                //challenge decsription
                Text("Congratulations! \(challenge.descriptionText ?? "Great job!")")
                    .font(.custom("Arial Rounded MT Bold", size: 20))
                    .foregroundStyle(Color(.white))
                    .multilineTextAlignment(.center)
                Spacer()
                //completion date
                if let date = challenge.badge?.dateEarned{
                    Text("Completed: \(date.formatted(date: .numeric, time: .omitted))")
                        .font(.custom("Arial Rounded MT Bold", size: 20))
                        .foregroundStyle(Color(.white))
                        .multilineTextAlignment(.center)
                }
                
            }
            .padding(30)
        }
        .frame(width:338, height: 484)

    }
}

//#Preview {
//    ChallengePopUpView()
//}
