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

final class CameraManager: NSObject, ObservableObject {

    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "camera.session.queue")

    @Published var permissaoNegada = false
    @Published var erro: String?

    private var configurada = false
    
    //processar os frames
    private let videoQueue = DispatchQueue(label: "camera.video.queue")
    
    //recebe os frames da camera
    private let videoOutput = AVCaptureVideoDataOutput()
    
    //detetcao facial
    private let detector = DetectorFacial()
    private let classificador = ClassificadorPosicao()
    
    //guarda a ultima posicao
    private var ultimaPosicao: PosicaoRosto?
    
    //envia o resultado da classificacao pro viewlmodel
    var onPosicaoAtualizada: ((PosicaoRosto) -> Void)?
    

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
            DispatchQueue.main.async{
                self.permissaoNegada = true
                
            }
            

        @unknown default:
            DispatchQueue.main.async {
                self.permissaoNegada = true

            }
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
                
                //configura a saida de video.
                self.videoOutput.videoSettings = [
                    kCVPixelBufferPixelFormatTypeKey as String:
                        kCVPixelFormatType_32BGRA
                ]
                
                //descarta frames atrasados
                self.videoOutput.alwaysDiscardsLateVideoFrames = true
                
                self.videoOutput.setSampleBufferDelegate(
                    self,
                    queue: self.videoQueue
                )
                
                guard self.session.canAddOutput(self.videoOutput) else {
                    self.session.commitConfiguration()
                    
                    DispatchQueue.main.async {
                        self.erro = "Não foi possível configurar a saída de vídeo."
                    }
                    return
                }
                
                self.session.addOutput(self.videoOutput)
                        
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
            //self.videoOutput.setSampleBufferDelegate(nil, queue: nil)
        }
    }
    
    func resetarUltimaPosicao() {
        videoQueue.async { [weak self] in
            self?.ultimaPosicao = nil
        }
    }
}

///recebimento dos frames
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        //obtem o frame indivual da camera
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        //detecta o rosto no frame
        let retanguloRosto = detector.detectar(frame)
        
        //classifica a posicao do rosto
        let posicao = classificador.classificar(retanguloRosto)
        
        //evitar enviar o mesmo estado
        guard posicao != ultimaPosicao else {
            return
        }
        
        ultimaPosicao = posicao
        
        //entrega o resultado
        DispatchQueue.main.async {
            [weak self ] in
            self?.onPosicaoAtualizada?(posicao)
        }
        
            
    }
}
