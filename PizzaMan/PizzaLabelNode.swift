//
//  PizzaLabelNode.swift
//  PizzaSlice
//
//  Created by William Entriken on 10/11/17.
//  Copyright © 2017 William Entriken. All rights reserved.
//

import SpriteKit

class PizzaLabelNode: SKLabelNode {
    override init() {
        super.init()
        fontName = "AmericanTypewriter"
        fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 26
        zPosition = 10
        horizontalAlignmentMode = .center
        verticalAlignmentMode = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
