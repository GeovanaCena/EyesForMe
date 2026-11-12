//
//  DetectorFacial.swift
//  EyesForMe
//
//  Created by Geovana Cena de Albuquerque on 12/11/26.


import Vision
import CoreVideo
import CoreGraphics
import ImageIO

final class DetectorFacial {
    
    var flashLigado = false // so detctar se o flah tove ligado
    var orientacao: CGImagePropertyOrientation = .leftMirrored // aqui avisa o vison pra qu lado a tela esta virada

    func detectar(_ frame: CVPixelBuffer) -> CGRect? {

        guard flashLigado else { return nil }

        let pedido = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(
            cvPixelBuffer: frame,
            orientation: orientacao,
            options: [:]
        )

        do {
            try handler.perform([pedido])
        } catch {
            return nil
        }

        guard let maior = pedido.results?.max(by: { // aqi vao ser se tiver mais de um rosto oq tiver mais perto da camera no caso o maior é o que vai detectar
            $0.boundingBox.width * $0.boundingBox.height <
            $1.boundingBox.width * $1.boundingBox.height
        }) else {
            return nil
        }

        return Self.converter(maior.boundingBox)
    }

    /// o vision usa um jeito difernete de posicionamento = origem embaixo à esquerda e o nosso  em cima à esquerda isso aqui converte eles
    static func converter(_ visionRect: CGRect) -> CGRect {
        CGRect(
            x: visionRect.minX,
            y: 1 - visionRect.maxY,
            width: visionRect.width,
            height: visionRect.height
        )
    }
}
 
