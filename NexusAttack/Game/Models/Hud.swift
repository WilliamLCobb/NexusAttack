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
    var mineralsLabel = SKLabelNode(fontNamed: "Avenir Next Condensed-Bold")
    init(size: CGSize, player: Player) {
        self.player = player
        super.init(size: size)
        mineralsLabel.fontSize = 13
        mineralsLabel.fontColor = SKColor.black
        mineralsLabel.position = CGPoint(x: size.width - 50, y: size.height - 20)
        addChild(mineralsLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(dt: TimeInterval) {
        mineralsLabel.text = String(format: "%d minerals", player.minerals)
    }
}
