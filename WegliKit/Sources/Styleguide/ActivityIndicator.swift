import SwiftUI

public struct ActivityIndicator: UIViewRepresentable {
  public init(style: UIActivityIndicatorView.Style, color: UIColor) {
    self.style = style
    self.color = color
  }
  
  public let style: UIActivityIndicatorView.Style
  public let color: UIColor
  
  let spinner: UIActivityIndicatorView = {
    $0.hidesWhenStopped = true
    return $0
  }(UIActivityIndicatorView(style: .medium))
  
  public func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
    spinner.style = style
    spinner.startAnimating()
    spinner.color = color
    return spinner
  }
  
  public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {}
  
  func configure(_ indicator: (UIActivityIndicatorView) -> Void) -> some View {
    indicator(spinner)
    return self
  }
}
