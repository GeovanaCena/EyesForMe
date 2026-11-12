//
//  ContentView.swift
//  GreatApp
//
//  Created by Geovana Cena de Albuquerque on 06/11/26.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!") // voltei a 1 versao pq aqui eu tava colcoando a permissao como primeiro e agora a tela principal que e a 1 tela 
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
