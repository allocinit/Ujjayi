//
//  UjjayiApp.swift
//  Ujjayi
//
//  Created by Aleksandr Borisov on 04.02.2022.
//

import SwiftUI

@main
struct UjjayiApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(ViewModel())
                .onDisappear {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
        }
    }
}
