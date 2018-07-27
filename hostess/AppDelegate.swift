//
//  AppDelegate.swift
//  hostess
//
//  Created by Nimblr on 20/07/18.
//  Copyright © 2018 ricardo. All rights reserved.
//

import UIKit
import Material
import Graph
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var restrictRotation:TypeInterfaceOrientationMask = .portrait

    func application(_ application: UIApplication) {
        
        window = UIWindow(frame: Screen.bounds)
        window!.rootViewController = ViewController()
        window!.makeKeyAndVisible()
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        switch self.restrictRotation {
        case .all:
            return UIInterfaceOrientationMask.all
        case .portrait:
            return UIInterfaceOrientationMask.portrait
        case .landscape:
            return UIInterfaceOrientationMask.landscape
        }
    }
    
    enum TypeInterfaceOrientationMask {
        case all
        case portrait
        case landscape
    }
}

