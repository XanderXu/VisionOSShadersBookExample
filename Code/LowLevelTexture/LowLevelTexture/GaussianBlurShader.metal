//
//  GaussianBlurShader.metal
//  MPSAndCIFilterOnVisionOS
//
//  Created by 许M4 on 2025/6/18.
//

#include <metal_stdlib>
using namespace metal;

// Gaussian blur kernel with dynamic kernel size
kernel void gaussianBlurKernel(texture2d<float, access::read> inTexture [[texture(0)]],
                              texture2d<float, access::write> outTexture [[texture(1)]],
                              constant float &blurRadius [[buffer(0)]],
                              uint2 gid [[thread_position_in_grid]]) {

    // Check if the current thread is within the texture bounds
    if (gid.x >= outTexture.get_width() || gid.y >= outTexture.get_height()) {
        return;
    }

    // If blur radius is very small, just copy the input
    if (blurRadius <= 1) {
        float4 color = inTexture.read(gid);
        outTexture.write(color, gid);
        return;
    }

    // Calculate kernel size (ensure it's odd and within reasonable bounds)
    const int maxKernelSize = 101;  // Maximum kernel size to avoid performance issues
    int kernelSize = min(int(blurRadius*2+1), maxKernelSize);

//    // Ensure kernel size is odd
//    if (kernelSize % 2 == 0) {
//        kernelSize++;
//    }

    const int radius = kernelSize;

    // Apply Gaussian blur with weights calculated on-the-fly
    float4 blurredColor = float4(0.0);
    float weightSum = 0.0;

    // Use blurRadius as sigma for Gaussian distribution
    const float sigma = blurRadius;

    for (int y = -radius; y <= radius; y++) {
        for (int x = -radius; x <= radius; x++) {
            int2 samplePos = int2(gid.x + x, gid.y + y);

            // Handle boundary conditions by clamping
            samplePos.x = clamp(samplePos.x, 0, int(inTexture.get_width()) - 1);
            samplePos.y = clamp(samplePos.y, 0, int(inTexture.get_height()) - 1);

            // Calculate Gaussian weight
            float distance = sqrt(float(x * x + y * y));
            float weight = exp(-(distance * distance) / (2.0 * sigma * sigma));

            float4 sampleColor = inTexture.read(uint2(samplePos));
            blurredColor += sampleColor * weight;
            weightSum += weight;
        }
    }

    // Normalize by the sum of weights
    blurredColor /= weightSum;

    // Write the blurred result
    outTexture.write(blurredColor, gid);
}
