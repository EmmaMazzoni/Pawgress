//
//  FeedView.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/12/26.
//
import SwiftUI
import SwiftData

struct FeedView: View {
    var body: some View {
        ZStack{
            Color("Cream")
                .ignoresSafeArea()
            VStack(alignment: .center){
                Text("Coming Soon!!")
                    .font(.custom("Mega Champs", size: 60))
                    .foregroundStyle(Color("DarkBlue"))
                    .lineSpacing(-10)
                
                Text("Will not be coded for the purposes of CMPSC 475")
                    .font(.custom("Arial Rounded MT Bold", size: 20))
                    .foregroundStyle(Color("DarkBlue").opacity(0.75))
                    .multilineTextAlignment(.center)
            }
            .padding(20)
        }
        
    }
}

#Preview{
    FeedView()
}
