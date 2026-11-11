//
//  ScreenBrightnessManager.swift
//  EyesForMe
//
//  Created by Maria Izabelle Holanda de Andrade on 11/11/26.
//

import SwiftUI
import UIKit

struct ScreenBrightnessManager: UIViewRepresentable {
    var onScreenReady: (UIScreen) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        DispatchQueue.main.async {
            if let screen = view.window?.windowScene?.screen {
                onScreenReady(screen)
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let screen = uiView.window?.windowScene?.screen {
                onScreenReady(screen)
            }
        }
    }
}
