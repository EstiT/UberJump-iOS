//
//  GameScene.swift
//  UberJump
//
//  Created by Esti Tweg on 2019-01-18.
//  Copyright © 2019 Esti Tweg. All rights reserved.
//
//  Followed Ray Wenderlich tutorial in Objective-C by Toby Stephens
//  https://www.raywenderlich.com/2467-how-to-make-a-game-like-mega-jump-with-sprite-kit-part-2-2

import SpriteKit
import GameplayKit
import CoreMotion

struct PhysicsCategory {
    static let CollisionCategoryPlayer   : UInt32  = 0x1 << 0  //0 single 32-bit integer, acting as a bitmask
    static let CollisionCategoryStar      : UInt32  = 0x1 << 1 //1
    static let CollisionCategoryPlatform   : UInt32 =  0x1 << 2     // 2
}


class GameScene: SKScene {
    
    var backgroundNode = SKSpriteNode()
    var midgroundNode = SKNode()
    var foregroundNode = SKNode()
    var hudNode = SKNode()
    var player = SKNode()
    
    var tapToStartNode = SKSpriteNode()
    
    var endLevelY: Int
    var maxPlayerY: Int
    let levelPlist: String
    let levelData: NSDictionary
    
    let motionManager = CMMotionManager()
    var xAcceleration: CGFloat
    
    var scoreLabel = SKLabelNode()
    var starLabel = SKLabelNode()
    
