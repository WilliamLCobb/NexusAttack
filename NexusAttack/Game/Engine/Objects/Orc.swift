//
//  Orc.swift
//  NexusAttack
//
//  Created by Will Cobb on 7/8/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import Foundation
import SceneKit

// MARK: Buildings

class Fortress: Nexus {
    var bodyModel: SCNSphere!
    
    override func configureModel() {
        
        self.setModel(named: "Fortress", scale: 0.01)
        
        self.position.y = 0
        healthBar = addHealthBar(y: 2.5, health: health, size: .large, showsProgress: false)
        
        let collisionBody = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: collisionBody, options: nil))
        self.physicsBody?.friction = 0
        
    }
}

class OrcBarracks: BuildingSpawner {
    var bodyModel: SCNSphere!
    
    override func configureNode() {
        attackRadius = 3
        size = int2(2, 2)
        health = 2000
        cost = 200
    }
    
    override func configureModel() {
        self.setModel(named: "OrcBarracks", scale: 0.01)
        
        self.position.y = 0.5
        healthBar = addHealthBar(y: 2.5, health: health, size: .large, showsProgress: true)
        
        let collisionBody = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: collisionBody, options: nil))
        self.physicsBody?.friction = 0
    }
    
    override func createUnit() -> Unit {
        let unit = OrcGrunt(player: self.owner,
                            position: SCNVector3Zero,
                            target: self.target)
        return unit
    }
    
    override func copy() -> Any {
        return OrcBarracks.init(player: self.owner, position: self.position, target: self.target)
    }
}

class SpiritLodge: BuildingSpawner {
    var bodyModel: SCNSphere!
    
    override func configureNode() {
        attackRadius = 3
        size = int2(2, 2)
        health = 2000
        cost = 200
    }
    
    override func configureModel() {
        self.setModel(named: "SpiritLodge", scale: 0.01)
        
        self.position.y = 0.5
        healthBar = addHealthBar(y: 2.5, health: health, size: .large, showsProgress: true)
        
        let collisionBody = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: collisionBody, options: nil))
        self.physicsBody?.friction = 0
    }
    
    override func createUnit() -> Unit {
        let unit = Shaman(player: self.owner,
                            position: SCNVector3Zero,
                            target: self.target)
        return unit
    }
    
    override func copy() -> Any {
        return SpiritLodge.init(player: self.owner, position: self.position, target: self.target)
    }
}

class TaurenTotem: BuildingSpawner {
    var bodyModel: SCNSphere!
    
    override func configureNode() {
        attackRadius = 3
        size = int2(2, 2)
        health = 2000
        cost = 200
    }
    
    override func configureModel() {
        self.setModel(named: "TaurenTotem", scale: 0.01)
        
        self.position.y = 0.5
        healthBar = addHealthBar(y: 2.5, health: health, size: .large, showsProgress: true)
        
        let collisionBody = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: collisionBody, options: nil))
        self.physicsBody?.friction = 0
    }
    
    override func createUnit() -> Unit {
        let unit = Tauren(player: self.owner,
                            position: SCNVector3Zero,
                            target: self.target)
        return unit
    }
    
    override func copy() -> Any {
        return TaurenTotem.init(player: self.owner, position: self.position, target: self.target)
    }
}

class WarMill: BuildingSpawner {
    var bodyModel: SCNSphere!
    
    override func configureNode() {
        attackRadius = 3
        size = int2(2, 2)
        health = 2000
        cost = 200
    }
    
    override func configureModel() {
        
        self.setModel(named: "WarMill", scale: 0.01)
        
        self.position.y = 0.5
        healthBar = addHealthBar(y: 2.5, health: health, size: .large, showsProgress: true)
        
        let collisionBody = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: collisionBody, options: nil))
        self.physicsBody?.friction = 0
    }
    
    override func createUnit() -> Unit {
        let unit = OrcGrunt(player: self.owner,
                            position: SCNVector3Zero,
                            target: self.target)
        return unit
    }
    
    override func copy() -> Any {
        return WarMill.init(player: self.owner, position: self.position, target: self.target)
    }
}

