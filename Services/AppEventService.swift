//
//  AppEventService.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 12.06.21.
//

import RedCat


final class AppEventService : Service<AppState, AppAction> {
    
    override func onAppInit(store: Store<AppState, AppAction>, environment: Dependencies) {
        store.send(.appInit)
    }
    
    override func onShutdown(store: Store<AppState, AppAction>, environment: Dependencies) {
        store.send(.shutdown)
    }
    
}
