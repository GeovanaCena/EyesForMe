//
//  SwiftUIView.swift
//  EyesForMe
//
//  Created by Maria Izabelle Holanda de Andrade on 11/11/26.
//

import SwiftUI

struct TelaPrincipal: View {

    @StateObject private var permissionVM = CameraPermissionViewModel()
    @Environment(\.openURL) private var openURL

    @State private var abrirCamera = false
    @State private var mostrarAviso = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                Button {
                    Task {//colcoquei para pedir a permissao aqi
                        await permissionVM.checkPermission()

                        if permissionVM.status == .authorized {
                            abrirCamera = true
                        } else {
                            mostrarAviso = true
                        }
                    }
                } label: {
                    Text("Apertar")
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .accessibilityLabel("abrir a câmera")
                }
                .navigationDestination(isPresented: $abrirCamera) {
                    CameraFrontal()
                }
            }
            .alert("Câmera necessária", isPresented: $mostrarAviso) {
                if permissionVM.status == .denied {
                    Button("Abrir Ajustes") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                }
                Button("Agora não", role: .cancel) { }
            } message: {
                Text(mensagemDoAviso)
            }
        }
    }

    private var mensagemDoAviso: String {
        if permissionVM.status == .restricted {
            return "A câmera está bloqueada neste aparelho, por exemplo por controle parental. Ela é fundamental para o app funcionar."
        } else {
            return "A câmera é fundamental para o app funcionar, porque é ela que te orienta sobre a posição do seu rosto. Permita o acesso nos Ajustes do iPhone para continuar."
        }
    }
}

#Preview {
    TelaPrincipal()
}
