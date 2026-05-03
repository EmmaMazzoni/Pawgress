//
//  HueSatLightView.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/22/26.
//
import SwiftUI

struct HueSlider: View {
    @Binding var hue: Double

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: stride(from: 0.0, through: 1.0, by: 0.01).map {
                    Color(hue: $0, saturation: 1, brightness: 1)
                }),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 12)
            .cornerRadius(6)

            Slider(value: $hue, in: 0...360)
                .tint(.clear)
                .overlay(
                    GeometryReader { geo in
                        Circle()
                            .fill(Color(hue: hue/360, saturation: 1, brightness: 1))
                            .frame(width: 22, height: 22)
                            .shadow(radius: 2)
                            .position(
                                x: geo.size.width * hue,
                                y: geo.size.height / 2
                            )
                    }
                )
        }
    }
}

struct SaturationSlider: View {
    @Binding var saturation: Double
    var hue: Double
    var brightness: Double

    var body: some View {
        VStack {

            ZStack {
                // dynamic gradient (gray → full color of current hue)
                LinearGradient(
                    colors: [
                        Color(hue: hue/360, saturation: 0, brightness: brightness),
                        Color(hue: hue/360, saturation: 1, brightness: brightness)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 12)
                .cornerRadius(6)

                Slider(value: $saturation, in: 0...1)
                    .tint(.clear)
            }
        }
    }
}

struct BrightnessSlider: View {
    @Binding var brightness: Double

    var body: some View {
        VStack {

            ZStack {
                LinearGradient(
                    colors: [.black, .white],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 12)
                .cornerRadius(6)

                Slider(value: $brightness, in: 0...1)
                    .tint(.clear)
            }
        }
    }
}

struct HSLSliderGroup: View {
    @Binding var hue: Double
    @Binding var saturation: Double
    @Binding var lightness: Double
    
    var body: some View {
        VStack(spacing: 10) {
            // Hue Slider (0-360 degrees usually, but 0-1 for SwiftUI color modifiers)
            SliderView(value: $hue, label: "H", color: .red)
            SliderView(value: $saturation, label: "S", color: .gray)
            SliderView(value: $lightness, label: "L", color: .white)
        }
        .padding(.top, 10)
    }
}

struct SliderView: View {
    @Binding var value: Double
    let label: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .bold()
                .foregroundStyle(Color("DarkBlue"))
            Slider(value: $value, in: 0...1)
                .tint(color)
        }
    }
}
