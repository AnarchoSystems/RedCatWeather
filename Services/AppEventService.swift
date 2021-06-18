//
//  AppEventService.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 12.06.21.
//

import RedCat


final class AppEventService : RedCat.AppEventService<AppState, AppAction> {
    
    override func onAppInit() {
        store.send(.appInit)
    }
    
    override func onShutdown() {
        store.send(.shutdown)
    }
    
}
