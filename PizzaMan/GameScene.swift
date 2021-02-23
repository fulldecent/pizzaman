//
//  GameScene.swift
//  PizzaSlice
//
//  Created by William Entriken on 10/11/17.
//  Copyright © 2017 William Entriken. All rights reserved.
//

import SpriteKit
import GameKit

class GameScene: SKScene {
    var viewController: UIViewController! = nil

    // MARK: Sounds
    let playEatSound = SKAction.playSoundFileNamed("eat.caf", waitForCompletion: false)
    let playCWSound = SKAction.playSoundFileNamed("cw.caf", waitForCompletion: false)
    let playCCWSound = SKAction.playSoundFileNamed("ccw.caf", waitForCompletion: false)
    let playDieSound = SKAction.playSoundFileNamed("die.caf", waitForCompletion: false)

    // MARK: Nodes
    var pizzaMan: PizzaManShapeNode!
    var howtoNode: HowtoNode!
    let scoreLabel = PizzaLabelNode(fontNamed: "AmericanTypewriter-Bold")
    let highScoreLabel = PizzaLabelNode(fontNamed: "AmericanTypewriter-Bold")
    let leaderboardLabel = PizzaLabelNode(fontNamed: "AmericanTypewriter-Bold")
    let moreDetails = SKSpriteNode(imageNamed: "moreDetails")
    let gameOverLabel = PizzaLabelNode(fontNamed: "SNES-Italic")

    // MARK: Game state
    enum GameState {
        case tutorial
        case readyToStart
        case playing
    }
    var gameState = GameState.tutorial
    var score: Int = 0 {
        didSet {
            self.scoreLabel.text = "SCORE  \(self.score)"
            self.scoreLabel.fontColor = colorForScore(self.score)
        }
    }
    var highScore: Int = 0 {
        didSet {
            self.highScoreLabel.text = "HIGH SCORE  \(self.highScore)"
            self.highScoreLabel.fontColor = colorForScore(self.highScore)
        }
    }

    // MARK: Other variables
    var viewRadius: CGFloat!
    var pizzaManRadius: CGFloat!
    let pizzaManArc = CGFloat(Double.pi * 0.45)
    var turningClockwise = true
    var nextPepperoniLaunch:CFTimeInterval = 0
    
    override func didMove(to view: SKView) {
        viewRadius = hypot(view.frame.width, view.frame.height) / 2
        pizzaManRadius = viewRadius * 0.08

        // Create nodes that depend on view size
        pizzaMan = PizzaManShapeNode(radius: pizzaManRadius, angle: pizzaManArc)
        pizzaMan.position = CGPoint(x: frame.midX, y: frame.midY)
        howtoNode = HowtoNode(pizzaManRadius: pizzaManRadius, pizzaManAngle: pizzaManArc, viewRadius: viewRadius)
        howtoNode.position = CGPoint(x: frame.midX, y: frame.midY)

        let emitterNode = SKEmitterNode(fileNamed: "StarField")!
        emitterNode.position = CGPoint(x: frame.midX, y: frame.midY)
        emitterNode.zPosition = -10
        emitterNode.isUserInteractionEnabled = false
        self.addChild(emitterNode)

        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(cameraNode)
        self.camera = cameraNode

        switchToInstructionState()
    }
    
    func switchToInstructionState() {
        gameState = .tutorial
        pizzaMan.removeFromParent()
        addChild(howtoNode)
        
        let wait = SKAction.wait(forDuration: 1.5)
        let setReady = SKAction.run {
            self.switchToReadyState()
        }
        self.run(SKAction.sequence([wait, setReady]))
    }
    
    func switchToReadyState() {
        gameState = .readyToStart
    }
    
    func switchToPlayingState() {
        gameState = .playing
        leaderboardLabel.removeFromParent()
        howtoNode.removeFromParent()
        gameOverLabel.removeFromParent()
        moreDetails.removeFromParent()
        
        score = 0
        scoreLabel.removeFromParent()
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.size.height)
        addChild(scoreLabel)
        scoreLabel.run(SKAction.move(to: CGPoint(x: frame.midX, y: frame.size.height * 0.9), duration: 0.5))
        