    var gameOver: Bool = false

    
    override func sceneDidLoad() {
        backgroundColor = SKColor.white
        backgroundNode = createBackgroundNode()
//        backgroundNode.position = CGPoint(x: size.width/2, y: size.height/2)
//        backgroundNode.size =  self.frame.size
        addChild(backgroundNode)
        
        // Add the platforms
        if let platforms = levelData["Platforms"] as? [AnyHashable : Any] {
            if let platformPatterns = platforms["Patterns"] as? [AnyHashable : Any]{
                if let platformPositions = platforms["Positions"] as? [Any]{
                    
                    for platformPosition: [AnyHashable : Any]? in platformPositions as? [[AnyHashable : Any]?] ?? [] {
                        let patternX =  CGFloat(((platformPosition?["x"] as? NSNumber)?.floatValue)!)
                        let patternY =  CGFloat(((platformPosition?["y"] as? NSNumber)?.floatValue)!)
                        let pattern = platformPosition?["pattern"] as! String
                        
                        // Look up the pattern
                        if let platformPattern = platformPatterns[pattern] as? NSArray{
                            for platformPoint: [AnyHashable : Any]? in platformPattern as! [[AnyHashable : Any]?] {
                                let x = CGFloat(((platformPoint?["x"] as? NSNumber)?.floatValue)!)
                                let y = CGFloat(((platformPoint?["y"] as? NSNumber)?.floatValue)!)
                                if let type = platformPoint?["type"] as? Int{
                                    let platformNode: PlatformNode? = createPlatformAtPosition(position: CGPoint(x: x + patternX, y: y + patternY), type: PlatformType(rawValue: type)!)
                                    if let platformNode = platformNode {
                                        foregroundNode.addChild(platformNode)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Add the stars
        if let stars = levelData["Stars"] as? [AnyHashable : Any] {
            if let starPatterns = stars["Patterns"] as? [AnyHashable : Any]{
                if let starPositions = stars["Positions"] as? [Any]{
                    for starPosition: [AnyHashable : Any]? in starPositions as? [[AnyHashable : Any]?] ?? [] {
                        let patternX = CGFloat(((starPosition?["x"] as? NSNumber)?.floatValue)!)
                        let patternY = CGFloat(((starPosition?["y"] as? NSNumber)?.floatValue)!)
                        if let pattern = starPosition?["pattern"] as? String{
                            // Look up the pattern
                            let starPattern = starPatterns[pattern] as? NSArray
                            for starPoint: [AnyHashable : Any]? in starPattern as! [[AnyHashable : Any]?] {
                                let x = CGFloat(((starPoint?["x"] as? NSNumber)?.floatValue)!)
                                let y = CGFloat(((starPoint?["y"] as? NSNumber)?.floatValue)!)
                                if let type = starPoint?["type"] as? Int{
                                    let starNode: StarNode? = createStarAtPosition(position: CGPoint(x: x + patternX, y: y + patternY), type: StarType(rawValue: type)!)
                                    if let starNode = starNode {
                                        foregroundNode.addChild(starNode)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        player = createPlayer()
        foregroundNode.addChild(player)
        addChild(foregroundNode)
        
        // Tap to Start
        tapToStartNode = SKSpriteNode(imageNamed: "TapToStart")
        tapToStartNode.position = CGPoint(x: 160, y: 180.0)
        
        hudNode.addChild(tapToStartNode)
        // Stars
        
        let star = SKSpriteNode(imageNamed: "Star")
        star.position = CGPoint(x: 10, y: 110) //top left corner
        hudNode.addChild(star)
        
        starLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        starLabel.fontSize = 30
        starLabel.fontColor = SKColor.white
        starLabel.position = CGPoint(x: 80, y: 100)//size.height - 40
        starLabel.horizontalAlignmentMode = .right
        starLabel.text = "X \(GameState.sharedInstance.stars)" //set text
        hudNode.addChild(starLabel)
        
        // Score
        scoreLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: 80, y: 70) //bottom left corner
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.text = "0" //starting score
        hudNode.addChild(scoreLabel)
        addChild(hudNode)
    
        
        // CoreMotion
        motionManager.accelerometerUpdateInterval = 0.2
        if let current = OperationQueue.current {
            motionManager.startAccelerometerUpdates(to: current, withHandler: {
                accelerometerData, error in
                let acceleration: CMAcceleration? = accelerometerData?.acceleration
                self.xAcceleration = CGFloat(Float(((acceleration?.x)!) * 0.75)) + (self.xAcceleration * 0.25)
            })
        }
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -2.0)
        physicsWorld.contactDelegate = self
    
    }
    
    
    override init(size: CGSize){
        // Load the level
        levelPlist = Bundle.main.path(forResource: "Level01", ofType: "plist")!
        levelData = NSDictionary(contentsOfFile: levelPlist)!
        
        endLevelY = levelData["EndY"] as! Int
        maxPlayerY = 80
        xAcceleration = 0
        GameState.sharedInstance.score = 0 //reset the game each time
        GameState.sharedInstance.stars = 0
        gameOver = false
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        // Load the level
        levelPlist = Bundle.main.path(forResource: "Level01", ofType: "plist")!
        levelData = NSDictionary(contentsOfFile: levelPlist)!
        
        endLevelY = levelData["EndY"] as! Int
        maxPlayerY = 80
        xAcceleration = 0
        GameState.sharedInstance.score = 0
        GameState.sharedInstance.stars = 0
        gameOver = false
        
        super.init(coder: aDecoder)
    }
    
    
    override func update(_ currentTime: CFTimeInterval){
        if gameOver {
            return 
        }
        //award points for travelling higher
        if Int(player.position.y) > maxPlayerY {
            GameState.sharedInstance.score += Int(player.position.y) - maxPlayerY
            maxPlayerY = Int(player.position.y)
            scoreLabel.text = "\(GameState.sharedInstance.score)"
        }
        
        // Calculate player y offset
        if player.position.y > 200.0 {
            backgroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - 200.0)/10))
            midgroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - 200.0)/4))
            foregroundNode.position = CGPoint(x: 0.0, y: -(player.position.y - 200.0))
        }
        
        // Remove game objects that have passed by
        foregroundNode.enumerateChildNodes(withName: "NODE_PLATFORM", using: { node, stop in
            (node as? PlatformNode)?.checkNodeRemoval(playerY: self.player.position.y)
        })
        foregroundNode.enumerateChildNodes(withName: "NODE_STAR", using: { node, stop in
            (node as? StarNode)?.checkNodeRemoval(playerY: self.player.position.y)
        })
        
        //check if the game is over
        //finished level
        if Int(player.position.y) > endLevelY {
            endGame()
        }
        //fell
        if Int(player.position.y) < (maxPlayerY - 400){ // 400 magic number screen size?
            endGame()
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if player.physicsBody?.isDynamic == true {
            return
        }
        tapToStartNode.removeFromParent()
        player.physicsBody?.isDynamic = true
        player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 20.0))
    }
    
    func createBackgroundNode() -> SKSpriteNode{
        let bgNode = SKSpriteNode()
        for nodeCount in 0..<20 {
            let bgName = String(format: "Background%02d", nodeCount+1)
            let node = SKSpriteNode(imageNamed: bgName)
            node.zPosition = -1
            node.anchorPoint = CGPoint(x:0.5, y:0.0)
            node.position = CGPoint(x:160, y:nodeCount*64)
            bgNode.addChild(node)
        }
        return bgNode
    }
    
    func createPlayer() -> SKNode{
        let playerNode = SKNode()
        playerNode.position = CGPoint(x:160, y:80)
        
        let sprite = SKSpriteNode(imageNamed: "Player")
        playerNode.addChild(sprite)
        
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
        playerNode.physicsBody?.isDynamic = false
        playerNode.physicsBody?.allowsRotation = true
        playerNode.physicsBody?.restitution = 1.0
        playerNode.physicsBody?.friction = 0.0
        playerNode.physicsBody?.angularDamping = 0.0
        playerNode.physicsBody?.linearDamping = 0.0
        
        playerNode.physicsBody?.usesPreciseCollisionDetection = true
        playerNode.physicsBody?.categoryBitMask = PhysicsCategory.CollisionCategoryPlayer
        playerNode.physicsBody?.collisionBitMask = 0
        playerNode.physicsBody?.contactTestBitMask = PhysicsCategory.CollisionCategoryStar | PhysicsCategory.CollisionCategoryPlatform
        
        return playerNode;
    }
    
    func createStarAtPosition(position: CGPoint, type: StarType) -> StarNode{
        let node = StarNode()
        node.starType = type
        let sprite : SKSpriteNode
        if type == StarType.STAR_SPECIAL {
            sprite = SKSpriteNode(imageNamed: "StarSpecial")
        }
        else{
            sprite = SKSpriteNode(imageNamed: "Star")
        }
        node.position = position
        node.name = "NODE_STAR"
        
        node.addChild(sprite)
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = PhysicsCategory.CollisionCategoryStar
        node.physicsBody?.collisionBitMask = 0
    
        return node
    }

    func createPlatformAtPosition(position: CGPoint, type: PlatformType) -> PlatformNode{
        let node = PlatformNode()
        node.position = position
        node.name = "NODE_PLATFORM"
        node.platformType = type
        
        let sprite : SKSpriteNode
        if type == PlatformType.PLATFORM_BREAK {
            sprite = SKSpriteNode(imageNamed: "PlatformBreak")
        }
        else {
            sprite = SKSpriteNode(imageNamed: "Platform")
        }
        node.addChild(sprite)

        node.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.CollisionCategoryPlatform
        node.physicsBody?.collisionBitMask = 0;
        
        return node;
    }
    
    
    override func didSimulatePhysics() {
        // Set velocity based on x-axis acceleration
        player.physicsBody?.velocity = CGVector(dx: xAcceleration * 400.0, dy: (player.physicsBody?.velocity.dy)!)
    
        // Check x bounds
        if player.position.x < -20.0 {
            player.position = CGPoint(x: 340.0, y: player.position.y)
        }
        else if player.position.x > 340.0 {
            player.position = CGPoint(x: -20.0, y: player.position.y)
        }
        return
    }
    
    func buildHud(){
        // Stars

        let star = SKSpriteNode(imageNamed: "Star")
        star.position = CGPoint(x: 25, y: size.height - 30)
        star.zPosition = 10
        hudNode.addChild(star)
        
        starLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        starLabel.fontSize = 30
        starLabel.zPosition = 10
        starLabel.fontColor = SKColor.white
        starLabel.position = CGPoint(x: 50, y: size.height - 40)
        starLabel.horizontalAlignmentMode = .left
        starLabel.text = "X \(GameState.sharedInstance.stars)" //set text
        hudNode.addChild(starLabel)
        
        // Score
        scoreLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        scoreLabel.fontSize = 30
        scoreLabel.zPosition = 10
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: size.width - 20, y: size.height - 40)
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.text = "0" //starting score 
        hudNode.addChild(scoreLabel)

    }
    
    
    func endGame(){
        gameOver = true
        GameState.sharedInstance.saveState()
        let reveal = SKTransition.fade(withDuration: 0.5)//flipHorizontal(withDuration: 0.5)
        let endGameScene = EndGameScene(size: self.size, won: false)
        self.view?.presentScene(endGameScene, transition: reveal)
    }
}

extension GameScene: SKPhysicsContactDelegate {
    //called whenever there is a collision and contactTestBitMasks are correctly set
    func didBegin(_ contact: SKPhysicsContact) { //contact delegate method implementation
        var updateHUD = true
        
        let other = ((contact.bodyA.node != player) ? contact.bodyA.node : contact.bodyB.node) as! GameObjectNode
        
        updateHUD = other.collisionWithPlayer(player: player)
        
        // Update the HUD if necessary
        if (updateHUD) {
            scoreLabel.text = String(GameState.sharedInstance.score)
            starLabel.text = String(GameState.sharedInstance.stars)
        }
  
    }
    
    
    
}
