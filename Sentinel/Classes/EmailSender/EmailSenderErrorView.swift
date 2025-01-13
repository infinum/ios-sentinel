//
//  EmailSenderErrorView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 13.01.2025..
//

import SwiftUI

struct EmailSenderErrorView: View {

    let alertTitle: String
    let alertMessage: String

    var body: some View {
        VStack(spacing: 10) {
            Text(alertTitle)
                .font(.system(size: 17, weight: .bold))
                .multilineTextAlignment(.center)

            Text(alertMessage)
                .font(.system(size: 14, weight: .regular))
                .multilineTextAlignment(.center)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
    }
}
