//
//  GameScene.swift
//  Pizza Slice
//
//  Created by William Entriken 2014-10-17
//  Copyright (c) 2014 William Entriken. All rights reserved.
//

import SpriteKit
 

class GameScene: SKScene {
    var navigationController: UINavigationController! = nil
    var viewController: UIViewController! = nil
    
    // MARK: Sprites
    let howto = SKSpriteNode(imageNamed: "howto1")
    let clickMe = SKSpriteNode(imageNamed: "moreDetails")
    let eatSound = SKAction.playSoundFileNamed("eat.caf", waitForCompletion: false)
    let cwSound = SKAction.playSoundFileNamed("cw.caf", waitForCompletion: false)
    let ccwSound = SKAction.playSoundFileNamed("ccw.caf", waitForCompletion: false)
    let dieSound = SKAction.playSoundFileNamed("die.caf", waitForCompletion: false)

    let scoreLabel: SKLabelNode = {
        let retval = SKLabelNode(fontNamed: "AmericanTypewriter")
        retval.text = "SCORE"
        retval.fontColor = colorForScore(0)
        retval.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 30
        retval.zPosition = 10
        retval.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        retval.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        return retval
    }()
    
    let highScoreLabel: SKLabelNode = {
        let retval = SKLabelNode(fontNamed: "AmericanTypewriter")
        retval.text = "HIGH SCORE"
        retval.fontColor = colorForScore(0)
        retval.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 30
        retval.zPosition = 10
        retval.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        retval.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        return retval
    }()
    
    let friendRankLabel: SKLabelNode = {
        let retval = SKLabelNode(fontNamed: "AmericanTypewriter")
        retval.text = "FRIEND RANK  NONE"
        retval.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 30
        retval.zPosition = 10
        retval.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        retval.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        return retval
    }()
    
    let noFriendsLabel: SKLabelNode = {
        let retval = SKLabelNode(fontNamed: "AmericanTypewriter")
        retval.text = "NO FRIENDS"
        retval.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 30
        retval.zPosition = 10
        retval.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        retval.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        return retval
    }()
    
    let gameOverLabel: SKLabelNode = {
        let retval = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        retval.text = "GAME OVER"
        retval.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 30
        retval.zPosition = 10
        retval.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        retval.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        return retval
    }()

    let achievementLabel: SKLabelNode = {
        let retval = SKLabelNode(fontNamed: "AmericanTypewriter")
        retval.text = "ACHIEVEMENT LEVEL"
        retval.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 30
        retval.zPosition = 10
        retval.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        retval.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        return retval
    }()
    
    var pacMan:SKShapeNode!
    
    // MARK: - Model
    var viewRadius: CGFloat!
    let pacManArc = M_PI * 0.45
    var pacManRadius: CGFloat!
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
    
    var turningClockwise = true
    var gameOver = true
    var readyToStartNewGame = true
    var nextPlaneLaunch:CFTimeInterval = 0
    
    /* Setup your scene here */
    override func didMove(to view: SKView) {
        viewRadius = hypot(view.frame.width, view.frame.height) / 2
        pacManRadius = viewRadius * 0.08
        
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addArc(center: CGPoint.zero, radius: pacManRadius, startAngle: CGFloat(pacManArc/2), endAngle: CGFloat(-pacManArc/2), clockwise: false)
        pacMan = SKShapeNode(path:path)
        pacMan.fillColor = SKColor.yellow
        pacMan.strokeColor = SKColor.clear
        pacMan.zPosition = 9999999
        pacMan.position = CGPoint(x: frame.midX, y: frame.midY)
        
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.name = "background"
        background.xScale = 2.0
        background.yScale = 2.0
        addChild(background)
        
        howto.position = CGPoint(x: frame.midX, y: frame.midY)
        howto.size = CGSize(width: viewRadius * 0.45, height: viewRadius * 0.45)
        var actions = [SKAction]()
        actions.append(SKAction.setTexture(SKTexture(imageNamed: "howto1")))
        actions.append(SKAction.run {
            let angle = CGFloat(Double(arc4random()) / 0x100000000 * 2 * M_PI)
            self.howto.run(SKAction.rotate(byAngle: angle, duration: 0))
        })
        actions.append(SKAction.wait(forDuration: 0.3))
        actions.append(SKAction.setTexture(SKTexture(imageNamed: "howto2")))
        actions.append(SKAction.wait(forDuration: 0.6))
        howto.run(SKAction.repeatForever(SKAction.sequence(actions)))
        addChild(self.howto)
    }

