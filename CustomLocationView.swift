//
//  CustomLocationView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 10.12.2024..
//

import SwiftUI
import MapKit

struct CustomLocationView: View {

    @ObservedObject var viewModel: CustomLocationViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if let marker = viewModel.marker {
                    Map(coordinateRegion: $viewModel.coordinateRegion, annotationItems: [marker], annotationContent: {
                        MapMarker(coordinate: $0.coordinate)
                    })
                } else {
                    Map(coordinateRegion: $viewModel.coordinateRegion)
                }
                if viewModel.enableCustomLocation {
                    VStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Latitude")
                            TextField("Enter latitude", text: $viewModel.latitude)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }


                        VStack(alignment: .leading, spacing: 5) {
                            Text("Longitude")
                            TextField("Enter longitude", text: $viewModel.longitude)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button("Update location", action: viewModel.updateLocation)
                    }
                    .padding(16)
                }
            }
            .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                Toggle(isOn: $viewModel.enableCustomLocation) {
                    Text("Enable custom location")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
            }
        }
    }
}
