//
//  CityTextField.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 14.05.21.
//

import SwiftUI
import RedCat



struct CityTextField: UIViewRepresentable {
    
    @EnvironmentObject var store : CombineStore<AppState, AppAction>
    
    func makeUIView(context: Context) -> UITextField {
        let view = UITextField()
        view.textColor = .black
        view.tintColor = .white
        view.backgroundColor = .systemFill
        view.addTarget(context.coordinator,
                       action: #selector(Coordinator.textDidChange),
                       for: .editingChanged)
        view.addTarget(context.coordinator,
                       action: #selector(Coordinator.editingDidEnd),
                       for: .editingDidEndOnExit)
        view.clearsOnInsertion = true
        view.becomeFirstResponder()
        return view
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(store: store)
    }
    
    class Coordinator {
        
        let store : CombineStore<AppState, AppAction>
        
        init(store: CombineStore<AppState, AppAction>) {
            self.store = store
        }
        
        @objc
        func textDidChange(_ textField: UITextField) {
            store.send(.possibleCities(action:.getPossibleCitiesCount(prefix: textField.text ?? "")))
        }
        
        @objc
        func editingDidEnd(_ textField: UITextField) {
            textField.resignFirstResponder()
            guard let inferred = store.state.possibleCities.infer() else {
                return
            }
            store.send(AppAction.showForecastForCity(oldValue: store.state.currentForecast.city,
                                        newValue: inferred))
        }
        
    }
    
}

extension PossibleCities {
    func infer() -> String? {
        guard
            case .resolved(let cities) = requestState,
            cities.list.count == 1,
            let first = cities.list.first,
            case .resolved(let result) = first else {
            return nil
        }
        return result
    }
}

struct CityTextFieldPreview : PreviewProvider {
    static var previews : some View {
        CityTextField()
            .environmentObject(AppState.makeStore())
    }
}
