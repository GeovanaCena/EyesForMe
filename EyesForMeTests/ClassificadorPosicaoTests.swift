//
//  EyesForMeTests.swift
//  EyesForMeTests
//
//  Created by Geovana Cena de Albuquerque on 12/11/26.
//

import XCTest
import CoreGraphics
@testable import EyesForMe

final class ClassificadorPosicaoTests: XCTestCase {

    let c = ClassificadorPosicao()

    func testSemRosto()            { XCTAssertEqual(c.classificar(nil), .foraDoCampo) }
    func testTotalmenteFora()      { XCTAssertEqual(c.classificar(CGRect(x: 1.2, y: 0.4, width: 0.3, height: 0.3)), .foraDoCampo) }
    func testCentralizado()        { XCTAssertEqual(c.classificar(CGRect(x: 0.3, y: 0.3, width: 0.4, height: 0.4)), .correta) }
    func testLonge()               { XCTAssertEqual(c.classificar(CGRect(x: 0.42, y: 0.42, width: 0.16, height: 0.16)), .parcial(.aproximar)) }
    func testPerto()               { XCTAssertEqual(c.classificar(CGRect(x: 0.05, y: 0.2, width: 0.9, height: 0.6)), .parcial(.afastar)) }
    func testCortadoNaEsquerda()   { XCTAssertEqual(c.classificar(CGRect(x: -0.1, y: 0.3, width: 0.4, height: 0.4)), .parcial(.direita)) }
    func testCortadoNaDireita()    { XCTAssertEqual(c.classificar(CGRect(x: 0.75, y: 0.3, width: 0.4, height: 0.4)), .parcial(.esquerda)) }
    func testCortadoEmCima()       { XCTAssertEqual(c.classificar(CGRect(x: 0.3, y: -0.1, width: 0.4, height: 0.4)), .parcial(.baixo)) }
    func testCortadoEmbaixo()      { XCTAssertEqual(c.classificar(CGRect(x: 0.3, y: 0.75, width: 0.4, height: 0.4)), .parcial(.cima)) }
    func testDescentradoDireita()  { XCTAssertEqual(c.classificar(CGRect(x: 0.5, y: 0.3, width: 0.4, height: 0.4)), .parcial(.esquerda)) }
}
