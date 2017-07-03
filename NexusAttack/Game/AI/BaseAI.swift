//
//  BaseAI.swift
//  NexusAttack
//
//  Created by Will Cobb on 7/2/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import Foundation
import SceneKit

class BaseAI {
    var player: Player
    var gameScene: GameScene
    var gameUtility: GameUtilityDelegate
    var lastPlayTime: TimeInterval = 118
    var buildings: [Building]
    var nextBuilding: Building!
    
    init(gameScene: GameScene, player: Player) {
        self.gameScene = gameScene
        self.player = player
        gameUtility = globalGameUtility
        buildings = [AttackSpawner(player: gameScene.player2, position: SCNVector3(x:-100, y: 0, z: 0), target: gameScene.nexus1),
                     RangedSpawner(player: gameScene.player2, position: SCNVector3(x:-100, y: 0, z: 0), target: gameScene.nexus1)]
        nextBuilding = buildings.first
        
    }
    
    func update(dt: TimeInterval) {
        if nextBuilding == nil {
            nextBuilding = buildings.randomItem()
        }
        lastPlayTime += dt
        if (lastPlayTime > 5) {
            if player.minerals > nextBuilding.cost {
                let x = Int32(arc4random_uniform(20)) + 31
                let z = Int32(arc4random_uniform(28)) - 14
                let newBuilding = nextBuilding.copy() as! Building
                DispatchQueue.main.async {
                    newBuilding.position.x = Float(x)
                    newBuilding.position.z = Float(z)
                    if self.gameUtility.spawn(building: newBuilding) {
                        self.lastPlayTime = 0
                        print("BaseAI: Placed Building at ", x, z)
                    }
                }
            }
        }
    }
}
