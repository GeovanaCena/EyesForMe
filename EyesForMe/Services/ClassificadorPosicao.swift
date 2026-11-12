//
//  ClassificadorPosicao.swift
//  EyesForMe
//
//  Created by Geovana Cena de Albuquerque on 12/11/26.
//


import CoreGraphics // para ferramentas e medidas ( pata determinar as medidas na tela

struct ClassificadorPosicao {

    struct Config {
        // determina o tamanho do rosto na tela para saber como tra
        var larguraMinima: CGFloat = 0.30 // aqui ta longe demais tipo o rsto ta longe entao o tamanho dele ta pequeno
        var larguraMaxima: CGFloat = 0.75 // aqui o rosto ta muito perto da tela por isso ta grande
        var toleranciaCentro: CGFloat = 0.12 // aqui fala o quanto pode sair do centro da tela para a pessoa nao ficar parada totalmemnte
        var margemBorda: CGFloat = 0.02 // / se o rosto tiver muito perto da borda quase cortando
        var visivelMinimo: CGFloat = 0.30 // ta fora da tela ou boa parte fora da tela
    }

    var config = Config()

    func classificar(_ rosto: CGRect?) -> PosicaoRosto { // o gcreact para determnar um retangulo para o rosto
        
        // aqui tem um caixinha ora cada estado que o rosto pode ficar
        guard let rosto, rosto.width > 0, rosto.height > 0 else { // ta na tela ?
            return .foraDoCampo
        }
        let tela = CGRect(x: 0, y: 0, width: 1, height: 1) // se ta o suficiente na tela
        let visivel = rosto.intersection(tela)
        let areaVisivel = visivel.isNull ? 0 : visivel.width * visivel.height
        
        if areaVisivel / (rosto.width * rosto.height) < config.visivelMinimo {
            return .foraDoCampo
        }
        let m = config.margemBorda // ta cortado 
        let cortes: [(excesso: CGFloat, dir: DirecaoAjuste)] = [
            (m - rosto.minX,         .direita),
            (rosto.maxX - (1 - m),   .esquerda),
            (m - rosto.minY,         .baixo),
            (rosto.maxY - (1 - m),   .cima)
        ]
        
        if let pior = cortes.max(by: { $0.excesso < $1.excesso }), pior.excesso > 0 {
            return .parcial(pior.dir)
        }

        if rosto.width < config.larguraMinima { return .parcial(.aproximar) }
        if rosto.width > config.larguraMaxima { return .parcial(.afastar) }

        let dx = rosto.midX - 0.5   // >0: rosto à direita na tela
        let dy = rosto.midY - 0.5   // >0: rosto embaixo na tela
        let t = config.toleranciaCentro

        if abs(dx) > t || abs(dy) > t {
            if abs(dx) >= abs(dy) {
                return .parcial(dx > 0 ? .esquerda : .direita)
            } else {
                return .parcial(dy > 0 ? .cima : .baixo)
            }
        }

        return .correta
    }
}
