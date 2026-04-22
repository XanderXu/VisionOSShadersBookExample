//
//  LowLevelTextureApp.swift
//  LowLevelTexture
//
//  Created by 许同学 on 2026/2/24.
//

import SwiftUI

@main
struct LowLevelTextureApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }

        .windowResizability(.contentSize)
//        .defaultSize(width: 1, height: 0.6, depth: 0.1, in: .meters)

        ImmersiveSpace(id: Module.imageWithCIFilter.immersiveId) {
            ImageWithCIFilterImmersiveView()
                .environment(appModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
        
        ImmersiveSpace(id: Module.imageWithMPS.immersiveId) {
            ImageWithMPSImmersiveView()
                .environment(appModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)

        ImmersiveSpace(id: Module.imageWithComputeShader.immersiveId) {
            ImageWithComputeShaderImmersiveView()
                .environment(appModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
     }
}
