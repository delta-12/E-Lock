//
//  ConnectButton.swift
//  E-Lock
//
//  Created by Esquieres, Benjamin T on 2/26/22.
//

import SwiftUI

struct ConnectButton: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: 55, alignment: .center)
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(20)
    }
}
