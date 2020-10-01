//
//  LocationMockViewController.swift
//  ToolBox
//
//  Created by Nikola Majcen on 01/10/2020.
//

import UIKit

extension UIStoryboard {
    static var locationMock: UIStoryboard { UIStoryboard(name: "LocationMock", bundle: .toolBox) }
}

class LocationMockViewController: UIViewController {
    
    // MARK: - Public methods
    
    static func create() -> LocationMockViewController {
        let viewController = UIStoryboard.locationMock.instantiateViewController(ofType: LocationMockViewController.self)
        return viewController
    }
}
