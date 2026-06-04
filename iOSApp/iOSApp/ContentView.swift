//
//  ContentView.swift
//  iOSApp
//
//  Created by JAVIER CALATRAVA LLAVERIA on 4/6/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                Text("Version: \(CoreCWrapper.fetchVersion())")
                .font(.title)
                .bold()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
