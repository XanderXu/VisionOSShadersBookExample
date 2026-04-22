//
//  AppModel.swift
//  LowLevelTexture
//
//  Created by 许同学 on 2026/2/24.
//

import SwiftUI
import RealityKit

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    var rootEntity: Entity?
    var turnOnImmersiveSpace = false
    var blurRadius: Float = 10
    var inTexture: MTLTexture?
    var lowLevelTexture: LowLevelTexture?
    
    var pipelineState: MTLComputePipelineState?

    func getPipeline(device: MTLDevice) -> MTLComputePipelineState? {
        if pipelineState == nil {
            guard let library = try? device.makeDefaultLibrary(bundle: Bundle.main) else {
                print("Failed to create shader library")
                return nil
            }

            guard let kernelFunction = library.makeFunction(name: "gaussianBlurKernel") else {
                print("Failed to find kernel function")
                return nil
            }

            pipelineState = try? device.makeComputePipelineState(function: kernelFunction)

            if pipelineState == nil {
                print("Failed to create pipeline state")
                return nil
            }

            print("✅ Pipeline state created successfully")
        }

        return pipelineState
    }
    
    func clear() {
        rootEntity?.children.removeAll()
        inTexture = nil
        lowLevelTexture = nil
    }
    
    /// Resets game state information.
    func reset() {
        debugPrint(#function)
        
        blurRadius = 10
        clear()
    }
}

/// A description of the modules that the app can present.
enum Module: String, Identifiable, CaseIterable, Equatable {
    case imageWithCIFilter
    case imageWithMPS
    case imageWithComputeShader


    var id: Self { self }
    var name: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }

    var immersiveId: String {
        self.rawValue + "ID"
    }

}
