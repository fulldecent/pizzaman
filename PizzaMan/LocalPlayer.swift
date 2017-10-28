//
//  LocalPlayer.swift
//  PizzaSlice
//
//  Created by William Entriken on 10/28/17.
//  Copyright © 2017 William Entriken. All rights reserved.
//

import UIKit

class LocalPlayer
{
    static let sharedInstance = LocalPlayer()
    var gameKitViewController: UIViewController?
    
    private init() {
    }
}
