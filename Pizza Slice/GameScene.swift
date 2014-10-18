//
//  GameScene.swift
//  Pizza Slice
//
//  Created by William Entriken 2014-10-17
//  Copyright (c) 2014 William Entriken. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, UIGestureRecognizerDelegate {

    var pacMan:SKShapeNode!
    var planes:NSMutableArray = []
    var nextPlaneLaunch:CFTimeInterval = 0
    var direction = 0
    
    var viewRadius:CGFloat!
    var pacManRadius:CGFloat!
    let pacManArc = M_PI * 0.4

    var eatSound = SKAction.playSoundFileNamed("eat.caf", waitForCompletion: false)
    var cwSound = SKAction.playSoundFileNamed("cw.caf", waitForCompletion: false)
    var ccwSound = SKAction.playSoundFileNamed("ccw.caf", waitForCompletion: false)
    var dieSound = SKAction.playSoundFileNamed("die.caf", waitForCompletion: false)
    
    var scoreLabel:SKLabelNode = SKLabelNode(fontNamed: "American Typewriter")
    var maxScoreLabel:SKLabelNode = SKLabelNode(fontNamed: "American Typewriter")
    var gameOverLabel = SKLabelNode()
    var score:Int = 0
    var gameOver = false
    var readyToStartNewGame = true
    
    var howto:SKSpriteNode!
    
    func handleRotate(recognizer : UIRotationGestureRecognizer) {
        if readyToStartNewGame {
            self.startGame()
        }
        
        if gameOver {
            return
        }
        
        if (recognizer.rotation > 0 && self.direction != 1) {
            self.runAction(self.ccwSound)
            self.direction = 1
        } else if (recognizer.rotation < 0 && self.direction != -1) {
            self.runAction(self.cwSound)
            self.direction = -1
        }
        self.pacMan.zRotation -= recognizer.rotation
        recognizer.rotation = 0
    }
    
    /* Setup your scene here */
    override func didMoveToView(view: SKView) {
        self.gameOver = true
        self.viewRadius = hypot(view.frame.width, view.frame.height)
        self.pacManRadius = self.viewRadius * 0.05
        
        var background:SKSpriteNode = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        background.name = "background"
        background.xScale = 2.0
        background.yScale = 2.0
        self.addChild(background)

        self.howto = SKSpriteNode(imageNamed: "howto")
        self.howto.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.howto.size = CGSizeMake(self.viewRadius * 0.2, self.viewRadius * 0.2)
        let action = SKAction.animateWithTextures([SKTexture(imageNamed: "howto"), SKTexture(imageNamed: "howto2")], timePerFrame: 0.4)
        self.howto.runAction(SKAction.repeatActionForever(action))
        self.addChild(self.howto)
        
        self.scoreLabel.text = "Score : 0"
        self.scoreLabel.name = "scoreLabel"
        self.scoreLabel.fontSize = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 60 : 30
        self.scoreLabel.zPosition = 10
        self.scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - scoreLabel.frame.height * 2)
        self.addChild(scoreLabel)
        self.maxScoreLabel.text = "Max Score : 0"
        self.maxScoreLabel.name = "maxScoreLabel"
        self.maxScoreLabel.fontSize = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 60 : 30
        self.maxScoreLabel.zPosition = 10
        self.maxScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        self.maxScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - scoreLabel.frame.height * 3)
    }
    
    func startGame() {
        self.howto.removeFromParent()
        self.gameOverLabel.removeFromParent()
        self.maxScoreLabel.removeFromParent()
        self.score = 0
        self.scoreLabel.text = "Score : \(self.score)"

        
        var path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0, 0)
        CGPathAddArc(path, nil, 0, 0, self.pacManRadius, CGFloat(self.pacManArc/2), CGFloat(-self.pacManArc/2), false)
        self.pacMan = SKShapeNode(path:path)
        self.pacMan.fillColor = SKColor.yellowColor()
        self.pacMan.strokeColor = SKColor.clearColor()
        self.pacMan.zPosition = 9999999
        self.pacMan.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.addChild(self.pacMan)
        
        self.readyToStartNewGame = false
        self.gameOver = false
    }
    
    func gameOver(attackingPiece: SKNode) {
        self.gameOver = true
        
        for plane in self.planes {
            plane.removeFromParent()
        }
        self.planes.removeAllObjects()
        self.runAction(self.dieSound)
        
        var maxScore = self.score
        if let savedMaxScore = NSUserDefaults.standardUserDefaults().objectForKey("maxScore") as? NSNumber {
            maxScore = max(self.score, savedMaxScore)
        }
        NSUserDefaults.standardUserDefaults().setInteger(maxScore, forKey: "maxScore")
        self.maxScoreLabel.text = "Max Score : \(maxScore)"
        self.addChild(self.maxScoreLabel)
        
        gameOverLabel = SKLabelNode(fontNamed: "American Typewriter")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.name = "scoreLabel"
        gameOverLabel.fontSize = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 60 : 30
        gameOverLabel.zPosition = 9999999
        gameOverLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - gameOverLabel.frame.height * 3)
        self.addChild(gameOverLabel)
        
        
        
        var wait = SKAction.waitForDuration(1.5)
        var setReady = SKAction.runBlock {
            self.pacMan.removeFromParent()
            
            self.howto = SKSpriteNode(imageNamed: "howto")
            self.howto.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            self.howto.size = CGSizeMake(self.viewRadius * 0.2, self.viewRadius * 0.2)
            let action = SKAction.animateWithTextures([SKTexture(imageNamed: "howto"), SKTexture(imageNamed: "howto2")], timePerFrame: 0.4)
            self.howto.runAction(SKAction.repeatActionForever(action))
            self.addChild(self.howto)

            self.readyToStartNewGame = true
        }
        self.runAction(SKAction.sequence([wait, setReady]))
    }
    

    /* Called before each frame is rendered */
    override func update(currentTime: CFTimeInterval) {
        if gameOver {return}
        if currentTime < self.nextPlaneLaunch {return}
        
        let interval:NSTimeInterval = 0.05 + 10/(Double(self.score) + 10)
        self.nextPlaneLaunch = currentTime + interval
        NSLog("launching")
        self.launchNewPlane()
    }
    
    func launchNewPlane() {
        let angle:CGFloat = CGFloat(Double(arc4random()) / 0x100000000 * 2 * M_PI)
        let middlePoint = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        let startPoint = CGPointMake(self.viewRadius * cos(angle) + CGRectGetMidX(self.frame),
                                     self.viewRadius * sin(angle) + CGRectGetMidY(self.frame))
        let collisionPoint = CGPointMake(self.pacManRadius * cos(angle) + CGRectGetMidX(self.frame),
                                         self.pacManRadius * sin(angle) + CGRectGetMidY(self.frame))
        
        var plane:SKSpriteNode = SKSpriteNode(imageNamed: "plane")
        plane.position = startPoint
        plane.name = "background"
        plane.size = CGSizeMake(self.viewRadius * 0.03, self.viewRadius * 0.03)
        self.addChild(plane)
        self.planes.addObject(plane)
        
        var approachPacMac = SKAction.moveTo(collisionPoint, duration: 5)
        approachPacMac.timingMode = SKActionTimingMode.EaseIn
        
        var checkCollision:SKAction = SKAction.runBlock {
            if Double(cos(angle - self.pacMan.zRotation)) > Double(cos(self.pacManArc/2)) {
                self.score += 1
                self.scoreLabel.text = "Score : \(self.score)"
                self.runAction(self.eatSound)
                
                if (self.score == 10) {
                    self.pacMan.fillColor = SKColor.orangeColor()
                } else if (self.score == 20) {
                    self.pacMan.fillColor = SKColor.redColor()
                } else if (self.score == 30) {
                    self.pacMan.fillColor = SKColor.purpleColor()
                } else if (self.score == 40) {
                    self.pacMan.fillColor = SKColor.greenColor()
                } else if (self.score == 50) {
                    self.pacMan.fillColor = SKColor.blueColor()
                } else if (self.score % 10 == 0) {
                    self.pacMan.fillColor = UIColor(hue: CGFloat(self.score), saturation: 1, brightness: 1, alpha: 1)
                }
                
            } else {
                self.gameOver(plane)
            }
        }
        
        var approachCenter = SKAction.moveTo(middlePoint, duration: 0.4)
        approachCenter.timingMode = SKActionTimingMode.EaseOut
        
        var deleteNode:SKAction = SKAction.runBlock {
            plane.removeFromParent()
            self.planes.removeObject(plane)
        }

        var sequence:SKAction = SKAction.sequence([approachPacMac, checkCollision, approachCenter, deleteNode])
        plane.runAction(sequence)
    }


}
