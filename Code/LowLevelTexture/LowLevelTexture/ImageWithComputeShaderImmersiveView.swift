//
//  ImageWithComputeShaderImmersiveView.swift
//  MPSAndCIFilterOnVisionOS
//
//  Created by 许M4 on 2025/6/18.
//

import SwiftUI
import RealityKit
import RealityKitContent
import MetalKit

struct ImageWithComputeShaderImmersiveView: View {
    @Environment(AppModel.self) private var model
    let mtlDevice = MTLCreateSystemDefaultDevice()!

   
    var body: some View {
        RealityView { content in

            let entity = Entity()
            entity.name = "GameRoot"
            model.rootEntity = entity
            content.add(entity)

            do {
                let textureLoader = MTKTextureLoader(device: mtlDevice)
                let inTexture = try await textureLoader.newTexture(name: "Shop_L", scaleFactor: 1, bundle: nil)

                // Create a descriptor for the LowLevelTexture.
                let textureDescriptor = createTextureDescriptor(width: inTexture.width, height: inTexture.height)
                // Create the LowLevelTexture and populate it on the GPU.
                let llt = try LowLevelTexture(descriptor: textureDescriptor)

                populateWithComputeShader(inTexture: inTexture, lowLevelTexture: llt, device: mtlDevice)

                // Create a TextureResource from the LowLevelTexture.
                let resource = try await TextureResource(from: llt)
                // Create a material that uses the texture.
                let material = UnlitMaterial(texture: resource)

                // Return an entity of a plane which uses the generated texture.
                let entity1 = ModelEntity(mesh: .generatePlane(width: 1, height: 1), materials: [material])
                entity.addChild(entity1)
                entity1.position = SIMD3(x: 0, y: 1, z: -2)


                // Create a shader graph material that uses the texture.
                var shaderGraphMaterial = try await ShaderGraphMaterial(named: "/Root/GridMaterial", from: "Materials/GridMaterial.usda", in: realityKitContentBundle)
                try shaderGraphMaterial.setParameter(name: "BaseImage", value: .textureResource(resource))

                // Return an entity of a plane which uses the generated texture.
                let entity2 = ModelEntity(mesh: .generatePlane(width: 1, height: 1), materials: [shaderGraphMaterial])
                entity.addChild(entity2)
                entity2.position = SIMD3(x: -1.2, y: 1, z: -2)

                model.inTexture = inTexture
                model.lowLevelTexture = llt
            } catch {
                print(error)
            }

        }
        .onChange(of: model.blurRadius) { oldValue, newValue in
            guard model.inTexture != nil && model.lowLevelTexture != nil else {
                return
            }
            populateWithComputeShader(inTexture: model.inTexture!, lowLevelTexture: model.lowLevelTexture!, device: mtlDevice)

        }


    }

    func createTextureDescriptor(width: Int, height: Int) -> LowLevelTexture.Descriptor {
        var desc = LowLevelTexture.Descriptor()

        desc.textureType = .type2D
        desc.arrayLength = 1

        desc.width = width
        desc.height = height
        desc.depth = 1

        desc.mipmapLevelCount = 1
        desc.pixelFormat = .bgra8Unorm
        desc.textureUsage = [.shaderRead, .shaderWrite]
        desc.swizzle = .init(red: .red, green: .green, blue: .blue, alpha: .alpha)

        return desc
    }


    func populateWithComputeShader(inTexture: MTLTexture, lowLevelTexture: LowLevelTexture, device: MTLDevice) {

        // Set up the Metal command queue and compute command encoder
        guard let commandQueue = device.makeCommandQueue(),
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder() else {
            print("❌ Failed to create command queue or encoder")
            return
        }

        // Create or retrieve the compute pipeline state
        guard let pipelineState = model.getPipeline(device: device) else {
            print("❌ Failed to get pipeline state")
            return
        }

        // Get the final output texture from LowLevelTexture
        let outTexture = lowLevelTexture.replace(using: commandBuffer)

        // Set blur radius parameter
        var blurRadius = Float(model.blurRadius)

        // Calculate threadgroup and grid sizes
        let threadgroupSize = MTLSize(width: 16, height: 16, depth: 1)
        let gridWidth = (inTexture.width + threadgroupSize.width - 1) / threadgroupSize.width
        let gridHeight = (inTexture.height + threadgroupSize.height - 1) / threadgroupSize.height
        let gridSize = MTLSize(width: gridWidth, height: gridHeight, depth: 1)

        // Configure the compute pipeline
        computeCommandEncoder.setComputePipelineState(pipelineState)

        // Set input texture
        computeCommandEncoder.setTexture(inTexture, index: 0)

        // Set output texture
        computeCommandEncoder.setTexture(outTexture, index: 1)

        // Set blur radius parameter
        computeCommandEncoder.setBytes(&blurRadius, length: MemoryLayout<Float>.size, index: 0)

        // Dispatch the compute shader
        computeCommandEncoder.dispatchThreadgroups(gridSize, threadsPerThreadgroup: threadgroupSize)

        // End encoding
        computeCommandEncoder.endEncoding()

        // Commit the command buffer and wait for completion
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}

#Preview {
    ImageWithComputeShaderImmersiveView()
}

