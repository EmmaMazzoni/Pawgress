//
//  CustomShapes.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/12/26.
//
import SwiftUI

struct Parallelogram: Shape {
    var skew: CGFloat = 20

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX + skew, y: rect.minY)) // top left
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))     // top right
        path.addLine(to: CGPoint(x: rect.maxX - skew, y: rect.maxY)) // bottom right
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))     // bottom left
        path.closeSubpath()

        return path
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct QuarterCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        
        path.closeSubpath()
        
        return path
    }
}

struct Trapezoid: Shape {
    var topWidth: CGFloat
    var bottomWidth: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Center both widths inside the rect
        let topXOffset = (rect.width - topWidth) / 2
        let bottomXOffset = (rect.width - bottomWidth) / 2
        
        path.move(to: CGPoint(x: topXOffset, y: rect.minY)) // top-left
        path.addLine(to: CGPoint(x: topXOffset + topWidth, y: rect.minY)) // top-right
        path.addLine(to: CGPoint(x: bottomXOffset + bottomWidth, y: rect.maxY)) // bottom-right
        path.addLine(to: CGPoint(x: bottomXOffset, y: rect.maxY)) // bottom-left
        path.closeSubpath()
        
        return path
    }
}

#Preview{
    Trapezoid(topWidth: 110, bottomWidth: 120)
        .fill(Color.blue)
        .frame(width: 160, height: 60)
    Trapezoid(topWidth: 120, bottomWidth: 160)
        .fill(Color.blue)
        .frame(width: 160, height: 60)
}
