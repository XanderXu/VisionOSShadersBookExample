//
//  ContentView.swift
//  LowLevelTexture
//
//  Created by 许同学 on 2026/2/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @State private var selectedModule: Module = .imageWithCIFilter
    
    @Environment(AppModel.self) private var model
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    var body: some View {
        @Bindable var model = model
        HStack(alignment: .center, spacing: 10) {
            Spacer()
            VStack {
                VStack(alignment: .center, spacing: 10) {
                    Picker("SelectedModule", selection: $selectedModule) {
                        ForEach(Module.allCases) { module in
                            Text(module.name).tag(module)
                        }
                    }
                    .pickerStyle(.segmented)
                    Toggle("Turn on Immersive Space", isOn: $model.turnOnImmersiveSpace)
                        .toggleStyle(ButtonToggleStyle())
                        .font(.system(size: 16, weight: .bold))
                        .padding(.bottom, 40)
                    
                }
                Text("Blur Radius: \(Int(model.blurRadius).formatted())")
                Slider(value: $model.blurRadius, in: 0...50, step: 5) {
                    Text("Blur Radius: \(model.blurRadius)")
                }
            }
            Spacer()
        }.frame(width: 600, height: 400)
        .onChange(of: selectedModule) { _, newValue in
            Task {
                if model.turnOnImmersiveSpace {
                    model.turnOnImmersiveSpace = false
                }
            }
        }
        .onChange(of: model.turnOnImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    await openImmersiveSpace(id: selectedModule.immersiveId)
                } else {
                    await dismissImmersiveSpace()
                    model.reset()
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
