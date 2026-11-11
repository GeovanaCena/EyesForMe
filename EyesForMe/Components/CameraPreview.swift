//
//  CameraPreview.swift
//  EyesForMe
//
//  Created by Maria Izabelle Holanda de Andrade on 11/11/26.
//

import SwiftUI
import AVFoundation

class CameraUIView: UIView {

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var cameraLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}

struct CameraPreview: UIViewRepresentable {

    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraUIView {

        let view = CameraUIView()

        view.cameraLayer.session = session
        view.cameraLayer.videoGravity = .resizeAspectFill

        return view
    }

    func updateUIView(_ uiView: CameraUIView, context: Context) {

        uiView.cameraLayer.session = session
    }
}

