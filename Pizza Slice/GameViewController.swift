//
//  GameViewController.swift
//  Pizza Slice
//
//  Created by William Entriken on 17/10/2014.
//  Copyright (c) 2014 William Entriken. All rights reserved.
//

import UIKit
import QuartzCore
import SpriteKit
import iAd

class GameViewController: UIViewController, ADBannerViewDelegate {
    var adBannerView:ADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adBannerView = ADBannerView(adType: ADAdType.banner)
        adBannerView.delegate = self
        adBannerView.isHidden = true
        view.addSubview(adBannerView)

        let skView = SKView(frame: self.view.frame)
        self.view.addSubview(skView)
        let scene = GameScene(size: self.view.frame.size)
        scene.navigationController = self.navigationController
        scene.viewController = self
        skView.presentScene(scene)
    }
    
    // http://stackoverflow.com/q/16796783/300224
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adBannerView.center = CGPoint(x: adBannerView.center.x, y: view.bounds.size.height - adBannerView.frame.size.height / 2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false;
    }
    
    
    func bannerViewDidLoadAd(_ banner: ADBannerView!) {
        adBannerView.isHidden = false
    }
    
    func bannerView(_ banner: ADBannerView!, didFailToReceiveAdWithError error: Error!) {
        adBannerView.isHidden = true
    }
}
