//
//  Environment.swift
//  NexusAttack
//
//  Created by Will Cobb on 7/1/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import UIKit
import SpriteKit


class Hud: SKScene {
    var player: Player
    var goldLabel = SKLabelNode(fontNamed: "Avenir Next Condensed-Bold")
    init(size: CGSize, player: Player) {
        self.player = player
        super.init(size: size)
        goldLabel.fontSize = 13
        goldLabel.fontColor = SKColor.black
        goldLabel.position = CGPoint(x: size.width - 50, y: size.height - 20)
        addChild(goldLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(dt: TimeInterval) {
        goldLabel.text = String(format: "%d gold", player.gold)
    }
}
