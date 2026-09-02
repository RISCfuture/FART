import CoreTransferable
import Foundation
import UniformTypeIdentifiers

extension FRATReport: Transferable {
  // `exportedContentType:` rather than `contentType:`: the latter overload also demands an
  // importing closure, which would declare that the app can read an arbitrary PDF back into a
  // questionnaire. Five of a FRAT's answers are defined by per-device threshold settings, so a
  // reopened assessment would silently re-interpret the sender's answers against the
  // recipient's; the PDF travels as an inert artifact and nothing travels back.
  static var transferRepresentation: some TransferRepresentation {
    FileRepresentation(exportedContentType: .pdf, shouldAllowToOpenInPlace: false) { report in
      try await SentTransferredFile(report.writeTemporaryPDF())
    }
    .suggestedFileName { $0.suggestedFileName }
  }

  /// The directory holding every PDF exported since the app launched.
  static var exportsDirectory: URL {
    FileManager.default.temporaryDirectory
      .appending(path: "Exports", directoryHint: .isDirectory)
  }

  /// Discards the exports left behind by earlier launches.
  ///
  /// An exported file has to outlive the exporting closure, because the system copies out of
  /// it only after that closure returns — so no export is safe to reap while the app is
  /// running. Launch is the one moment none can be in flight, which makes it the moment to
  /// clear the whole directory. Call it before the first export of a session.
  static func removeStaleExports() {
    try? FileManager.default.removeItem(at: exportsDirectory)
  }

  /// Renders the report to a PDF in its own directory under ``exportsDirectory`` and returns
  /// the file's URL.
  ///
  /// The directory is unique per export so the file can carry ``suggestedFileName`` verbatim;
  /// services that copy the file, like Mail and AirDrop, read the name off disk rather than
  /// from the transfer representation. ``removeStaleExports()`` clears them at launch.
  @MainActor
  func writeTemporaryPDF() throws -> URL {
    guard let pdfData else { throw FRATReportError.renderingFailed }

    let directory = Self.exportsDirectory
      .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

    let url = directory.appending(path: suggestedFileName)
    try pdfData.write(to: url)

    return url
  }
}

/// A failure that kept a ``FRATReport`` from becoming a shareable file.
enum FRATReportError: LocalizedError {
  case renderingFailed

  var errorDescription: String? {
    String(localized: "Couldn’t create the PDF.")
  }

  var failureReason: String? {
    switch self {
      case .renderingFailed:
        String(localized: "The report didn’t draw any pages.")
    }
  }
}
