//
//  ActivityIndicator.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 13.05.21.
//

import SwiftUI


struct ActivityIndicator : UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let result = UIActivityIndicatorView()
        result.startAnimating()
        return result
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {}
    
}


struct ActivityIndicatorPreview : PreviewProvider {
    
    static var previews : some View {
        ActivityIndicator() 
    }
    
}
