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


    func application(_ application: UIApplication) {
        
        window = UIWindow(frame: Screen.bounds)
        window!.rootViewController = ViewController()
        window!.makeKeyAndVisible()
    }
    
}

