// Created for weg-li in 2021.

import SwiftUI

public struct ActivityIndicator: UIViewRepresentable {
  public init(style: UIActivityIndicatorView.Style) {
    self.style = style
  }
  
  public let style: UIActivityIndicatorView.Style
  
  let spinner: UIActivityIndicatorView = {
    $0.hidesWhenStopped = true
    return $0
  }(UIActivityIndicatorView(style: .medium))
  
  public func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
    spinner.style = style
    spinner.startAnimating()
    return spinner
  }
  
  public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {}
  
  func configure(_ indicator: (UIActivityIndicatorView) -> Void) -> some View {
    indicator(spinner)
    return self
  }
}