class Beastiary: BuildingSpawner {
    var bodyModel: SCNSphere!
    
    override func configureNode() {
        attackRadius = 3
        size = int2(2, 2)
        health = 2000
        cost = 200
    }
    
    override func configureModel() {
        self.setModel(named: "Beastiary", scale: 0.01)
        
        self.position.y = 0.5
        healthBar = addHealthBar(y: 2.5, health: health, size: .large, showsProgress: true)
        
        let collisionBody = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: collisionBody, options: nil))
        self.physicsBody?.friction = 0
    }
    
    override func createUnit() -> Unit {
        let unit = KodoRider(player: self.owner,
                            position: SCNVector3Zero,
                            target: self.target)
        return unit
    }
    
    override func copy() -> Any {
        return Beastiary.init(player: self.owner, position: self.position, target: self.target)
    }
}

// MARK: Units

class OrcGrunt: AutoUnit, AnimatableObject {
    let radius: CGFloat = 0.4
    let damageLow = 10
    let damageHigh = 20
    
    var bodyModel: SCNSphere!
    var body: SCNNode!
    
    override func configureNode() {
        health = 80
        targetingRange = 8
        attackRange = 1.5
        mineralValue = 2
        attackSpeed = 1
        speed = 3
    }
    
    override func configureModel() {
        super.configureModel()
        
        bodyModel = SCNSphere(radius: radius)
        body = SCNNode(geometry: bodyModel)
        
        self.setModel(named: "Grun6", scale: 1)
        
        self.position.y = 0.2
        
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: bodyModel, options: nil))
        self.physicsBody?.angularVelocityFactor = SCNVector3(x: 0, y: 0, z: 0)
        self.physicsBody?.velocityFactor = SCNVector3(x: 1, y: 0, z: 1)
        self.physicsBody?.rollingFriction = 0
        self.physicsBody?.friction = 0
        
        healthBar = self.addHealthBar(y: 1.5, health: health, size: .medium, showsProgress: false)
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
        let damage = Int(arc4random_uniform(UInt32(damageHigh - damageLow))) + damageLow
        enemy.attackedWithDamage(damage: damage)
    }
}

class Tauren: AutoUnit, AnimatableObject {
    let radius: CGFloat = 0.4
    let damageLow = 30
    let damageHigh = 40
    
    var bodyModel: SCNSphere!
    var body: SCNNode!
    
    override func configureNode() {
        health = 180
        targetingRange = 8
        attackRange = 1.5
        mineralValue = 4
        attackSpeed = 3
        speed = 2.3
    }
    
    override func configureModel() {
        super.configureModel()
        
        bodyModel = SCNSphere(radius: radius)
        body = SCNNode(geometry: bodyModel)
        
        self.setModel(named: "Tauren", scale: 1)
        
        self.position.y = 0.2
        
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: bodyModel, options: nil))
        self.physicsBody?.angularVelocityFactor = SCNVector3(x: 0, y: 0, z: 0)
        self.physicsBody?.velocityFactor = SCNVector3(x: 1, y: 0, z: 1)
        self.physicsBody?.rollingFriction = 0
        self.physicsBody?.friction = 0
        
        healthBar = self.addHealthBar(y: 1.5, health: health, size: .medium, showsProgress: false)
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
        let damage = Int(arc4random_uniform(UInt32(damageHigh - damageLow))) + damageLow
        enemy.attackedWithDamage(damage: damage)
    }
}

class Shaman: AutoUnit, AnimatableObject {
    let radius: CGFloat = 0.4
    let damageLow = 20
    let damageHigh = 25
    
    var bodyModel: SCNSphere!
    var body: SCNNode!
    
