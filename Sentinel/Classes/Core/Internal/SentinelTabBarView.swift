//
//  SentinelTabBarView.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 08.11.2024..
//

import SwiftUI

enum Tab {
    case device
    case application
    case tools
    case preferences
    case performance
}

struct SentinelTabBarView: View {

    @State var selectedTab: Tab = .tools
    let tabs: [SentinelTabItem]

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                ForEach(tabs, id: \.barItemTitle) { tab in
                    SentinelListView(title: tab.barItemTitle, items: tab.sections)
                        .tabItem { TabBarView(tab: tab) }
                }
            }
        }
        .navigationTitle("Sentinel")
    }
}

private struct TabBarView: View {

    var tab: SentinelTabItem

    var body: some View {
        VStack(spacing: 5) {
            Image(uiImage: tab.barItemImage)
            Text(tab.barItemTitle)
        }
    }
}

//#Preview {
//    SentinelTabBarView()
//}


extension Tab {
    var barItemTitle: String {
        switch self {
        case .device:
            return "Device"
        case .application:
            return "Application"
        case .tools:
            return "Tools"
        case .preferences:
            return "Preferences"
        case .performance:
            return "Performance"
        }
    }

    var barItemImage: UIImage {
        switch self {
        case .device:
            guard let image = UIImage.SentinelImages.device else { return UIImage() }
            return image
        case .application:
            guard let image = UIImage.SentinelImages.application else { return UIImage() }
            return image
        case .tools:
            guard let image = UIImage.SentinelImages.tools else { return UIImage() }
            return image
        case .preferences:
            guard let image = UIImage.SentinelImages.preferences else { return UIImage() }
            return image
        case .performance:
            guard let image = UIImage.SentinelImages.performance else { return UIImage() }
            return image
        }
    }
}
