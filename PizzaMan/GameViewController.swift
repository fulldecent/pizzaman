//
//  GameViewController.swift
//  PizzaSlice
//
//  Created by William Entriken on 10/11/17.
//  Copyright © 2017 William Entriken. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = SKView(frame: self.view.frame)
        self.view.addSubview(skView)
        let scene = GameScene(size: self.view.frame.size)
        scene.viewController = self
        skView.presentScene(scene)
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