    func rotateToPoint(_ point: CGPoint) {
        let rotation = atan2(point.y - frame.height/2, point.x - frame.width/2)
        let rotationDifference = rotation - pacMan.zRotation
        let differenceQuadrant14 = (rotationDifference + CGFloat(M_PI)).truncatingRemainder(dividingBy: CGFloat(2 * M_PI)) - CGFloat(M_PI)
        if (differenceQuadrant14 > 0 && !turningClockwise) {
            run(ccwSound)
            turningClockwise = true
        } else if (differenceQuadrant14 < 0 && turningClockwise) {
            run(cwSound)
            turningClockwise = false
        }
        pacMan.zRotation = rotation
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let location = touches.first!.location(in: self)
        if self.atPoint(location) == self.clickMe {
            self.viewController.performSegue(withIdentifier: "friendRank", sender: self)
        } else if readyToStartNewGame {
            self.startGame()
        } else if !gameOver {
            self.rotateToPoint(location)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let touch = touches.first!
        rotateToPoint(touch.location(in: self))
    }
    
    func startGame() {
        readyToStartNewGame = false
        gameOver = false

        score = 0
        scoreLabel.removeFromParent()
        scoreLabel.text = "SCORE  \(score)"
        scoreLabel.fontColor = colorForScore(score)
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.size.height)
        addChild(scoreLabel)
        scoreLabel.run(SKAction.move(to: CGPoint(x: frame.midX, y: frame.size.height * 0.9), duration: 0.5))
        
        highScore = UserDefaults.standard.integer(forKey: "maxScore")
        highScoreLabel.removeFromParent()
        highScoreLabel.text = "HIGH SCORE  \(highScore)"
        highScoreLabel.fontColor = colorForScore(highScore)
        highScoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.size.height)
        addChild(highScoreLabel)
        highScoreLabel.run(SKAction.move(to: CGPoint(x: frame.midX, y: frame.size.height * 0.8), duration: 0.5))
        
        howto.removeFromParent()
        gameOverLabel.removeFromParent()
        achievementLabel.removeFromParent()
        friendRankLabel.removeFromParent()
        noFriendsLabel.removeFromParent()
        clickMe.removeFromParent()
        pacMan.zRotation = 0
        pacMan.fillColor = colorForScore(score)
        addChild(pacMan)
    }
    
    func gameOver(_ attackingPiece: SKNode) {
        guard !gameOver else {
            return
        }
        gameOver = true
        run(dieSound)

        enumerateChildNodes(withName: "plane") {
            (plane:SKNode, x) in
            plane.removeFromParent()
        }
        
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "maxScore")
        }
        highScoreLabel.text = "HIGH SCORE  \(highScore)"
        highScoreLabel.fontColor = colorForScore(highScore)

        // TODO: Calculate friend rank
        friendRankLabel.position = CGPoint(x: self.frame.midX, y: self.frame.size.height)
        addChild(friendRankLabel)
        friendRankLabel.run(SKAction.move(to: CGPoint(x: frame.midX, y: frame.size.height * 0.7), duration: 0.2))

        noFriendsLabel.position = CGPoint(x: self.frame.midX, y: 0)
        addChild(noFriendsLabel)
        noFriendsLabel.run(SKAction.move(to: CGPoint(x: frame.midX, y: frame.size.height * 0.3), duration: 0.2)) {
            self.clickMe.size.height = self.noFriendsLabel.frame.size.height * 1.5
            self.clickMe.size.width = self.noFriendsLabel.frame.size.height * 1.5
            self.clickMe.position.x = self.noFriendsLabel.position.x + self.noFriendsLabel.frame.width / 2 + self.clickMe.size.width
            self.clickMe.position.y = self.noFriendsLabel.position.y
            self.addChild(self.clickMe)
        }
        
        gameOverLabel.position = CGPoint(x: self.frame.midX, y: 0)
        addChild(gameOverLabel)
        gameOverLabel.run(SKAction.move(to: CGPoint(x: frame.midX, y: frame.size.height * 0.2), duration: 0.2))
        
        let level = achievementLevelForScore(score)
        achievementLabel.text = "\(level)"
        achievementLabel.position = CGPoint(x: self.frame.midX, y: 0)
        addChild(achievementLabel)
        achievementLabel.run(SKAction.move(to: CGPoint(x: frame.midX, y: frame.size.height * 0.1), duration: 0.2))
        
        
        let wait = SKAction.wait(forDuration: 1.5)
        let setReady = SKAction.run {
            self.pacMan.removeFromParent()
            self.addChild(self.howto)
            self.readyToStartNewGame = true
        }
        self.run(SKAction.sequence([wait, setReady]))
        
        let fr = FriendRank.shared
        fr.sendScoreToCloud(score: self.score)
    }
    
    /* Called before each frame is rendered */
    override func update(_ currentTime: TimeInterval) {
        guard !gameOver else {
            return
        }
        guard currentTime >= self.nextPlaneLaunch else {
            return
        }
        
        let interval:TimeInterval = 0.15 + 2/(Double(score) + 1)
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
                self.run(self.eatSound)
                let color = colorForScore(self.score)
                self.pacMan.fillColor = color
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
