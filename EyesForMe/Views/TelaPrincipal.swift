//
//  SwiftUIView.swift
//  EyesForMe
//
//  Created by Maria Izabelle Holanda de Andrade on 11/11/26.
//


import SwiftUI

struct TelaPrincipal: View {

    @State private var abrirCamera = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                Button {
                    abrirCamera = true
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
        }
    }
}

#Preview {
    TelaPrincipal()
}
