//
//  ContentView.swift
//  GreatApp
//
//  Created by Geovana Cena de Albuquerque on 06/11/26.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var permissionVM = CameraPermissionViewModel()
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            switch permissionVM.status {
            case nil:
                Text("Verificando a permissão da câmera.")

            case .authorized:
                // Aqui entra a tela principal do Dev 2
                Text("Câmera liberada. Tudo pronto para começar.")

            case .denied:
                VStack(spacing: 16) {
                    Text("O acesso à câmera foi negado. Para usar o app, permita a câmera nos Ajustes do iPhone.")
                        .multilineTextAlignment(.center)
                    Button("Abrir Ajustes") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                }

            case .restricted:
                Text("A câmera está bloqueada neste aparelho, por exemplo por controle parental, e o app não consegue pedir acesso.")
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .task {
            await permissionVM.checkPermission()
        }
        // Quando a pessoa volta dos Ajustes, checa de novo (iOS 17 ou mais novo)
        .onChange(of: scenePhase) { _, novaFase in
            if novaFase == .active {
                Task { await permissionVM.checkPermission() }
            }
        }
    }
}
#Preview {
    ContentView()
}
