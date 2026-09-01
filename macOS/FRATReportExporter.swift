#if os(macOS)
  import AppKit
  import PDFKit

  /// Prints or saves a ``FRATReport`` using native macOS facilities.
  ///
  /// Printing hands the report's PDF to PDFKit, which paginates and prints it reliably without
  /// the blank-page pitfalls of printing a detached `NSHostingView`.
  @MainActor
  enum FRATReportExporter {
    static func printReport(_ report: FRATReport) {
      guard let data = report.pdfData,
        let document = PDFDocument(data: data),
        let operation = document.printOperation(
          for: .shared,
          scalingMode: .pageScaleDownToFit,
          autoRotate: false
        )
      else { return }

      operation.jobTitle = String(localized: "Flight Risk Assessment")
      operation.run()
    }

    static func exportPDF(_ report: FRATReport) {
      guard let data = report.pdfData else { return }

      let panel = NSSavePanel()
      panel.allowedContentTypes = [.pdf]
      panel.nameFieldStringValue = report.suggestedFileName
      guard panel.runModal() == .OK, let url = panel.url else { return }

      try? data.write(to: url)
    }
  }
#endif
