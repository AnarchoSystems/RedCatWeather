//
//  CityRequestResolver.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 14.05.21.
//

import Foundation


protocol CityRequestResolver {
    
    func getNumberOfPossibleCities(withPrefix prefix: String,
                                   response: @escaping (Result<Int, NSError>) -> Void)
    
    func getPossibleCities(withPrefix prefix: String,
                           indices: [Int],
                           response: @escaping ([Result<String, NSError>]) -> Void)
    
}


struct MockCityResolver : CityRequestResolver {
    
    let delay : DebugDelay
    
    func getNumberOfPossibleCities(withPrefix prefix: String,
                                   response: @escaping (Result<Int, NSError>) -> Void) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(.random(in: delay.delayMs))) {
            response(.success(cities.filter {$0.hasPrefix(prefix)}.count))
        }
        
    }
    
    func getPossibleCities(withPrefix prefix: String,
                           indices: [Int],
                           response: @escaping ([Result<String, NSError>]) -> Void) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(.random(in: delay.delayMs))) {
            let validCities = cities.filter {$0.hasPrefix(prefix)}
            response(indices.map {idx in
                validCities.indices.contains(idx) ?
                    .success(validCities[idx]) :
                    .failure(.cityNotFound())
            })
        }
        
    }
    
    
    var cities : [String] {
        // arbitrary capitals of EU countries
        ["Berlin", "Paris", "Madrid",
         "Warsaw", "Rome", "Athens",
         "Brussels", "Lisbon", "Budapest",
         "Vienna", "Vilnius", "Copenhagen",
         "Stockholm", "Dublin", "Zagreb", ].sorted()
    }
    
}

extension CityRequestResolver {
    func cached() -> CachedCityResolver {
        CachedCityResolver(self)
    }
}

class CachedCityResolver : CityRequestResolver {
    
    let maxValsPerPrefix = 20
    let queue = DispatchQueue(label: "CacheQueue")
    var numDict : [String : Int] = [:]
    var prefixDict : [String : (values: [Result<String, NSError>], lastRequested: Date)] = [:]
    let wrapped : CityRequestResolver
    
    init(_ wrapped: CityRequestResolver) {
        self.wrapped = wrapped
    }
    
    func getNumberOfPossibleCities(withPrefix prefix: String, response: @escaping (Result<Int, NSError>) -> Void) {
        
        queue.async {
            if let count = self.countFromPrefix(prefix) {
                response(.success(count))
            }
            else if let result = self.tryRespondFromCache(withPrefix: prefix,
                                                     indices: Array(0..<self.maxValsPerPrefix)) {
                response(.success(result.lazy.filter(\.isSuccess).count))
            }
            else {
                self.wrapped.getNumberOfPossibleCities(withPrefix: prefix) {result in
                    if case .success(let count) = result {
                        self.queue.async {
                            self.numDict[prefix] = count
                        }
                    }
                    response(result)
                }
            }
        }
        
    }
    
    func getPossibleCities(withPrefix prefix: String,
                           indices: [Int],
                           response: @escaping ([Result<String, NSError>]) -> Void) {
        
        queue.async {
            if let result = self.tryRespondFromCache(withPrefix: prefix, indices: indices) {
                response(result)
            }
            else if let count = self.countFromPrefix(prefix) {
                
                if count == 0 {
                    response(Array(repeating: .failure(.cityNotFound()), count: indices.count))
                }
                else if count < self.maxValsPerPrefix {
                    self.wrapped.getPossibleCities(withPrefix: prefix, indices: Array(0..<count)) {result in
                        self.queue.async {
                            self.updatePrefixDict(prefix: prefix, values: result)
                            response(indices.map {
                                result.indices.contains($0) ?
                                    result[$0] :
                                    .failure(.cityNotFound())
                            })
                        }
                    }
                }
                else {
                    self.wrapped.getPossibleCities(withPrefix: prefix, indices: indices, response: response)
                }
                
            }
            else {
                self.wrapped.getPossibleCities(withPrefix: prefix, indices: indices, response: response)
            }
        }
        
    }
    
    func countFromPrefix(_ prefix: String) -> Int? {
        
        if let result = numDict[prefix] {
            return result
        }
        else {
            let original = prefix
            var prefix = prefix
            
            while numDict[prefix] == nil {
                if prefix == "" {break}
                prefix = String(prefix.dropLast())
            }
            
            if
                let number = numDict[prefix],
                number == 0 {
                numDict[original] = 0
                return 0
            }
            return nil
        }
    }
    
    func tryRespondFromCache(withPrefix prefix: String,
                             indices: [Int]) -> [Result<String, NSError>]? {
        
        let original = prefix
        var prefix = prefix
        
        while prefixDict[prefix] == nil || prefixDict[prefix]!.values.contains(where: \.isFailure) {
            if prefix == "" {break}
            prefix = String(prefix.dropLast())
        }
        
        if let (values, _) = self.prefixDict[prefix],
           let unwrapped = try? values.map({try $0.get()}) {
            self.prefixDict[prefix]?.lastRequested = Date()
            let okValues = unwrapped.filter {$0.hasPrefix(original)}
            numDict[original] = okValues.count
            return indices.map {
                okValues.indices.contains($0) ?
                    .success(okValues[$0]) :
                    .failure(.cityNotFound())
            }
        }
        else {
            return nil
        }
        
    }
    
    func updatePrefixDict(prefix: String, values: [Result<String, NSError>]) {
        
        queue.async {
            let now = Date()
            self.prefixDict[prefix].modify(default: (values, now)) {
                (oldValues) in
                
                for (idx, newValue) in values.enumerated() where oldValues.values[idx].isFailure {
                    oldValues.values[idx] = newValue
                }
                
                oldValues.lastRequested = now
                
            }
            if self.prefixDict.count > 1000 {
                let okPairs = self.prefixDict
                    .sorted(accordingTo: \.value.lastRequested)
                    .prefix(300)
                    .lazy.map {key, value in (key, value)}
                self.prefixDict = Dictionary(okPairs,
                                             uniquingKeysWith: {print("Something strange is going on..."); return $1})
            }
        }
        
    }
    
}


extension NSError {
    
    static func cityNotFound() -> NSError {
        NSError(domain: "cityRequestError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey : "Item not found"])
    }
    
}


extension Optional {
    
    mutating func modify(default defaultValue: Wrapped?, closure: (inout Wrapped) -> Void) {
        guard var value = self else {
            self = defaultValue
            return
        }
        self = nil
        closure(&value)
        self = value
    }
    
}

extension Result {
    var isSuccess : Bool {
        !isFailure
    }
    var isFailure : Bool {
        switch self {
        case .success:
            return false
        case .failure:
            return true
        }
    }
}

extension Collection {
    func sorted<T : Comparable>(accordingTo value: (Element) -> T) -> [Element] {
        sorted(by: {value($0) < value($1)})
    }
}
