//
//  ConfirmationSoundManager.swift
//  EyesForMe
//
//  Created by Maria Izabelle Holanda de Andrade on 12/11/26.
//


//som de confirmacao
import Foundation
import AVFAudio

@MainActor
final class ConfirmationSoundManager {
    private var audioPlayer: AVAudioPlayer?
    
    func reproduzimSomConfirmacao (){
        
        //procura o arquivo de som
        guard let url = Bundle.main.url(
            forResource: "confirmacao",
            withExtension: "wav"
        )else {
            print("arquivo de confirmação não encontrado")
            return
        }
        do {
            //prepraa o arquivo pra reproducao
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            
            //reproduz o som
            audioPlayer?.play()
            
        }catch{
            print("Erro ao reproduzir o som: \(error.localizedDescription)")
            
        }
    }
    // interrompe a reprodução do som de confirmação quando uma voz precisa ser falada
    func parar (){
        audioPlayer?.stop()
    }
}
