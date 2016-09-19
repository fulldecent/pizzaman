//
//  GameScene.swift
//  Pizza Slice
//
//  Created by William Entriken 2014-10-17
//  Copyright (c) 2014 William Entriken. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    let howto = SKSpriteNode(imageNamed: "howto1")
    let eatSound = SKAction.playSoundFileNamed("eat.caf", waitForCompletion: false)
    let cwSound = SKAction.playSoundFileNamed("cw.caf", waitForCompletion: false)
    let ccwSound = SKAction.playSoundFileNamed("ccw.caf", waitForCompletion: false)
    let dieSound = SKAction.playSoundFileNamed("die.caf", waitForCompletion: false)

    let scoreLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
    let maxScoreLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
    let gameOverLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
    let achievementLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
    let shareButton = SKSpriteNode(imageNamed: "share")
    
    var pacMan:SKShapeNode!
    let pacManArc = M_PI * 0.45
    var viewRadius:CGFloat!
    var pacManRadius:CGFloat!
    var score:Int = 0
    var turningClockwise = true
    var gameOver = false
    var readyToStartNewGame = true
    var nextPlaneLaunch:CFTimeInterval = 0
    
    /* Setup your scene here */
    override func didMove(to view: SKView) {
        self.gameOver = true
        self.viewRadius = hypot(view.frame.width, view.frame.height) / 2
        self.pacManRadius = self.viewRadius * 0.08
        
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.name = "background"
        background.xScale = 2.0
        background.yScale = 2.0
        self.addChild(background)
        
        self.howto.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.howto.size = CGSize(width: self.viewRadius * 0.45, height: self.viewRadius * 0.45)
        var actions = [SKAction]()
        actions.append(SKAction.setTexture(SKTexture(imageNamed: "howto1")))
        actions.append(SKAction.run {
            let angle = CGFloat(Double(arc4random()) / 0x100000000 * 2 * M_PI)
            self.howto.run(SKAction.rotate(byAngle: angle, duration: 0))
        })
        actions.append(SKAction.wait(forDuration: 0.3))
        actions.append(SKAction.setTexture(SKTexture(imageNamed: "howto2")))
        actions.append(SKAction.wait(forDuration: 0.6))
        self.howto.run(SKAction.repeatForever(SKAction.sequence(actions)))
        self.addChild(self.howto)
        
        self.scoreLabel.text = "SCORE  0"
        self.scoreLabel.fontColor = self.colorForScore(self.score)
        self.scoreLabel.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 30
        self.scoreLabel.zPosition = 10
        self.scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        self.scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.size.height * 0.9)
        self.addChild(scoreLabel)
        
        var maxScore = 0
        if let savedMaxScore = UserDefaults.standard.object(forKey: "maxScore") as? NSNumber {
            maxScore = max(self.score, Int(savedMaxScore))
        }
        self.maxScoreLabel.text = "HIGH SCORE  \(maxScore)"
        self.maxScoreLabel.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 30
        self.maxScoreLabel.zPosition = 10
        self.maxScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        self.maxScoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.size.height * 0.8)
        self.addChild(maxScoreLabel)
        
        self.gameOverLabel.text = "GAME OVER"
        self.gameOverLabel.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 30
        self.gameOverLabel.zPosition = 9999999
        self.gameOverLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        self.gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.size.height * 0.3)
        
        self.achievementLabel.text = "ACHIEVEMENT"
        self.achievementLabel.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 30
        self.achievementLabel.zPosition = 9999999
        self.achievementLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        self.achievementLabel.position = CGPoint(x: self.frame.midX, y: self.frame.size.height * 0.2)
    
        self.shareButton.position = CGPoint(x: self.frame.midX, y: self.frame.size.height * 0.1)
        self.shareButton.size.width = 150
        self.shareButton.size.height = 75
        
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addArc(center: CGPoint.zero, radius: pacManRadius, startAngle: CGFloat(self.pacManArc/2), endAngle: CGFloat(-self.pacManArc/2), clockwise: false)
        self.pacMan = SKShapeNode(path:path)
        self.pacMan.fillColor = SKColor.yellow
        self.pacMan.strokeColor = SKColor.clear
        self.pacMan.zPosition = 9999999
        self.pacMan.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
    }

    func rotateToPoint(_ point: CGPoint) {
        let rotation = atan2(point.y - self.frame.height/2, point.x - self.frame.width/2)
        let rotationDifference = rotation - self.pacMan.zRotation
        let differenceQuadrant14 = (rotationDifference + CGFloat(M_PI)).truncatingRemainder(dividingBy: CGFloat(2 * M_PI)) - CGFloat(M_PI)
        if (differenceQuadrant14 > 0 && !self.turningClockwise) {
            self.run(self.ccwSound)
            self.turningClockwise = true
        } else if (differenceQuadrant14 < 0 && self.turningClockwise) {
            self.run(self.cwSound)
            self.turningClockwise = false
        }
        self.pacMan.zRotation = rotation
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let location = touches.first!.location(in: self)
        if (self.atPoint(location) == self.shareButton) {
            self.doShare(self.score)
        } else if readyToStartNewGame {
            self.startGame()
        } else if !gameOver {
            self.rotateToPoint(location)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let touch = touches.first!
        self.rotateToPoint(touch.location(in: self))
    }
    
    func startGame() {
        self.howto.removeFromParent()
        self.score = 0
        self.gameOverLabel.removeFromParent()
        self.achievementLabel.removeFromParent()
        self.maxScoreLabel.removeFromParent()
        self.shareButton.removeFromParent()
        self.pacMan.zRotation = 0
        self.pacMan.fillColor = self.colorForScore(self.score)
        self.addChild(self.pacMan)
        self.scoreLabel.text = "SCORE  \(self.score)"
        self.scoreLabel.fontColor = self.colorForScore(self.score)
        self.readyToStartNewGame = false
        self.gameOver = false
    }
    
    func gameOver(_ attackingPiece: SKNode) {
        guard !gameOver else {
            return
        }

        self.gameOver = true
        self.run(self.dieSound)

        self.enumerateChildNodes(withName: "plane", using: { (plane:SKNode, x) -> Void in
            plane.removeFromParent()
        })
        
        var maxScore = self.score
        if let savedMaxScore = UserDefaults.standard.object(forKey: "maxScore") as? NSNumber {
            maxScore = max(self.score, Int(savedMaxScore))
        }
        UserDefaults.standard.set(maxScore, forKey: "maxScore")
        self.maxScoreLabel.text = "HIGH SCORE  \(maxScore)"
        self.maxScoreLabel.fontColor = self.colorForScore(maxScore)
        self.addChild(self.maxScoreLabel)
        self.addChild(self.gameOverLabel)
        self.addChild(self.achievementLabel)
        self.addChild(self.shareButton)
        let level = self.achievementLevelForScore(self.score)
        self.achievementLabel.text = "\(level)"
        
        let wait = SKAction.wait(forDuration: 1.5)
        let setReady = SKAction.run {
            self.pacMan.removeFromParent()
            self.addChild(self.howto)
            self.readyToStartNewGame = true
        }
        self.run(SKAction.sequence([wait, setReady]))
    }
    
    /* Called before each frame is rendered */
    override func update(_ currentTime: TimeInterval) {
        guard !gameOver else {
            return
        }
        guard currentTime >= self.nextPlaneLaunch else {
            return
        }
        
        let interval:TimeInterval = 0.15 + 2/(Double(self.score) + 1)
        self.nextPlaneLaunch = currentTime + interval
        self.launchNewPlane()
    }
    
    func launchNewPlane() {
        let angle = CGFloat(Double(arc4random()) / 0x100000000 * 2 * M_PI)
        let startPoint = CGPoint(x: self.viewRadius * cos(angle) + self.frame.midX,
                                     y: self.viewRadius * sin(angle) + self.frame.midY)
        let collisionPoint = CGPoint(x: self.pacManRadius * cos(angle) + self.frame.midX,
                                         y: self.pacManRadius * sin(angle) + self.frame.midY)
        let middlePoint = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        let plane = SKSpriteNode(imageNamed: "plane")
        plane.position = startPoint
        plane.name = "plane"
        plane.size = CGSize(width: self.viewRadius * 0.05, height: self.viewRadius * 0.05)
        self.addChild(plane)
        
        let approachPacMac = SKAction.move(to: collisionPoint, duration: 5)
        approachPacMac.timingMode = SKActionTimingMode.easeIn
        
        let checkCollision:SKAction = SKAction.run {
            if Double(cos(angle - self.pacMan.zRotation)) > Double(cos(self.pacManArc/2)) {
                self.score += 1
                self.scoreLabel.text = "SCORE  \(self.score)"
                self.run(self.eatSound)
                let color = self.colorForScore(self.score)
                self.pacMan.fillColor = color
                self.scoreLabel.fontColor = color
            } else {
                self.gameOver(plane)
            }
        }
        
        let approachCenter = SKAction.move(to: middlePoint, duration: 0.4)
        approachCenter.timingMode = SKActionTimingMode.easeOut
        
        let deleteNode:SKAction = SKAction.run {
            plane.removeFromParent()
        }

        let sequence:SKAction = SKAction.sequence([approachPacMac, checkCollision, approachCenter, deleteNode])
        plane.run(sequence)
    }
    
    func doShare(_ score: Int) {
        let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
        let url = URL(string: "https://itunes.apple.com/us/app/pizza-slice/id931174800")
        let title = "I acheived the score \(score) in \(appName)"

        UIGraphicsBeginImageContextWithOptions(self.view!.bounds.size, true, UIScreen.main.scale)
        self.shareButton.isHidden = true
        self.view!.drawHierarchy(in: self.view!.bounds, afterScreenUpdates: false)
        let screenshot : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        var itemsToShare = [AnyObject]()
        itemsToShare.append(screenshot)
        itemsToShare.append(title as AnyObject)
        itemsToShare.append(url! as AnyObject)
        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.print, UIActivityType.assignToContact]
        //activityVC.completionWithItemsHandler = {// Google Tracker event  }()
        
        let rootVC = self.view!.window!.rootViewController
        rootVC?.present(activityVC, animated: true, completion: nil)
    }
    
    func colorForScore(_ score: Int) -> SKColor {
        switch score {
        case 0...9:
            return UIColor(red: 1, green: 1, blue: 0, alpha: 1)
        case 10...19:
            return SKColor.orange
        case 20...29:
            return SKColor.red
        case 30...39:
            return SKColor.purple
        case 40...49:
            return SKColor.green
        case 50...59:
            return SKColor.blue
        default:
            let tens = Int(score / 10)
            return UIColor(hue: CGFloat(tens), saturation: 1, brightness: 1, alpha: 1)
        }
    }
    
    func achievementLevelForScore(_ score: Int) -> String {
        switch score {
        case 0...9:
            return "Bad"
        case 10...19:
            return "Eh"
        case 20...29:
            return "Meh"
        case 30...39:
            return "Fair"
        case 40...49:
            return "Decent"
        case 50...59:
            return "OK"
        case 60...69:
            return "Cool"
        case 70...79:
            return "Good"
        case 80...89:
            return "Better"
        case 90...99:
            return "Wild"
        case 100...109:
            return "Beast"
        case 110...119:
            return "Master"
        case 120...129:
            return "Champion"
        case 130...139:
            return "Wicked"
        case 140...149:
            return "Wickeder"
        case 150...159:
            return "Best"
        default:
            let bestLevel = Int((score - 140) / 10)
            return "Best \(bestLevel)"
        }
    }
}
