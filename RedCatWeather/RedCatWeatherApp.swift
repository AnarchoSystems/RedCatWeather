//
//  RedCatWeatherApp.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 12.05.21.
//

import SwiftUI
import RedCat


@main
struct RedCatWeatherApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(delegate.store)
        }
    }
}


class AppDelegate : NSObject, UIApplicationDelegate {
    
    let store : CombineStore<AppState, AppAction> = AppState.makeStore()
    
    func applicationWillTerminate(_ application: UIApplication) {
        store.shutDown()
    }
    
}
