//
//  VoiceCommandManager.swift
//  EyesForMe
//
//  Created by Maria Izabelle Holanda de Andrade on 13/11/26.
//

import Foundation
import Speech
import AVFoundation

final class VoiceCommandManager {

    // reconhecedor de fala em português.
    private let reconhecedor = SFSpeechRecognizer(locale: Locale(identifier: "pt-BR"))

    // responsável por capturar o áudio do microfone.
    private let audioEngine = AVAudioEngine()

    // objetos utilizados durante o reconhecimento
    private var requisicao: SFSpeechAudioBufferRecognitionRequest?
    private var tarefaReconhecimento: SFSpeechRecognitionTask?

    // garda a acao que será executada quando um comando for reconhecido.
    private var aoReconhecerComando: (() -> Void)?

    private var estaEscutando = false
    private var comandoDetectado = false
    private var instalouTap = false

    // innicia a solicitação de permissões e, se autorizado, começa a escutar.
    func iniciarEscuta(aoReconhecerComando: @escaping () -> Void) {

        guard !estaEscutando else { return }

        self.aoReconhecerComando = aoReconhecerComando

        SFSpeechRecognizer.requestAuthorization { [weak self] status in

            guard status == .authorized else {
                print("Permissão de reconhecimento de fala negada.")
                return
            }

            AVAudioSession.sharedInstance().requestRecordPermission { permitido in

                guard permitido else {
                    print("Permissão do microfone negada.")
                    return
                }

                DispatchQueue.main.async {
                    self?.iniciarReconhecimento()
                }
            }
        }
    }

    // configura o microfone e inicia o reconhecimento.
    private func iniciarReconhecimento() {

        guard !estaEscutando else { return }

        guard let reconhecedor, reconhecedor.isAvailable else {
            print("Reconhecimento de fala indisponível.")
            return
        }

        let audioSessao = AVAudioSession.sharedInstance()

        do {
            try audioSessao.setCategory(
                .playAndRecord,
                mode: .default,
                options: [.defaultToSpeaker, .mixWithOthers]
            )

            try audioSessao.setActive(true)

            let entrada = audioEngine.inputNode
            let formato = entrada.outputFormat(forBus: 0)

            let novaRequisicao = SFSpeechAudioBufferRecognitionRequest()
            novaRequisicao.shouldReportPartialResults = true

            requisicao = novaRequisicao

            entrada.installTap(
                onBus: 0,
                bufferSize: 1024,
                format: formato
            ) { buffer, _ in
                novaRequisicao.append(buffer)
            }

            instalouTap = true

            tarefaReconhecimento = reconhecedor.recognitionTask(
                with: novaRequisicao
//            ) { [weak self] resultado, erro in
//
//                guard let self else { return }
//
//                if let resultado {
//                    let texto = resultado.bestTranscription.formattedString
//                    self.verificarComando(texto)
//                    
//                    if resultado.isFinal{
//                        DispatchQueue.main.async{
//                            self.reiniciarReconhecimento()
//                        }
//                    }
//                }
//
//                if erro != nil {
//                    DispatchQueue.main.async {
//                        self.pararEscuta()
//                    }
//                }
//            }
            ) { [weak self] resultado, erro in

                guard let self else { return }

                if let erro {
                    print("Erro no reconhecimento: \(erro.localizedDescription)")

                    DispatchQueue.main.async {
                        self.pararEscuta()
                    }

                    return
                }

                if let resultado {
                    let texto = resultado.bestTranscription.formattedString
                    self.verificarComando(texto)

                    if resultado.isFinal {
                        DispatchQueue.main.async {
                            self.reiniciarReconhecimento()
                        }
                    }
                }
            }

            audioEngine.prepare()
            try audioEngine.start()

            estaEscutando = true
            comandoDetectado = false

            print("Reconhecimento de voz iniciado.")

        } catch {
            print("Erro ao iniciar reconhecimento: \(error.localizedDescription)")
            pararEscuta()
        }
    }
    //se a pessoa falar outra coisa que não seja um comando reconhecido, o aplicativo volta a escutar.
    private func reiniciarReconhecimento() {
        guard estaEscutando else { return }
        guard !comandoDetectado else { return }

        pararEscuta()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.iniciarReconhecimento()
        }
    }

    
    // verifica se a pessoa solicitou um feedback.
    private func verificarComando(_ texto: String) {

        guard !comandoDetectado else { return }

        let textoNormalizado = texto
            .lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)

        let comandos = [
            "quero um feedback",
            "quero feedback",
            "verifique minha maquiagem",
            "verificar minha maquiagem",
            "verificar a minha maquiagem",
            "verificar maquiagem",
            "preciso de um feedback"
        ]

        guard comandos.contains(where: { textoNormalizado.contains($0) }) else {
            return
        }

        comandoDetectado = true

        print("Comando de feedback reconhecido.")

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            let acao = self.aoReconhecerComando

            self.pararEscuta()
            acao?()
        }
    }

    //interrompe a captura de áudio e o reconhecimento.
    func pararEscuta() {

        estaEscutando = false

        if audioEngine.isRunning {
            audioEngine.stop()
        }

        if instalouTap {
            audioEngine.inputNode.removeTap(onBus: 0)
            instalouTap = false
        }

        requisicao?.endAudio()
        tarefaReconhecimento?.cancel()

        requisicao = nil
        tarefaReconhecimento = nil

        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )
    }
}
