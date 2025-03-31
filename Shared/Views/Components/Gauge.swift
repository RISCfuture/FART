import SwiftUI

struct Gauge<Content: View>: View {
    private var gradient: Gradient {
        .init(colors: [lowRiskColor, moderateRiskColor, highRiskColor, moderateRiskColor, lowRiskColor])
    }

    private var angularGradient: AngularGradient {
        .init(gradient: gradient, center: .center, angle: .degrees(180))
    }

    var value: Float
    var contentView: () -> Content

    private var normalizedValue: CGFloat {
        CGFloat(value / 2 + 0.5)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                dial(geometry)
                contentView()
            }.frame(width: width(geometry))
                .offset(x: thickness(geometry) / 2, y: 0)
        }
    }

    private func dial(_ geometry: GeometryProxy) -> some View {
        ZStack {
            Circle()
                .trim(from: 0.5, to: 1)
                .stroke(Color.black.opacity(0.1), lineWidth: thickness(geometry))
                .frame(height: width(geometry))

            Circle()
                .trim(from: 0.5, to: normalizedValue)
                .stroke(angularGradient, lineWidth: thickness(geometry))
                .frame(height: width(geometry))
        }
    }

    private func thickness(_ geometry: GeometryProxy) -> CGFloat {
        min(geometry.size.width * 0.15, 50)
    }

    private func width(_ geometry: GeometryProxy) -> CGFloat {
        geometry.size.width - thickness(geometry)
    }
}

#Preview {
    @Previewable @State var value: Float = 0.5

    Gauge(value: value) {
        HStack(alignment: .firstTextBaseline) {
            Text("24")
                .font(.system(size: 75))
                .bold()
                .foregroundColor(moderateRiskColor)
            Text("PTS.")
                .bold()
                .foregroundColor(moderateRiskColor)
        }.offset(x: 0, y: -30)
    }
}
