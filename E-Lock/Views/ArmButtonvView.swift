//
//  ArmButtonvView.swift
//  E-Lock
//
//  Created by Esquieres, Benjamin T on 2/27/22.
//

import SwiftUI

struct ArmButtonView: View {
    @ObservedObject var viewModel: ELockViewModel
    var body: some View {
        HStack {
            Button(action: {
                viewModel.armingFunc(viewModel.armed ? 0 : 1)
            }, label: {
                Text(viewModel.armed ? "Disarm" : "Arm")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .padding()
            }).buttonStyle(ConnectButton())
        }.opacity(1)
//        .opacity(viewModel.connected ? 1.0 : 0.0)
        .frame(width: 220)
        .padding(.top)
    }
}