        highScore = UserDefaults.standard.integer(forKey: "maxScore")
        highScoreLabel.removeFromParent()
        highScoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.size.height)
        addChild(highScoreLabel)
        highScoreLabel.run(SKAction.move(to: CGPoint(x: frame.midX, y: frame.size.height * 0.8), duration: 0.5))
        
        pizzaMan.zRotation = 0
        pizzaMan.fillColor = colorForScore(score)
        pizzaMan.removeFromParent()
        pizzaMan.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        addChild(pizzaMan)
    }
    
    func gameOver() {
        guard gameState == .playing else {
            return
        }
        run(playDieSound)
        
        enumerateChildNodes(withName: "pepperoni") { (topping, _) in
            topping.removeFromParent()
        }
        
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "maxScore")
        }
        
        let zoomInAction = SKAction.scale(to: 1, duration: 1)
        self.camera!.run(zoomInAction)
        
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.color = UIColor.white
        gameOverLabel.position = CGPoint(x: self.frame.midX, y: 0)
        addChild(gameOverLabel)
        gameOverLabel.run(SKAction.move(to: CGPoint(x: frame.midX, y: frame.size.height * 0.2), duration: 0.2))
        
        leaderboardLabel.removeFromParent()
        leaderboardLabel.position = CGPoint(x: self.frame.midX, y: self.frame.size.height)
        leaderboardLabel.text = "LEADERBOARD  "
        addChild(leaderboardLabel)
        leaderboardLabel.run(SKAction.move(to: CGPoint(x: frame.midX, y: frame.size.height * 0.7), duration: 0.5)) {
            self.moreDetails.removeFromParent()
            self.moreDetails.size.height = self.leaderboardLabel.frame.size.height * 1.5
            self.moreDetails.size.width = self.leaderboardLabel.frame.size.height * 1.5
            self.moreDetails.position.x = self.leaderboardLabel.position.x + self.leaderboardLabel.frame.width / 2 + self.moreDetails.size.width
            self.moreDetails.position.y = self.leaderboardLabel.position.y
            self.moreDetails.zPosition = 10
            self.addChild(self.moreDetails)
        }
        
        switchToInstructionState()
        
        // Report score to Apple
        let gcLocalPlayer = GKLocalPlayer.local
        if gcLocalPlayer.isAuthenticated {
            let gkScore = GKScore(leaderboardIdentifier: "main")
            gkScore.value = Int64(score)
            GKScore.report([gkScore], withCompletionHandler: nil)
        }
    }
    
    func showLeaderboard() {
        let localPlayer = LocalPlayer.sharedInstance
        
        // One-time per app install needs to authenticate user
        if let gameKitViewController = localPlayer.gameKitViewController {
            self.viewController.present(gameKitViewController, animated: true, completion: nil)
            localPlayer.gameKitViewController = nil
            return
        }
        
        let gkLocalPlayer = GKLocalPlayer.local
        if gkLocalPlayer.isAuthenticated {
            let gcViewController = GKGameCenterViewController()
            gcViewController.gameCenterDelegate = self
            gcViewController.viewState = .leaderboards
            gcViewController.leaderboardTimeScope = .allTime
            gcViewController.leaderboardIdentifier = "main"
            self.viewController.present(gcViewController, animated: true, completion: nil)
            return
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        if atPoint(location) == moreDetails {
            showLeaderboard()
        } else if gameState == .readyToStart {
            switchToPlayingState()
        } else if gameState == .playing {
            rotateToPoint(location)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        rotateToPoint(touch.location(in: self))
    }
    
    /* Called before each frame is rendered */
    override func update(_ currentTime: TimeInterval) {
        guard gameState == .playing else {
            return
        }
        guard currentTime >= nextPepperoniLaunch else {
            return
        }
        
        let interval:TimeInterval = 0.15 + 2/(Double(score) + 1)
        nextPepperoniLaunch = currentTime + interval
        launchNewTopping()
    }
    
    func launchNewTopping() {
        let angle = CGFloat(Double.random() * 2 * Double.pi)
        let startPoint = CGPoint(x: viewRadius * cos(angle) + frame.midX,
                                 y: viewRadius * sin(angle) + frame.midY)
        let collisionPoint = CGPoint(x: pizzaManRadius * cos(angle) + frame.midX,
                                     y: pizzaManRadius * sin(angle) + frame.midY)
        let middlePoint = CGPoint(x: frame.midX, y: frame.midY)
        
        let topping = SKSpriteNode(imageNamed: "pepperoni")
        topping.position = startPoint
        topping.name = "pepperoni"
        topping.size = CGSize(width: self.viewRadius * 0.05, height: self.viewRadius * 0.05)
        self.addChild(topping)
        
        let approachPacMac = SKAction.move(to: collisionPoint, duration: 5)
        approachPacMac.timingMode = SKActionTimingMode.easeIn
        
        let checkCollision:SKAction = SKAction.run {
            if Double(cos(angle - self.pizzaMan.zRotation)) > Double(cos(self.pizzaManArc/2)) {
                self.score += 1
                self.run(self.playEatSound)
                self.pizzaMan.fillColor = colorForScore(self.score)

                if (self.score % 10 == 0) {
                    let newScale = CGFloat(1) - CGFloat(self.score) / 100
                    let zoomInAction = SKAction.scale(to: newScale, duration: 0.5)
                    self.camera!.run(zoomInAction)
                }
            
            } else {
                self.gameOver()
            }
        }
        
        let approachCenter = SKAction.move(to: middlePoint, duration: 0.4)
        approachCenter.timingMode = SKActionTimingMode.easeOut
        
        let deleteNode:SKAction = SKAction.run {
            topping.removeFromParent()
        }
        
        let sequence:SKAction = SKAction.sequence([approachPacMac, checkCollision, approachCenter, deleteNode])
        topping.run(sequence)
    }
    
    func rotateToPoint(_ point: CGPoint) {
        let rotation = atan2(point.y - frame.height/2, point.x - frame.width/2)
        let rotationDifference = rotation - pizzaMan.zRotation
        let differenceQuadrant14 = (rotationDifference + CGFloat(Double.pi)).truncatingRemainder(dividingBy: CGFloat(2 * Double.pi)) - CGFloat(Double.pi)
        if (differenceQuadrant14 > 0 && !turningClockwise) {
            run(playCCWSound)
            turningClockwise = true
        } else if (differenceQuadrant14 < 0 && turningClockwise) {
            run(playCWSound)
            turningClockwise = false
        }
        pizzaMan.zRotation = rotation
    }

}

class PizzaManShapeNode: SKShapeNode {
    convenience init(radius: CGFloat, angle: CGFloat) {
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addArc(center: CGPoint.zero, radius: radius, startAngle: CGFloat(angle/2), endAngle: CGFloat(-angle/2), clockwise: false)
        self.init(path: path)
        fillColor = SKColor.yellow
        strokeColor = SKColor.clear
        zPosition = 999
    }
}

class HowtoNode: SKShapeNode {
    convenience init(pizzaManRadius: CGFloat, pizzaManAngle: CGFloat, viewRadius: CGFloat) {
        self.init()
        let pizzaMan = PizzaManShapeNode(radius: pizzaManRadius, angle: pizzaManAngle)
        pizzaMan.position = CGPoint(x: 0, y: 0)
        addChild(pizzaMan)
        
        let finger = SKSpriteNode(imageNamed: "howto")
        let fingerRadius = 0.1 * viewRadius
        finger.size = CGSize(width: fingerRadius * 2, height: fingerRadius * 2)
        finger.position = CGPoint(x: 0, y: 0)
        finger.zRotation = CGFloat(Double.pi / 2)
        addChild(finger)
        
        let minFingerDistance = CGFloat(pizzaManRadius) + fingerRadius
        let maxFingerDistance = CGFloat(viewRadius * 0.8 - fingerRadius * 2)
        
        var actions = [SKAction]()
        actions.append(SKAction.run {
            let angle = CGFloat(Double.random() * 2 * Double.pi)
            self.zRotation = angle
            let distance = minFingerDistance + (maxFingerDistance - minFingerDistance) * CGFloat(Double.random())
            finger.position.x = distance
            finger.isHidden = false
        })
        actions.append(SKAction.wait(forDuration: 0.2))
        actions.append(SKAction.run {
            finger.isHidden = true
        })
        actions.append(SKAction.wait(forDuration: 0.4))
        run(SKAction.repeatForever(SKAction.sequence(actions)))
    }
}

public extension Double {
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    static func random() -> Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }
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
        return "Meh"
    case 20...29:
        return "Fair"
    case 30...39:
        return "Decent"
    case 40...49:
        return "OK"
    case 50...59:
        return "Cool"
    case 60...69:
        return "Good"
    case 70...79:
        return "Better"
    case 80...89:
        return "Wild"
    case 90...99:
        return "Beast"
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

extension GameScene: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
