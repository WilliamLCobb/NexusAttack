//
//  Human.swift
//  NexusAttack
//
//  Created by Will Cobb on 7/8/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import Foundation
import SceneKit

// MARK: Buildings

class HumanBarracks: BuildingSpawner {
    var bodyModel: SCNSphere!
    
    override func configureModel() {
        self.attackRadius = 3
        self.size = int2(2, 2)
        
        self.setModel(named: "HumanBarracks", scale: 0.01)
        
        self.position.y = 0
        
        health = 2000
        healthBar = addHealthBar(y: 2.5, health: health, size: .large, showsProgress: true)
        
        let collisionBody = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: collisionBody, options: nil))
        self.physicsBody?.friction = 0
        
        self.cost = 100
    }
    
    override func createUnit() -> Unit {
        let unit = HumanMilitia(player: self.owner,
                                position: SCNVector3Zero,
                                target: self.target)
        return unit
    }
    
    override func copy() -> Any {
        return HumanBarracks.init(player: self.owner, position: self.position, target: self.target)
    }
}

class HumanTower: Tower {
    var bodyModel: SCNSphere!
    
    override func configureNode() {
        damage = 15
        self.size = int2(1, 1)
        self.attackRadius = 6
        health = 1000
    }
    
    override func configureModel() {
        self.setModel(named: "HumanTower", scale: 0.01)
        
        self.position.y = 0.5
        
        healthBar = addHealthBar(y: 2.5, health: health, size: .large, showsProgress: true)
        
        let collisionBody = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: collisionBody, options: nil))
        self.physicsBody?.friction = 0
        
        self.cost = 100
    }
    
    override func copy() -> Any {
        return HumanTower.init(player: self.owner, position: self.position)
    }
}



// MARK: Units

class HumanMilitia: AutoUnit {
    let radius: CGFloat = 0.4
    
    var bodyModel: SCNSphere!
    var body: SCNNode!
    
    override func configureModel() {
        super.configureModel()
        
        bodyModel = SCNSphere(radius: radius)
        body = SCNNode(geometry: bodyModel)
        
        self.setModel(named: "Militia", scale: 0.01)
        
        self.position.y = 0.2
        
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: bodyModel, options: nil))
        self.physicsBody?.angularVelocityFactor = SCNVector3(x: 0, y: 0, z: 0)
        self.physicsBody?.velocityFactor = SCNVector3(x: 1, y: 0, z: 1)
        self.physicsBody?.rollingFriction = 0
        self.physicsBody?.friction = 0
        
        healthBar = self.addHealthBar(y: 1.5, health: health, size: .medium, showsProgress: false)
        
        self.health = 100
        self.targetingRange = 8
        self.attackRange = 2
        self.mineralValue = 2
    }
    
    override func update(dt: TimeInterval) {
        super.update(dt: dt)
    }
    
    override func beginAnimation(animation: AnimationType) {
        switch animation {
        case .idle:
            break
        case .running:
            self.runAnimationFrom(start: 0.7, to: 1.33, repeats: true)
        case .attacking:
            self.runAnimationFrom(start: 5.2, to: 6.5, repeats: false)
        }
    }
    
    override func attackEnemy(enemy: BaseObject) {
        let damage = Float(arc4random_uniform(10) + 10)
        enemy.attackedWithDamage(damage: damage)
    }
}
