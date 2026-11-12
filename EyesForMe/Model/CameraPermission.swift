//
//  CameraPermission.swift
//  EyesForMe
//
//  Created by Geovana Cena de Albuquerque on 11/11/26.
//

import AVFoundation
 
enum CameraPermissionStatus{
    case authorized
    case denied
    case restricted
    
}



func checkCameraPermission() async -> CameraPermissionStatus {
    
    let systemStatus =  AVCaptureDevice.authorizationStatus(for: .video)
    
    switch systemStatus {
    case .restricted:
        return .restricted
    case .notDetermined:
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        
        if granted{
            return .authorized
        }else{
            return .denied
        }
    case .denied:
        return .denied
    case .authorized:
        return .authorized
    
    }
    
}
