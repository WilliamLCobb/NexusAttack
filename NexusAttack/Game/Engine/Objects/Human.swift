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
    
    override func configureNode() {
        name = "Barracks"
        attackRadius = 3
        size = int2(2, 2)
        health = 2000
        cost = 200
    }
    
    override func configureModel() {
        super.configureModel()
        self.setModel(named: "HumanBarracks", scale: 0.007)
        
        self.position.y = 0
        
        healthBar = addHealthBar(y: 2.5, health: health, size: .large, showsProgress: true)
        
        let collisionBody = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: collisionBody, options: nil))
        self.physicsBody?.friction = 0
    }
    
    override func createUnit() -> Unit {
        let unit = Footman(player: self.owner,
                                position: SCNVector3Zero,
                                target: self.target)
        return unit
    }
    
    override func copy() -> Any {
        return HumanBarracks.init(player: self.owner, position: self.position)
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
        super.configureModel()
        self.setModel(named: "HumanTower", scale: 0.007)
        
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

class ArcaneSanctum: BuildingSpawner {
    var bodyModel: SCNSphere!
    
    override func configureNode() {
        super.configureModel()
        name = "Arcane Sanctum"
        attackRadius = 3
        size = int2(2, 2)
        health = 2000
        cost = 150
    }
    
    override func configureModel() {
        self.setModel(named: "ArcaneSanctum", scale: 0.007)
        
        self.position.y = 0
        healthBar = addHealthBar(y: 3.5, health: health, size: .large, showsProgress: true)
        
        let collisionBody = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: collisionBody, options: nil))
        self.physicsBody?.friction = 0
    }
    
    override func createUnit() -> Unit {
        let unit = Sorceress(player: self.owner,
                                position: SCNVector3Zero,
                                target: self.target)
        return unit
    }
    
    override func copy() -> Any {
        return ArcaneSanctum.init(player: self.owner, position: self.position)
    }
}

class GryphonAviary: BuildingSpawner {
    var bodyModel: SCNSphere!
    
    override func configureNode() {
        super.configureModel()
        name = "Aviary"
        attackRadius = 3
        size = int2(2, 2)
        health = 2000
        cost = 200
    }
    
    override func configureModel() {
        self.setModel(named: "GryphonAviary", scale: 0.007)
        
        self.position.y = 0
        
        healthBar = addHealthBar(y: 2.5, health: health, size: .large, showsProgress: true)
        
        let collisionBody = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: collisionBody, options: nil))
        self.physicsBody?.friction = 0
        
    }
    
    override func createUnit() -> Unit {
        let unit = Militia(player: self.owner,
                                position: SCNVector3Zero,
                                target: self.target)
        return unit
    }
    
    override func copy() -> Any {
        return GryphonAviary.init(player: self.owner, position: self.position)
    }
}

class Workshop: BuildingSpawner {
    var bodyModel: SCNSphere!
    
    override func configureNode() {
        name = "Workshop"
        attackRadius = 3
        size = int2(2, 2)
        health = 2000
        cost = 200
    }
    
    override func configureModel() {
        super.configureModel()
        self.setModel(named: "Workshop", scale: 0.007)
        
        self.position.y = 0
        
        healthBar = addHealthBar(y: 2.5, health: health, size: .large, showsProgress: true)
        
        let collisionBody = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: collisionBody, options: nil))
        self.physicsBody?.friction = 0
        
    }
    
    override func createUnit() -> Unit {
        let unit = Rifleman(player: self.owner,
                                position: SCNVector3Zero,
                                target: self.target)
        return unit
    }
    
    override func copy() -> Any {
        return Workshop.init(player: self.owner, position: self.position)
    }
}

class Farm: BuildingSpawner {
    var bodyModel: SCNSphere!
    
    override func configureNode() {
        name = "Farm"
        attackRadius = 3
        size = int2(2, 2)
        health = 2000
        cost = 100
    }
    
    override func configureModel() {
        super.configureModel()
        self.setModel(named: "Farm", scale: 0.007)
        
        self.position.y = 0
        
        healthBar = addHealthBar(y: 2.5, health: health, size: .large, showsProgress: true)
        
        let collisionBody = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: collisionBody, options: nil))
        self.physicsBody?.friction = 0
        
    }
    
    override func createUnit() -> Unit {
        let unit = Militia(player: self.owner,
                                position: SCNVector3Zero,
                                target: self.target)
        return unit
    }
    
    override func copy() -> Any {
        return Farm.init(player: self.owner, position: self.position)
    }
}

