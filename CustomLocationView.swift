//
//  CustomLocationView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 10.12.2024..
//

import SwiftUI

struct CustomLocationView: UIViewControllerRepresentable {

    let locationProvider: CustomLocationProvider

    func makeUIViewController(context: Context) -> some UIViewController {
        CustomLocationViewController.create(locationProvider: locationProvider)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // Nothing to do here
    }
}
