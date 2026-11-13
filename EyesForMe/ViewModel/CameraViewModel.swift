//
//  CameraViewModel.swift
//  EyesForMe
//
//  Created by Maria Izabelle Holanda de Andrade on 11/11/26.
//

import Foundation
import AVFoundation
import UIKit
import Combine
import SwiftUI

@MainActor
final class CameraViewModel: ObservableObject{
    //gerenciamento da camera
    let camera = CameraManager()
    
    //intensidade da moldura
    @Published var intensidade: Double = 1.0
    
    // Guarda o brilho original do iPhone
    private var brilhoOriginal: CGFloat  = 0.5
    private var tela: UIScreen?
    
    
    private let speech = SpeechManager()
    private let confirmationSound = ConfirmationSoundManager()
    
    //ultima posic identificada
    private var ultimaposicaoCamera: PosicaoRosto?
    
    private var posicionamentoConfirmado = false
    
    // controla quando o aplicativo pode começar a orientar
    private var podeOrientar = false

    // indica se a pessoa recebeu um aviso de que saiu da posição
    private var avisouDesalinhamento = false
    
    
    // reconhecimento dos comandos de voz
    private let voiceCommand = VoiceCommandManager()


    // indica se a pessoa solicitou uma nova verificação
    private var aguardandoFeedback = false
    
    
    private var tarefaInicial: Task<Void, Never>?
    private var tarefaEscuta: Task<Void, Never>?
        
    
    ///configurar a tela
    func configurarTela (_ screen: UIScreen ){
        guard tela == nil else {return}
        
        tela = screen
        brilhoOriginal =  screen.brightness
        screen.brightness = 1.0
    }
    
    ///inicia a camera
    func iniciarCamera (){
        intensidade=1.0
        
        posicionamentoConfirmado = false
        aguardandoFeedback = false
        podeOrientar = false
        ultimaposicaoCamera = nil
        
        
        //recebe as atualiacoes de posicoes enviadas pelo cameraManager
        camera.onPosicaoAtualizada = {
            [weak self] posicao in
            self?.atualizarPosicao(posicao)
        }
        camera.iniciarCamera()
        
        speech.falarSeNecessario(CameraVoiceMessages.cameraAtivada)
        
        // esperra 3 segundos antes de começar as orientações
//        Task {
//            try? await Task.sleep(for: .seconds(3))
//
//            podeOrientar = true
//
//            camera.resetarUltimaPosicao()
//            // ve novamente a posição atual do rosto
//           // ultimaposicaoCamera = nil
//        }
        tarefaInicial?.cancel()

        tarefaInicial = Task {
            try? await Task.sleep(for: .seconds(3))

            guard !Task.isCancelled else { return }

            podeOrientar = true
            camera.resetarUltimaPosicao()
        }
    }
    
    ///reprodiz uma orientacao por voce
    func falarOrientacao (_ mensagem: String){
        //interropme som de confirmacao
        confirmationSound.parar()
        
        //reproduz a mensagem sem reprtir a utlima
        speech.falarSeNecessario(mensagem)
        
    }
    
    func reproduzirSomConfirmacao (){
        //interrompe uma fala qe esteja em andamento
        speech.parar()
        //repdiuzi o som de confirmaca
        confirmationSound.reproduzimSomConfirmacao()
    }
    
    
    ///restaura o brilho ao sair da camera, interrompe os audios
    func encerrarCamera(){
        speech.parar()
        confirmationSound.parar()
        
        //para =o reocnhemcimento de voz
        voiceCommand.pararEscuta()
        
        camera.onPosicaoAtualizada = nil
        camera.pararCamera()
        
        
        posicionamentoConfirmado = false
        aguardandoFeedback = false
        //avisouDesalinhamento = false
        podeOrientar = false
        ultimaposicaoCamera = nil
        
        tarefaInicial?.cancel()
        tarefaEscuta?.cancel()

        tarefaInicial = nil
        tarefaEscuta = nil
        
        restaurarBrilho()

    }
    
    //controla o brilho conforme o ciclo de vida do app
    func atualizarEstado (_ fase: ScenePhase){
        switch fase{
        case .active:
            tela?.brightness = 1.0
        case .inactive, .background:
            restaurarBrilho()
            
        @unknown default:
            break
        }
        
    }
    
