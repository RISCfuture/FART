#if os(macOS)
  import SwiftUI

  /// A one-page, print-styled summary of a FRAT, used for printing and PDF export.
  ///
  /// Rendered on a fixed-width white page in a forced light appearance so it reads the same
  /// on paper regardless of the app's current theme.
  struct FRATReportView: View {
    static let pageWidth = 612.0  // US Letter width at 72 dpi

    let report: FRATReport

    var body: some View {
      VStack(alignment: .leading, spacing: 24) {
        ReportHeader(report: report)
        ScoreSummary(report: report)
        ForEach(report.categories) { category in
          FactorSection(category: category)
        }
      }
      .padding(48)
      .frame(width: Self.pageWidth, alignment: .topLeading)
      .fixedSize(horizontal: false, vertical: true)
      .background(.white)
      .environment(\.colorScheme, .light)
    }
  }

  private struct ReportHeader: View {
    let report: FRATReport

    var body: some View {
      VStack(alignment: .leading, spacing: 4) {
        Text("Flight Risk Assessment")
          .font(.system(size: 24, weight: .bold, design: .rounded))
          .foregroundStyle(.black)
        Text(report.generatedAt, format: .dateTime.year().month().day().hour().minute())
          .foregroundStyle(.secondary)
      }
    }
  }

  /// The centered score readout, mirroring the app's results screen: a large “17 PTS.” with
  /// the uppercased risk level beneath it, both tinted with the risk band color.
  private struct ScoreSummary: View {
    let report: FRATReport

    var body: some View {
      VStack(spacing: 8) {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
          Text(report.score, format: .number)
            .font(.system(size: 64, weight: .bold, design: .rounded))
          Text("PTS.")
            .font(.title3)
            .bold()
        }
        Text(report.risk.label.uppercased())
          .font(.title2)
          .bold()
      }
      .foregroundStyle(report.risk.color)
      .frame(maxWidth: .infinity)
    }
  }

  private struct FactorSection: View {
    let category: FRATReport.Category

    var body: some View {
      VStack(alignment: .leading, spacing: 6) {
        Text(category.name)
          .font(.headline)
          .foregroundStyle(.black)
        ForEach(category.factors) { factor in
          FactorRow(factor: factor)
        }
      }
    }
  }

  private struct FactorRow: View {
    let factor: FRATReport.Factor

    var body: some View {
      HStack(alignment: .firstTextBaseline) {
        Text(factor.label)
          .foregroundStyle(.black)
        Spacer(minLength: 16)
        Text(factor.points, format: .number.sign(strategy: .always()))
          .monospacedDigit()
          .foregroundStyle(.secondary)
      }
    }
  }

  #Preview {
    let questionnaire: Questionnaire = {
      let questionnaire = Questionnaire()
      questionnaire.lessThan50InType = true
      questionnaire.lessThan8HrSleep = true
      questionnaire.night = true
      questionnaire.shortRunway = true
      return questionnaire
    }()
    FRATReportView(report: .init(questionnaire: questionnaire, generatedAt: Date()))
  }
#endif
