//
//  CameraPermissionViewModel.swift
//  EyesForMe
//
//  Created by Geovana Cena de Albuquerque on 11/11/26.
//

import SwiftUI
import Combine

@MainActor
class CameraPermissionViewModel : ObservableObject {
    @Published var status : CameraPermissionStatus? = nil
    
    func checkPermission() async {
        status = await checkCameraPermission()
    }
    
}
