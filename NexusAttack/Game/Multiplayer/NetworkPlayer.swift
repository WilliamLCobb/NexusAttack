//
//  BaseAI.swift
//  NexusAttack
//
//  Created by Will Cobb on 7/2/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import Foundation
import SceneKit
import CocoaAsyncSocket

class NetworkPlayer: NSObject, GCDAsyncSocketDelegate {
    var player: Player
    var gameScene: GameScene
    var gameUtility: GameUtilityDelegate
    var objects = [BaseObject]()
    var socket: GCDAsyncSocket!
    
    init(gameScene: GameScene, player: Player) {
        self.gameScene = gameScene
        self.player = player
        gameUtility = globalGameUtility
        super.init()
        socket = GCDAsyncSocket(delegate: self, delegateQueue: nil)
        if ((try? socket.connect(toHost: "192.168.0.7", onPort: 5020)) == nil) {
            assertionFailure("Unable to connect")
        }
        socket.readData(to: "!".data(using: String.Encoding.utf8)!, withTimeout: 30, tag: 0)
    }
    
    func update(dt: TimeInterval) {
        
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("Disconnected!")
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("Read Data:", data)
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("Connected to", host)
    }
}
