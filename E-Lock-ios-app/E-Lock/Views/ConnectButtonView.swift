//
//  ConnectBtnView.swift
//  E-Lock
//
//  Created by Esquieres, Benjamin T on 2/26/22.
//

import SwiftUI

struct ConnectButtonView: View {
    @ObservedObject var viewModel: ELockViewModel
    
    var body: some View {
        HStack {
            if viewModel.connected {
                Button(action: {
                    viewModel.disconnectELock()
                }, label: {
                    Text("Disconnect")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .padding()
                }).buttonStyle(ConnectButton())
            } else {
                Button(action: {
                    viewModel.connectELock()
                }, label: {
                    Text("Connect")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .padding()
                }).buttonStyle(ConnectButton())
            }
        }
        .frame(width: 220)
        .padding(.top)
    }
}