    private func restaurarBrilho(){
        tela?.brightness = brilhoOriginal
    }
    
    
    func testarFalasRepetidas() {
        
        speech.falarSeNecessario(CameraVoiceMessages.rostoNaoDetectado)
        speech.falarSeNecessario(CameraVoiceMessages.rostoNaoDetectado)
        speech.falarSeNecessario(CameraVoiceMessages.rostoParcial)
        
    }
    
    func testarSomConfirmacao (){
        reproduzirSomConfirmacao()
    }
    
    
    func atualizarPosicao(_ posicao: PosicaoRosto){
        guard podeOrientar else {return}
        
        guard posicao != ultimaposicaoCamera else {return}
        ultimaposicaoCamera = posicao
        
        if !posicionamentoConfirmado{
            switch posicao {
            case .foraDoCampo:
                falarOrientacao(CameraVoiceMessages.rostoNaoDetectado)
                
            case .parcial(let direcao):
                orientar(direcao)
                
//                switch direcao{
//                case .esquerda:
//                    falarOrientacao("Mova seu rosto para a esquerda.")
//                case .direita:
//                    falarOrientacao("Mova seu rosto para a direita.")
//                    
//                case .cima:
//                    falarOrientacao("Levante um pouco seu rosto.")
//                    
//                case .baixo:
//                    falarOrientacao("Abaixe um pouco seu rosto.")
//                    
//                case .aproximar:
//                    falarOrientacao("Aproxime seu rosto da câmera.")
//                    
//                case .afastar:
//                    falarOrientacao("Afaste um pouco seu rosto.")
//                    
//                }
                
            case .correta:
                posicionamentoConfirmado = true
                // confirma apenas uma vez no posicionamento inicial

                reproduzirSomConfirmacao()

                // fica aguardando um comando de voz
                iniciarEscutaComando()
            }
            return
        }
        
        guard aguardandoFeedback else{return}
        
        switch posicao {

            case .foraDoCampo:
                falarOrientacao(CameraVoiceMessages.rostoNaoDetectado)

            case .parcial(let direcao):
                orientar(direcao)

            case .correta:
                aguardandoFeedback = false

                // Confirma que a pessoa está posicionada para o feedback.
                reproduzirSomConfirmacao()

                // Volta a aguardar uma nova solicitação por voz.
                iniciarEscutaComando()
            }
//        
//        //dps da confirmacao so avisar se ela se afastar muito
//        switch posicao {
//        case .foraDoCampo:
//            avisouDesalinhamento = true
//            falarOrientacao(CameraVoiceMessages.rostoForaDaPosicao)
//            
//        case .parcial(.aproximar):
//            avisouDesalinhamento = true
//            falarOrientacao("Você está muito longe. Aproxime seu rosto da câmera")
//            
//        case .correta:
//            if avisouDesalinhamento{
//                avisouDesalinhamento = false
//                reproduzirSomConfirmacao()
//            }
//            
//        default:
//            break
//        }
        
        
    }
    
//    private func iniciarEscutaComando() {
//
//        // pequena espera para não capturar o próprio som de confirmação
//        Task {
//            try? await Task.sleep(for: .seconds(1))
//
//            voiceCommand.iniciarEscuta { [weak self] in
//                self?.solicitarFeedback()
//            }
//        }
//    }
    
    private func iniciarEscutaComando() {

        tarefaEscuta?.cancel()

        tarefaEscuta = Task {
            try? await Task.sleep(for: .seconds(1))

            guard !Task.isCancelled else { return }

            voiceCommand.iniciarEscuta { [weak self] in
                self?.solicitarFeedback()
            }
        }
    }
    
    func solicitarFeedback() {

        // so permite solicitar feedback depois da confirmação inicial
        guard posicionamentoConfirmado else { return }

        // evita iniciar várias verificações ao mesmo tempo
        guard !aguardandoFeedback else { return }

        aguardandoFeedback = true
        ultimaposicaoCamera = nil

        // faz o CameraManager enviar novamente a posição atual
        camera.resetarUltimaPosicao()
    }
    
    private func orientar(_ direcao: DirecaoAjuste) {

        switch direcao {

        case .esquerda:
            falarOrientacao("Mova seu rosto para a esquerda.")

        case .direita:
            falarOrientacao("Mova seu rosto para a direita.")

        case .cima:
            falarOrientacao("Levante um pouco seu rosto.")

        case .baixo:
            falarOrientacao("Abaixe um pouco seu rosto.")

        case .aproximar:
            falarOrientacao("Aproxime seu rosto da câmera.")

        case .afastar:
            falarOrientacao("Afaste um pouco seu rosto.")
        }
    }
}
