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
    var howto:SKSpriteNode!
    var scoreLabel = SKLabelNode(fontNamed: "American Typewriter")
    var maxScoreLabel = SKLabelNode(fontNamed: "American Typewriter")
    var gameOverLabel = SKLabelNode(fontNamed: "American Typewriter")
    
    var eatSound = SKAction.playSoundFileNamed("eat.caf", waitForCompletion: false)
    var cwSound = SKAction.playSoundFileNamed("cw.caf", waitForCompletion: false)
    var ccwSound = SKAction.playSoundFileNamed("ccw.caf", waitForCompletion: false)
    var dieSound = SKAction.playSoundFileNamed("die.caf", waitForCompletion: false)
    
    var viewRadius:CGFloat!
    var pacManRadius:CGFloat!
    let pacManArc = M_PI * 0.4
    var score:Int = 0
    var direction = 0
    var gameOver = false
    var readyToStartNewGame = true
    var nextPlaneLaunch:CFTimeInterval = 0
    
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
        
        var background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        background.name = "background"
        background.xScale = 2.0
        background.yScale = 2.0
        self.addChild(background)
        
        self.howto = SKSpriteNode(imageNamed: "howto")
        self.howto.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.howto.size = CGSizeMake(self.viewRadius * 0.2, self.viewRadius * 0.2)
        var actions = NSMutableArray()
        actions.addObject(SKAction.rotateByAngle(CGFloat(-M_PI_2), duration: 0.5))
        actions.addObject(SKAction.waitForDuration(0.4))
        actions.addObject(SKAction.rotateByAngle(CGFloat(+M_PI_2), duration: 0))
        self.howto.runAction(SKAction.repeatActionForever(SKAction.sequence(actions)))
        self.addChild(self.howto)
        
        self.scoreLabel.text = "Score : 0"
        self.scoreLabel.name = "scoreLabel"
        self.scoreLabel.fontSize = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 60 : 30
        self.scoreLabel.zPosition = 10
        self.scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - scoreLabel.frame.height * 2)
        self.addChild(scoreLabel)
        
        self.maxScoreLabel.text = "High Score : 0"
        self.maxScoreLabel.name = "maxScoreLabel"
        self.maxScoreLabel.fontSize = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 60 : 30
        self.maxScoreLabel.zPosition = 10
        self.maxScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        self.maxScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - scoreLabel.frame.height * 3)
        
        self.gameOverLabel.text = "GAME OVER"
        self.gameOverLabel.name = "scoreLabel"
        self.gameOverLabel.fontSize = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 60 : 30
        self.gameOverLabel.zPosition = 9999999
        self.gameOverLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        self.gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - gameOverLabel.frame.height * 3)
        
        var path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0, 0)
        CGPathAddArc(path, nil, 0, 0, self.pacManRadius, CGFloat(self.pacManArc/2), CGFloat(-self.pacManArc/2), false)
        self.pacMan = SKShapeNode(path:path)
        self.pacMan.fillColor = SKColor.yellowColor()
        self.pacMan.strokeColor = SKColor.clearColor()
        self.pacMan.zPosition = 9999999
        self.pacMan.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
    }
    
    func startGame() {
        self.howto.removeFromParent()
        self.gameOverLabel.removeFromParent()
        self.maxScoreLabel.removeFromParent()
        self.pacMan.zRotation = 0
        self.addChild(self.pacMan)
        self.score = 0
        self.scoreLabel.text = "Score : \(self.score)"
        self.scoreLabel.fontColor = self.colorForScore(self.score)
        self.readyToStartNewGame = false
        self.gameOver = false
    }
    
    func gameOver(attackingPiece: SKNode) {
        self.gameOver = true
        self.runAction(self.dieSound)

        self.enumerateChildNodesWithName("plane", usingBlock: { (plane:SKNode!, x) -> Void in
            plane.removeFromParent()
        })
        
        var maxScore = self.score
        if let savedMaxScore = NSUserDefaults.standardUserDefaults().objectForKey("maxScore") as? NSNumber {
            maxScore = max(self.score, savedMaxScore)
        }
        NSUserDefaults.standardUserDefaults().setInteger(maxScore, forKey: "maxScore")
        self.maxScoreLabel.text = "High Score : \(maxScore)"
        self.maxScoreLabel.fontColor = self.colorForScore(maxScore)
        self.addChild(self.maxScoreLabel)
        self.addChild(self.gameOverLabel)
        
        var wait = SKAction.waitForDuration(1.5)
        var setReady = SKAction.runBlock {
            self.pacMan.removeFromParent()
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
        let startPoint = CGPointMake(self.viewRadius * cos(angle) + CGRectGetMidX(self.frame),
                                     self.viewRadius * sin(angle) + CGRectGetMidY(self.frame))
        let collisionPoint = CGPointMake(self.pacManRadius * cos(angle) + CGRectGetMidX(self.frame),
                                         self.pacManRadius * sin(angle) + CGRectGetMidY(self.frame))
        let middlePoint = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        var plane:SKSpriteNode = SKSpriteNode(imageNamed: "plane")
        plane.position = startPoint
        plane.name = "plane"
        plane.size = CGSizeMake(self.viewRadius * 0.03, self.viewRadius * 0.03)
        self.addChild(plane)
        
        var approachPacMac = SKAction.moveTo(collisionPoint, duration: 5)
        approachPacMac.timingMode = SKActionTimingMode.EaseIn
        
        var checkCollision:SKAction = SKAction.runBlock {
            if Double(cos(angle - self.pacMan.zRotation)) > Double(cos(self.pacManArc/2)) {
                self.score += 1
                self.scoreLabel.text = "Score : \(self.score)"
                self.runAction(self.eatSound)
                
                if self.score % 10 == 0 {
                    self.pacMan.fillColor = self.colorForScore(self.score)
                    self.scoreLabel.fontColor = self.colorForScore(self.score)
                }
            } else {
                self.gameOver(plane)
            }
        }
        
        var approachCenter = SKAction.moveTo(middlePoint, duration: 0.4)
        approachCenter.timingMode = SKActionTimingMode.EaseOut
        
        var deleteNode:SKAction = SKAction.runBlock {
            plane.removeFromParent()
        }

        var sequence:SKAction = SKAction.sequence([approachPacMac, checkCollision, approachCenter, deleteNode])
        plane.runAction(sequence)
    }
    
    func colorForScore(score:Int) -> SKColor {
        switch score {
        case 0...9:
            return SKColor.whiteColor()
        case 10...19:
            return SKColor.orangeColor()
        case 20...29:
            return SKColor.redColor()
        case 30...39:
            return SKColor.purpleColor()
        case 40...49:
            return SKColor.greenColor()
        case 50...59:
            return SKColor.blueColor()
        default:
            let tens = Int(score / 10)
            return UIColor(hue: CGFloat(tens), saturation: 1, brightness: 1, alpha: 1)
        }
    }

}
