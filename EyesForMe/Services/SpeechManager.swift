//
//  SpeechManager.swift
//  EyesForMe
//
//  Created by Maria Izabelle Holanda de Andrade on 12/11/26.
//

import Foundation
import AVFAudio

@MainActor
final class SpeechManager {
    //transforma tetxo em fala
    private let sintetizador = AVSpeechSynthesizer()
    
    private var ultimaMessage: String?
    
    //recebe a mesagem que o aplicativo precise falar
    func falar(_ mensagem: String){
        guard !mensagem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        do{
            let audioSession = AVAudioSession.sharedInstance()
            
            try audioSession.setCategory(
                .playback, //permite reproduzir o audio
                mode: .spokenAudio, // define o modo de áudio para fala
                options: [.duckOthers] // diminui temporariamente outros áudios durante a fala
            )
            try audioSession.setActive(true)
            
            //represneta a mensahem que sera falada
            let fala = AVSpeechUtterance(string: mensagem)
            
            fala.voice = AVSpeechSynthesisVoice(language: "pt-BR")
            fala.rate = 0.48 //velocidade da fala
            fala.volume = 1.0 //volume da fala no maximo
            
            sintetizador.speak(fala)
        }catch {
            print("Erro ao reproduzir orientação: \(error.localizedDescription)")

        }
    }
    
    ///so reproduzir a mensagem se ela for difenrete da ultima
    func falarSeNecessario (_ mensagem: String){
        guard mensagem != ultimaMessage else {
            return
        }
        
        //atualiza a ultima mensagem antes de reproduzir
        ultimaMessage = mensagem
        
        //interropmpe uma fala anterior se existir
        sintetizador.stopSpeaking(at: .immediate)
        
        //repdiruz a nova mensagem
        falar(mensagem)
    }
    
    
    func parar(){
        sintetizador.stopSpeaking(at: .immediate)
        ultimaMessage = nil
    }
    
    ///interrpe a fala atual pra falar uma fala prioritaria
    func falaPrioritaria (_ mensagem: String){
        //para de falar
        sintetizador.stopSpeaking(at: .immediate)
        //nova mensagem reproduza
        ultimaMessage = nil
        //reproduz a nova orientacao 
        falarSeNecessario(mensagem)
        
    }
    
    
}
