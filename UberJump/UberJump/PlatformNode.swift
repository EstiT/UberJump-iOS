//
//  PlatformNode.swift
//  UberJump
//
//  Created by Esti Tweg on 2019-01-19.
//  Copyright © 2019 Esti Tweg. All rights reserved.
//
//  Followed Ray Wenderlich tutorial in Objective-C by Toby Stephens
//  https://www.raywenderlich.com/2467-how-to-make-a-game-like-mega-jump-with-sprite-kit-part-2-2

import Foundation
import SpriteKit


enum PlatformType: Int {
    case PLATFORM_NORMAL = 0
    case PLATFORM_BREAK = 1
}

class PlatformNode: GameObjectNode {
    var platformType: PlatformType?
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        if (player.physicsBody?.velocity.dy)! < CGFloat(0) { //falling
                player.physicsBody?.velocity = CGVector(dx: (player.physicsBody?.velocity.dx)!, dy: 250)
        }
        return false
    }


}
