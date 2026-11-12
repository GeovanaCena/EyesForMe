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
        camera.iniciarCamera()
        
        speech.falarSeNecessario(CameraVoiceMessages.cameraAtivada)
        //speech.falar("Câmera frontal ativada, posicione o seu rosto em frente à câmera. ")
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
        camera.pararCamera()
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

    
    
    
    
    
}
