//
//  StarNode.swift
//  UberJump
//
//  Created by Esti Tweg on 2019-01-19.
//  Copyright © 2019 Esti Tweg. All rights reserved.
//
//  Followed Ray Wenderlich tutorial in Objective-C by Toby Stephens
//  https://www.raywenderlich.com/2467-how-to-make-a-game-like-mega-jump-with-sprite-kit-part-2-2

import Foundation
import SpriteKit

enum StarType: Int {
    case STAR_NORMAL = 0
    case STAR_SPECIAL = 1
}

class StarNode: GameObjectNode {
    
    var starType: StarType?
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        //change velocity, fixed amount, all star collisions have same effect
        player.physicsBody?.velocity = CGVector(dx: (player.physicsBody?.velocity.dx)!, dy: 400.0)
        removeFromParent()
        
        // Award score
        GameState.sharedInstance.score += (starType == StarType.STAR_SPECIAL ? 100 : 20)
        GameState.sharedInstance.stars += (starType == StarType.STAR_SPECIAL ? 5 : 1)
        
        return true

    }
  
    
}
