//
//  Camera_frontal.swift
//  EyesForMe
//
//  Created by Maria Izabelle Holanda de Andrade on 11/11/26.
//

import SwiftUI
import AVFoundation

struct CameraFrontal: View {
    
    @StateObject private var viewModel = CameraViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack {
                
                Color.black
                    .ignoresSafeArea()
                
                ScreenBrightnessManager { screen in
                    viewModel.configurarTela(screen)
                }
                .frame(width: 0, height: 0 )
                
                VStack(spacing: 25) {
                    
                    
                    
                    // Câmera frontal
                    CameraPreview(session: viewModel.camera.session)
                        .frame(
                            width: max(0, geometry.size.width - 10),
                            height: max(0, geometry.size.height * 0.85)
                        )
                        .clipShape(
                            RoundedRectangle(cornerRadius: 25)
                        )
                        .accessibilityLabel("Visualização da câmera frontal")
                        .accessibilityHint("A câmera frontal está sendo utilizada pelo aplicativo")
                        .overlay {
                            ZStack{
                                // Moldura luminosa
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(
                                        Color.white.opacity(viewModel.intensidade),
                                        lineWidth: 18
                                    )
                                    .shadow(
                                        color: .white.opacity(viewModel.intensidade),
                                        radius: 15
                                    )
                                    .shadow(
                                        color: .white.opacity(viewModel.intensidade * 0.6),
                                        radius: 30
                                    )
                                
                                VStack{
                                    Spacer()
                                    
                                    // Controle da iluminação
                                    VStack(spacing: 12) {
                                        
                                        Text("Intensidade da iluminação")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Slider(value: $viewModel.intensidade, in: 0...1)
                                            .tint(.white)
                                            .accessibilityLabel("Intensidade da iluminação")
                                            .accessibilityValue("\(Int(viewModel.intensidade * 100)) por cento")
                                            .accessibilityHint("Deslize para ajustar a intensidade da iluminação")
                                    }
                                    .padding(15)
                                    .background(Color.black.opacity(0.6))
                                    .cornerRadius(15)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 20)
                                    
                                    
                                    //so pra testar, dps apagr os dois botoes
                                    Button {
                                        viewModel.testarFalasRepetidas()
                                    } label: {
                                        Text("Apertar")
                                            .fontWeight(.bold)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                            .accessibilityLabel("abrir a câmera")
                                    }
                                    
                                    Button("Testar som de confirmação") {
                                        viewModel.testarSomConfirmacao()
                                    }
                                    
                                    Button("Testar orientação por voz") {
                                        viewModel.falarOrientacao(
                                            CameraVoiceMessages.rostoNaoDetectado
                                        )
                                    }
                                    
                                }
                                
                            }
                        }
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            
            // Inicializa a câmera
            viewModel.iniciarCamera()
        }
        .onDisappear {
            // Interrompe a câmera
            viewModel.encerrarCamera()
        }
        .onChange(of: scenePhase){ _,
            novaFase in
            viewModel.atualizarEstado(novaFase)
        }
    }
}



#Preview {
    NavigationStack{
        CameraFrontal()
    }
    
}
