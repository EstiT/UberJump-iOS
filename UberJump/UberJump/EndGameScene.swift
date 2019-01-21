//
//  EndGameScene.swift
//  UberJump
//
//  Created by Esti Tweg on 2019-01-19.
//  Copyright © 2019 Esti Tweg. All rights reserved.
//
//  Followed Ray Wenderlich tutorial in Objective-C by Toby Stephens
//  https://www.raywenderlich.com/2467-how-to-make-a-game-like-mega-jump-with-sprite-kit-part-2-2

import Foundation
import SpriteKit

class EndGameScene: SKScene{
    
    init(size: CGSize, won:Bool) {
        super.init(size: size)
        
        // Stars
        let star = SKSpriteNode(imageNamed: "Star")
        star.position = CGPoint(x: 25, y: size.height - 30)
        addChild(star)
        let lblStars = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblStars.fontSize = 30
        lblStars.fontColor = SKColor.white
        lblStars.position = CGPoint(x: 50, y: size.height - 40)
        lblStars.horizontalAlignmentMode = .left
        lblStars.text = "X \(GameState.sharedInstance.stars)"
        addChild(lblStars)
        
        // Score
        let lblScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblScore.fontSize = 60
        lblScore.fontColor = SKColor.white
        lblScore.position = CGPoint(x: 160, y: 300)
        lblScore.horizontalAlignmentMode = .center
        lblScore.text = "\(GameState.sharedInstance.score)"
        addChild(lblScore)
        
        // High Score
        let lblHighScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblHighScore.fontSize = 30
        lblHighScore.fontColor = SKColor.cyan
        lblHighScore.position = CGPoint(x: 160, y: 150)
        lblHighScore.horizontalAlignmentMode = .center
        lblHighScore.text = "High Score: \(GameState.sharedInstance.highScore)"
        addChild(lblHighScore)
        
        // Try again
        let lblTryAgain = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblTryAgain.fontSize = 30
        lblTryAgain.fontColor = SKColor.white
        lblTryAgain.position = CGPoint(x: 160, y: 50)
        lblTryAgain.horizontalAlignmentMode = .center
        lblTryAgain.text = "Tap To Try Again"
        addChild(lblTryAgain)
       
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Transition back to the game on tap
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = .resizeFill
        gameScene.anchorPoint = CGPoint(x: 0.05, y: 0.05)
        let reveal = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(gameScene, transition: reveal)
        
    }
}
