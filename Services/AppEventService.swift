//
//  AppEventService.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 12.06.21.
//

import RedCat


final class AppEventService : DetailService<AppState, Dummy, AppAction> {
    
    init() {
        super.init {_ in Dummy()}
    }
    
    override func onAppInit() {
        store.send(.appInit)
    }
    
    override func onShutdown() {
        store.send(.shutdown)
    }
    
}

// ok, we *do* need a way to subclass Service without subclassing DetailService
struct Dummy : Equatable {}
