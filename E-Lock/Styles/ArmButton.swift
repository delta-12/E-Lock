//
//  ArmButton.swift
//  E-Lock
//
//  Created by Esquieres, Benjamin T on 2/27/22.
//

import SwiftUI

struct ArmButton: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: 55, alignment: .center)
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(20)
    }
}
