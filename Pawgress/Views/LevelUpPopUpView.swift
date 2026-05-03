//
//  LevelUpPopUpView.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/27/26.
//
import SwiftUI
import SwiftData

struct LevelUpPopUpView: View {
    let level: Int
    var onDismiss: () -> Void
    
    var body: some View {
        
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    colors: [Color("LightBlue"), Color("DarkBlue")],
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
            
            VStack{
                HStack{
                    //level
                    Text("\(level)")
                        .font(.custom("Arial Rounded MT Bold", size: 128))
                        .foregroundStyle(Color(.white))
                        .shadow(color: Color("DarkBlue"), radius: 3, x: 4, y: 4)
                    Image(systemName: "arrowtriangle.up.2.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color(.white))
                        .shadow(color: Color("DarkBlue"), radius: 3, x: 4, y: 4)
                }
                
                Text("YOU LEVELED UP!!")
                    .font(.custom("Mega Champs", size: 35))
                    .foregroundStyle(Color("LightBlue"))
                    .shadow(color: Color("DarkBlue"), radius: 3, x: 4, y: 4)
            }
        }
        .frame(width: 338, height: 253)
    }
}

//#Preview {
//    LevelUpPopUpView()
//}
