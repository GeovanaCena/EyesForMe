//
//  CameraManager.swift
//  EyesForMe
//
//  Created by Maria Izabelle Holanda de Andrade on 11/11/26.
//

import Foundation

import SwiftUI
import AVFoundation
import Combine

final class CameraManager: ObservableObject {

    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "camera.session.queue")

    @Published var permissaoNegada = false
    @Published var erro: String?

    private var configurada = false

    func iniciarCamera() {

        switch AVCaptureDevice.authorizationStatus(for: .video) {

        case .authorized:
            configurarCamera()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] permitido in

                DispatchQueue.main.async {
                    self?.permissaoNegada = !permitido
                }

                if permitido {
                    self?.configurarCamera()
                }
            }

        case .denied, .restricted:
            permissaoNegada = true

        @unknown default:
            permissaoNegada = true
        }
    }

    private func configurarCamera() {

        sessionQueue.async { [weak self] in

            guard let self = self else { return }

            guard !self.configurada else {
                self.iniciarSessao()
                return
            }

            self.session.beginConfiguration()
            self.session.sessionPreset = .high

            guard let camera = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .front
                
            ) else {
                print("Câmera frontal encontrada!")
               

                self.session.commitConfiguration()

                DispatchQueue.main.async {
                    self.erro = "Câmera frontal não encontrada."
                }

                return
            }

            do {

                let entrada = try AVCaptureDeviceInput(device: camera)

                guard self.session.canAddInput(entrada) else {
                    self.session.commitConfiguration()
                    return
                }

                self.session.addInput(entrada)

                self.session.commitConfiguration()

                self.configurada = true

                self.iniciarSessao()

            } catch {

                self.session.commitConfiguration()

                DispatchQueue.main.async {
                    self.erro = error.localizedDescription
                }
            }
        }
    }

    private func iniciarSessao() {

        guard !session.isRunning else { return }
        print("Iniciando sessão da câmera...")

        session.startRunning()
        print("Sessão iniciada: \(session.isRunning)")
    }

    func pararCamera() {

        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
}
[