    override func configureNode() {
        health = 80
        targetingRange = 9
        attackRange = 6
        mineralValue = 2
        attackSpeed = 1.3
        speed = 3
    }
    
    override func configureModel() {
        super.configureModel()
        
        bodyModel = SCNSphere(radius: radius)
        body = SCNNode(geometry: bodyModel)
        
        self.setModel(named: "Shaman", scale: 1)
        
        self.position.y = 0.2
        
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: bodyModel, options: nil))
        self.physicsBody?.angularVelocityFactor = SCNVector3(x: 0, y: 0, z: 0)
        self.physicsBody?.velocityFactor = SCNVector3(x: 1, y: 0, z: 1)
        self.physicsBody?.rollingFriction = 0
        self.physicsBody?.friction = 0
        
        healthBar = self.addHealthBar(y: 1.5, health: health, size: .medium, showsProgress: false)
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
        let damage = Int(arc4random_uniform(UInt32(damageHigh - damageLow))) + damageLow
        let missile = Missile(player: self.owner,
                              position: self.presentation.position,
                              target: enemy,
                              damage: damage)
        missile.speed = 15
        self.gameUtility.spawn(missile: missile)
    }
}

class WindRider: AutoUnit, AnimatableObject {
    let radius: CGFloat = 0.4
    let damageLow = 10
    let damageHigh = 20
    
    var bodyModel: SCNSphere!
    var body: SCNNode!
    
    override func configureNode() {
        health = 130
        targetingRange = 8
        attackRange = 1.5
        mineralValue = 2
        attackSpeed = 1
        speed = 4
    }
    
    override func configureModel() {
        super.configureModel()
        
        bodyModel = SCNSphere(radius: radius)
        body = SCNNode(geometry: bodyModel)
        
        self.setModel(named: "WindRider", scale: 1)
        
        self.position.y = 0.2
        
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: bodyModel, options: nil))
        self.physicsBody?.angularVelocityFactor = SCNVector3(x: 0, y: 0, z: 0)
        self.physicsBody?.velocityFactor = SCNVector3(x: 1, y: 0, z: 1)
        self.physicsBody?.rollingFriction = 0
        self.physicsBody?.friction = 0
        
        healthBar = self.addHealthBar(y: 1.5, health: health, size: .medium, showsProgress: false)
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
        let damage = Int(arc4random_uniform(UInt32(damageHigh - damageLow))) + damageLow
        let missile = Missile(player: self.owner,
                              position: self.presentation.position,
                              target: enemy,
                              damage: damage)
        missile.speed = 15
        self.gameUtility.spawn(missile: missile)
    }
}

class KodoRider: AutoUnit, AnimatableObject {
    let radius: CGFloat = 0.4
    let damageLow = 20
    let damageHigh = 30
    
    var bodyModel: SCNSphere!
    var body: SCNNode!
    
    override func configureNode() {
        health = 210
        targetingRange = 8
        attackRange = 1.5
        mineralValue = 5
        attackSpeed = 2.5
    }
    
    override func configureModel() {
        super.configureModel()
        
        bodyModel = SCNSphere(radius: radius)
        body = SCNNode(geometry: bodyModel)
        
        self.setModel(named: "KodoBeast", scale: 1)
        
        self.position.y = 0.2
        
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: bodyModel, options: nil))
        self.physicsBody?.angularVelocityFactor = SCNVector3(x: 0, y: 0, z: 0)
        self.physicsBody?.velocityFactor = SCNVector3(x: 1, y: 0, z: 1)
        self.physicsBody?.rollingFriction = 0
        self.physicsBody?.friction = 0
        
        healthBar = self.addHealthBar(y: 1.5, health: health, size: .medium, showsProgress: false)
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
        let damage = Int(arc4random_uniform(UInt32(damageHigh - damageLow))) + damageLow
        enemy.attackedWithDamage(damage: damage)
    }
}
