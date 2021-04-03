// Created for weg-li in 2021.

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    let style: UIActivityIndicatorView.Style

    private let spinner: UIActivityIndicatorView = {
        $0.hidesWhenStopped = true
        return $0
    }(UIActivityIndicatorView(style: .medium))

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        spinner.style = style
        spinner.startAnimating()
        return spinner
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {}

    func configure(_ indicator: (UIActivityIndicatorView) -> Void) -> some View {
        indicator(spinner)
        return self
    }
}
