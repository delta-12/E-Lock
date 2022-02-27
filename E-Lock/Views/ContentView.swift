//
//  ContentView.swift
//  E-Lock
//
//  Created by Esquieres, Benjamin T on 2/26/22.
//

import SwiftUI

struct ContentView: View {
    // 1
    @StateObject var viewModel = ELockViewModel()
    
    var body: some View {
        VStack {
            VStack {
            
            Text(viewModel.output)
                .frame(width: 300,
                        height: 50,
                        alignment: .center)
                .font(.title)
//                .background(Color.gray.opacity(0.2))
                .padding(.bottom)

            ArmButtonView(viewModel: viewModel)
            ConnectButtonView(viewModel: viewModel)
            
            }
        }
    }
}
