//
//  SlowInternetWarning.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 14.05.21.
//

import Foundation
import RedCat


enum SlowInternetWarnDescription : Config {
    static func value(given: Dependencies) -> SlowInternetWarning {
        if given.nativeValues.debug {
            return SlowInternetWarning(hint: "Change debugDelay in AppState.makeStore()")
        }
        else {
            return SlowInternetWarning(hint: "Please connect to WLAN.")
        }
    }
}

struct SlowInternetWarning {
    let hint : String
    func makeNSError() -> NSError {
        NSError(domain: "SlowInternetDomain",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey : "Your internet connection appears to be slow.",
                           NSLocalizedRecoverySuggestionErrorKey : hint])
    }
}


extension Dependencies {
    var slowInternetWarning : SlowInternetWarning {
        self[SlowInternetWarnDescription.self]
    }
}
