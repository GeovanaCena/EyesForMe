//
//  PosicaoRosto.swift
//  EyesForMe
//
//  Created by Geovana Cena de Albuquerque on 12/11/26.
//

import Foundation

enum DirecaoAjuste : Equatable{
    case esquerda
    case direita
    case cima
    case baixo
    case aproximar
    case afastar
}
enum PosicaoRosto: Equatable {
    case foraDoCampo
    case parcial(DirecaoAjuste)
    case correta
}
