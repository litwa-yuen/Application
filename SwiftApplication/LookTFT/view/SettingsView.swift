//
//  SettingsView.swift
//  Look TFT
//
//  Created by Lit Wa Yuen on 3/9/20.
//  Copyright © 2020 Lit Wa Yuen. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
        
    
    @State private var selectedRegion = regionIndex
   
    
    var body: some View {
        Form {
            Section {
                Picker(selection: $selectedRegion.onChange(regionChange), label: Text("Region")) {
                    ForEach(0 ..< regionTuples.count) {
                        Text(regionTuples[$0])
                    }
                }
            }
        }.onAppear {
            self.selectedRegion = regionIndex
        }.navigationBarTitle("Settings")
        
    }
    
    
    func regionChange(_ tag: Int) {
        region = regionIndexStringMap[tag]!
        regionIndex = tag
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}

