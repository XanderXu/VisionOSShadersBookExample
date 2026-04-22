//
//  ImmersiveView.swift
//  RealityKitNode
//
//  Created by 许同学 on 2026/2/11.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)

                if let hoverEntity = immersiveContentEntity.findEntity(named: "HoverEffect") {
                    let collisionComponent = CollisionComponent(
                        shapes: [ShapeResource.generateBox(size: [0.2, 0.2, 0.2])],
                    )
                    let inputTargetComponent = InputTargetComponent()
                    let hoverEffectComponent = HoverEffectComponent(.shader(
                        HoverEffectComponent.ShaderHoverEffectInputs(
                            fadeInDuration: 1.0, fadeOutDuration: 1.0
                        )
                    ))
                    hoverEntity.components.set([collisionComponent, inputTargetComponent, hoverEffectComponent])
                }
                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
