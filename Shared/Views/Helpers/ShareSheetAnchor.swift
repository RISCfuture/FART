import SwiftUI

#if canImport(UIKit)
  import UIKit
#endif

extension View {
  /// Keeps an open share sheet pointing at this view's toolbar share button when a layout
  /// change rebuilds the button.
  ///
  /// A share sheet shown as a popover points at the toolbar button that opened it. When a
  /// size-class change swaps the layout that holds the button, as unfolding iPhone Duo does,
  /// the button is replaced and the popover keeps pointing at where the old one was. Applied
  /// to the view whose toolbar holds the replacement, this moves the popover to it.
  ///
  /// - Parameter identifier: The accessibility identifier of the toolbar share button.
  @ViewBuilder
  func anchorsShareSheet(toToolbarButton identifier: String) -> some View {
    #if canImport(UIKit)
      background { ShareSheetAnchor(buttonIdentifier: identifier) }
    #else
      self
    #endif
  }
}

#if canImport(UIKit)
  private struct ShareSheetAnchor: UIViewRepresentable {
    let buttonIdentifier: String

    func makeUIView(context _: Context) -> AnchorView {
      AnchorView(buttonIdentifier: buttonIdentifier)
    }

    func updateUIView(_: AnchorView, context _: Context) {}

    /// An invisible view that, once the rebuilt layout is in a window, re-points the share
    /// sheet at the toolbar button the layout now shows.
    final class AnchorView: UIView {
      private let buttonIdentifier: String

      private var shareSheet: UIActivityViewController? {
        guard let root = window?.rootViewController else { return nil }
        return sequence(first: root) { $0.presentedViewController }
          .lazy
          .compactMap { $0 as? UIActivityViewController }
          .first
      }

      private var toolbarButton: UIBarButtonItem? {
        hostingController?.navigationItem.trailingItemGroups
          .lazy
          .flatMap(\.barButtonItems)
          .first { $0.accessibilityIdentifier == self.buttonIdentifier }
      }

      private var hostingController: UIViewController? {
        sequence(first: self as UIResponder) { $0.next }
          .lazy
          .compactMap { $0 as? UIViewController }
          .first
      }

      init(buttonIdentifier: String) {
        self.buttonIdentifier = buttonIdentifier
        super.init(frame: .zero)
      }

      @available(*, unavailable)
      required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
      }

      override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil else { return }
        // The toolbar's items are installed after the view joins the window.
        DispatchQueue.main.async { [weak self] in self?.reanchorShareSheet() }
      }

      private func reanchorShareSheet() {
        guard let popover = shareSheet?.popoverPresentationController,
          let button = toolbarButton,
          popover.sourceItem !== button
        else { return }

        popover.sourceItem = button
        popover.containerView?.setNeedsLayout()
      }
    }
  }
#endif
