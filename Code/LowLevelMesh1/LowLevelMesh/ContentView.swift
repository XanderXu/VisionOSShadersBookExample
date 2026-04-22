//
//  ContentView.swift
//  LowLevelMesh
//
//  Created by 许同学 on 2026/2/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    var body: some View {
        VStack {
            Text("Hello, LowLevelMesh!")
                .font(.title)

//            Text("https://github.com/XanderXu/RealityComputeShader_Flag")
//                .font(.title2)
//                .foregroundStyle(.white)
//                .underline(true,pattern: .solid)
//                .padding(.bottom)

            ToggleImmersiveSpaceButton()
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
