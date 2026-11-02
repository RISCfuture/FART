import SwiftUI

struct Gauge<Content: View>: View {
  private var gradient: Gradient {
    .init(colors: [
      Color(.lowRisk), Color(.moderateRisk), Color(.highRisk), Color(.moderateRisk),
      Color(.lowRisk)
    ])
  }

  private var angularGradient: AngularGradient {
    .init(gradient: gradient, center: .center, angle: .degrees(180))
  }

  var value: Float
  var contentView: () -> Content

  @State private var readingSize = CGSize.zero

  private var normalizedValue: CGFloat {
    CGFloat(value / 2 + 0.5)
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        dial(geometry)
        reading(geometry)
      }.frame(width: width(geometry))
        .offset(x: thickness(geometry) / 2 + (geometry.size.width - side(geometry)) / 2, y: 0)
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

  /// The content, on the dial's baseline and scaled down where needed to stay inside the arc.
  private func reading(_ geometry: GeometryProxy) -> some View {
    let box = readingBox(geometry)
    return contentView()
      .fixedSize()
      .onGeometryChange(for: CGSize.self, of: \.size) { readingSize = $0 }
      .scaleEffect(readingScale(in: box), anchor: .bottom)
      .frame(width: box.width, height: box.height, alignment: .bottom)
      .offset(y: -box.height / 2)
  }

  /// A box on the baseline whose top corners touch the inside of the arc.
  private func readingBox(_ geometry: GeometryProxy) -> CGSize {
    let innerRadius = (width(geometry) - thickness(geometry)) / 2
    return CGSize(
      width: innerRadius * ReadingBox.halfWidth * 2,
      height: innerRadius * ReadingBox.height
    )
  }

  private func readingScale(in box: CGSize) -> CGFloat {
    guard readingSize.width > 0, readingSize.height > 0 else { return 1 }
    return min(1, box.width / readingSize.width, box.height / readingSize.height)
  }

  /// The widest dial that fits: a half circle is twice as wide as it is tall.
  private func side(_ geometry: GeometryProxy) -> CGFloat {
    min(geometry.size.width, geometry.size.height * 2)
  }

  private func thickness(_ geometry: GeometryProxy) -> CGFloat {
    min(side(geometry) * 0.15, 50)
  }

  private func width(_ geometry: GeometryProxy) -> CGFloat {
    side(geometry) - thickness(geometry)
  }
}

#Preview(arguments: [Float(0), 0.25, 0.5, 0.75, 1]) { value in
  Gauge(value: value) {
    HStack(alignment: .firstTextBaseline) {
      // The dial is driven by a fraction but reads as a score, so the number follows the
      // sweep rather than sitting at a constant that contradicts it.
      Text(Int(value * 64), format: .number)
        .font(.system(size: 75))
        .bold()
        .foregroundStyle(Color(.moderateRisk))
      Text("PTS.")
        .bold()
        .foregroundStyle(Color(.moderateRisk))
    }
  }
}

/// The reading's box as fractions of the arc's inner radius. Its top corners sit on the arc,
/// since 0.8² + 0.6² = 1.
private enum ReadingBox {
  static let halfWidth = 0.8
  static let height = 0.6
}
