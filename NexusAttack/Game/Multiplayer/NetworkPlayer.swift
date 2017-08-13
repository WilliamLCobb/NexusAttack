//
//  BaseAI.swift
//  NexusAttack
//
//  Created by Will Cobb on 7/2/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import Foundation
import SceneKit

protocol NetworkPlayerDelegae {
}

class NetworkPlayer: WCSocketDelegate {
    var player: Player {
        didSet {
            socket.player = player
        }
    }
    var gameUtility: GameUtilityDelegate
    var objects = [BaseObject]()
    var socket: WCSocket
    
    init(player: Player, networkRole: ConnectionRole) {
        self.player = player
        gameUtility = globalGameUtility
        socket = WCSocket(withPlayer:player, role: networkRole)
    }
    
    func connectToHost(_ host: String) {
        socket.connectToHost(host)
    }
    
    func sendObject(object: BaseObject) {
        socket.sendObject(object)
    }
    
    func receivedObject(object: BuildingSpawner, atTime: TimeInterval) {
        let currentTime = gameUtility.currentTime
        object.spawnTime += currentTime - atTime
        _ = gameUtility.spawn(building: object)
    }
    
    func startGame() {
        
    }
    
    func updatedPlayer(player: Player) {
        
    }
    
    func update(dt: TimeInterval) {
        
    }
}
