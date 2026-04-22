//
//  ImmersiveView.swift
//  LowLevelMesh
//
//  Created by 许同学 on 2026/2/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @State private var subscriptions = [EventSubscription]()

    var body: some View {
        RealityView { content in
            
            let tex = try! await TextureResource.init(named: "LowLevelMesh.png", in: nil)
            var material = PhysicallyBasedMaterial()
            material.baseColor = .init(texture: .init(tex))
            material.metallic = .init(floatLiteral: 0.6)
            material.faceCulling = .none
            
            let plane = MeshResource.generatePlane(width: 1, depth: 1)
            let entity = ModelEntity(mesh: plane, materials: [material])
            entity.position = simd_float3(x: -0.5, y: 0.8, z: -1.5)
            entity.name = "flag"
            content.add(entity)
            
            
            
            guard let device = MTLCreateSystemDefaultDevice() else {
                fatalError( "Failed to get the system's default Metal device." )
            }
            let flagSimulation = MetalClothSimulator(device: device)
            flagSimulation.createFlagSimulationFromNode(entity)
            
            let sub = content.subscribe(to: SceneEvents.Update.self) { event in
                flagSimulation.update()
            }
            subscriptions.append(sub)
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
