//
//  AppEventService.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 12.06.21.
//

import RedCat


final class AppEventService : RedCat.AppEventService<AppState, AppAction> {
    
    func onAppInit() {
        store.send(.appInit)
    }
    
    func onShutdown() {
        store.send(.shutdown)
    }
    
}
