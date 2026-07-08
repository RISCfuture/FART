#if os(macOS)
  import AppKit
  import PDFKit
  import SwiftUI

  /// Prints or exports a ``FRATReport`` using native macOS facilities.
  ///
  /// Both paths render the report to a vector PDF with `ImageRenderer`; printing then hands
  /// that PDF to PDFKit, which paginates and prints it reliably without the blank-page
  /// pitfalls of printing a detached `NSHostingView`.
  @MainActor
  enum FRATReportExporter {
    static func printReport(_ report: FRATReport) {
      guard let data = pdfData(for: report),
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
      guard let data = pdfData(for: report) else { return }

      let panel = NSSavePanel()
      panel.allowedContentTypes = [.pdf]
      panel.nameFieldStringValue = defaultFileName(for: report)
      guard panel.runModal() == .OK, let url = panel.url else { return }

      try? data.write(to: url)
    }

    private static func pdfData(for report: FRATReport) -> Data? {
      let renderer = ImageRenderer(content: FRATReportView(report: report))
      let pdfData = NSMutableData()

      renderer.render { size, renderInContext in
        var mediaBox = CGRect(origin: .zero, size: size)
        guard let consumer = CGDataConsumer(data: pdfData as CFMutableData),
          let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil)
        else { return }

        context.beginPDFPage(nil)
        renderInContext(context)
        context.endPDFPage()
        context.closePDF()
      }

      return pdfData.isEmpty ? nil : pdfData as Data
    }

    private static func defaultFileName(for report: FRATReport) -> String {
      let date = report.generatedAt.formatted(.iso8601.year().month().day())
      return "FRAT \(date).pdf"
    }
  }
#endif