class TownHall: Nexus {
    var bodyModel: SCNSphere!
    
    override func configureModel() {
        super.configureModel()
        self.setModel(named: "TownHall", scale: 0.007)
        
        self.position.y = 0
        healthBar = addHealthBar(y: 3.5, health: health, size: .large, showsProgress: false)
        
        let collisionBody = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: collisionBody, options: nil))
        self.physicsBody?.friction = 0
        self.physicsBody?.velocityFactor = SCNVector3(x: 0, y: 0, z: 0)
    }
}

// MARK: Units

class Militia: AutoUnit {
    let radius: CGFloat = 0.4
    let damageLow = 15
    let damageHigh = 25
    
    var bodyModel: SCNSphere!
    var body: SCNNode!
    
    override func configureNode() {
        health = 110
        targetingRange = 8
        attackRange = 1.5
        mineralValue = 2
        attackSpeed = 1
    }
    
    override func configureModel() {
        super.configureModel()
        
        bodyModel = SCNSphere(radius: radius)
        body = SCNNode(geometry: bodyModel)
        
        self.setModel(named: "Militia", scale: 1)
        
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
            self.runAnimationFrom(start: 30.3, to: 31.15, repeats: true)
        case .attacking:
            self.runAnimationFrom(start: 28.8, to: 29.9, repeats: false)
        }
    }
    
    override func attackEnemy(enemy: BaseObject) {
        let damage = Int(arc4random_uniform(UInt32(damageHigh - damageLow))) + damageLow
        enemy.attackedWithDamage(damage: damage)
    }
}

class Footman: AutoUnit {
    let radius: CGFloat = 0.4
    let damageLow = 20
    let damageHigh = 30
    
    var bodyModel: SCNSphere!
    var body: SCNNode!
    
    override func configureNode() {
        health = 190
        targetingRange = 8
        attackRange = 1.5
        mineralValue = 3
        attackSpeed = 2
    }
    
    override func configureModel() {
        super.configureModel()
        
        bodyModel = SCNSphere(radius: radius)
        body = SCNNode(geometry: bodyModel)
        
        self.setModel(named: "Footman", scale: 1)
        
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
            self.runAnimationFrom(start: 18.5, to: 19.28, repeats: true)
        case .attacking:
            self.runAnimationFrom(start: 12.5, to: 14.2, repeats: false)
        }
    }
    
    override func attackEnemy(enemy: BaseObject) {
        let damage = Int(arc4random_uniform(UInt32(damageHigh - damageLow))) + damageLow
        enemy.attackedWithDamage(damage: damage)
    }
}

class Rifleman: AutoUnit {
    let radius: CGFloat = 0.4
    let damageLow = 25
    let damageHigh = 30
    
    var bodyModel: SCNSphere!
    var body: SCNNode!
    
    override func configureNode() {
        health = 100
        targetingRange = 9
        attackRange = 6
        mineralValue = 3
        attackSpeed = 1.8
    }
    
    override func configureModel() {
        super.configureModel()
        
        bodyModel = SCNSphere(radius: radius)
        body = SCNNode(geometry: bodyModel)
        
        self.setModel(named: "Rifleman", scale: 1)
        
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
            self.runAnimationFrom(start: 12.3, to: 15, repeats: true)
        case .attacking:
            self.runAnimationFrom(start: 14, to: 15.3 , repeats: false)
        }
    }
    
    override func attackEnemy(enemy: BaseObject) {
        let damage = Int(arc4random_uniform(UInt32(damageHigh - damageLow))) + damageLow
        enemy.attackedWithDamage(damage: damage)
    }
}

class Sorceress: AutoUnit {
    let radius: CGFloat = 0.4
    let damageLow = 25
    let damageHigh = 35
    
    var bodyModel: SCNSphere!
    var body: SCNNode!
    
    override func configureNode() {
        health = 100
        targetingRange = 9
        attackRange = 5
        mineralValue = 3
        attackSpeed = 2.3
    }
    
    override func configureModel() {
        super.configureModel()
        
        bodyModel = SCNSphere(radius: radius)
        body = SCNNode(geometry: bodyModel)
        
        self.setModel(named: "Sorceress", scale: 1)
        
        self.position.y = 0.3
        
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
            self.runAnimationFrom(start: 1, to: 3, repeats: true)
        case .attacking:
            self.runAnimationFrom(start: 5, to: 6.5, repeats: false)
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


