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
    private var brilhoOriginal: CGFloat = 0.5
    private var tela: UIScreen?
    
    //configurar a tela
    func configurarTela (_ screen: UIScreen ){
        guard tela == nil else {return}
        
        tela = screen
        brilhoOriginal =  screen.brightness
        screen.brightness = 1.0
    }
    
        //inicia a camera
    func iniciarCamera (){
        intensidade=1.0
        camera.iniciarCamera()
    }
    //restaura o brilho ao sair da camera
    func encerrarCamera(){
        camera.pararCamera()
        restaurarBrilho()
        
    }
    
    //controla o brilho conforme o ciclo de vida
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
    
    
    
    
    
}
