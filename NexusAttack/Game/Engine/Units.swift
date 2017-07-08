//
//  Unit.swift
//  NexusAttack
//
//  Created by Will Cobb on 6/17/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import SceneKit
import GameplayKit

enum UnitState {
    case walking
    case attacking
}

class Unit: BaseOwnedObject, AttackableObject {
    var health: Float = 100 {
        didSet {
            healthBar?.health = health
        }
    }
    var speed: Float = 3
    var state: UnitState = .attacking
    var mineralValue: Int = 0 // Money for killing
    
    init(player: Player, position: SCNVector3) {
        super.init(player: player)
        self.position = position
    }
    
    init(modelNode: SCNNode, player: Player, position: SCNVector3) {
        super.init(modelNode: modelNode, player: player)
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func runAttackAnimation(completeness: Float) {
        // override
    }
    
    func beginWalkAnimation() {
        // override
    }
    
    override func attackedWithDamage(damage: Float) {
        health -= damage
        if (health < 0) {
            die()
        }
    }
    
    override func die() {
        super.die()
        self.gameUtility.unitDidDie(unit: self)
    }
}

class AutoUnit: Unit {
    var lastPathSearch: TimeInterval = 1
    var lastEnemySearch: TimeInterval = 1
    var lastEnemyPathSearch: TimeInterval = 1
    var target: Building
    var path: [GKGridGraphNode]?
    var pathToEnemy: [GKGridGraphNode]?
    var targetingRange: Float = 5
    var attackRange: Float = 1
    var attackSpeed: TimeInterval = 1
    var lastAttack: TimeInterval = 0
    var closestEnemy: BaseOwnedObject?
    
    
    init(player: Player, position: SCNVector3, target: Building) {
        self.target = target
        super.init(player: player, position: position)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func attackEnemy() -> Bool {
        if (lastEnemySearch > 1) {
            lastEnemySearch = 0
            closestEnemy = self.gameUtility.closestEnemyTo(object: self)
        }
        
        if let enemy = closestEnemy {
            if !enemy.alive {
                closestEnemy = self.gameUtility.closestEnemyTo(object: self)
                return false
            }
            var enemyDistance = self.distanceTo(object: enemy)
            // Building buffer
            if let attackRadius = enemy.attackRadius {
                enemyDistance -= pow(attackRadius, 2)
            }
            if enemyDistance < pow(self.targetingRange, 2) {
                // In targeting range
                if enemyDistance < pow(self.attackRange, 2) {
                    if state != .attacking {
                        state = .attacking
                        //beginAttackAnimation()
                    }

                    self.runAttackAnimation(completeness: Float((CACurrentMediaTime() - lastAttack) / self.attackSpeed))
                    // Attack if ready
                    if (CACurrentMediaTime() - lastAttack > self.attackSpeed) {
                        self.attackEnemy(enemy: enemy)
                        lastAttack = CACurrentMediaTime()
                    }
                    
                    self.lookAt(destPoint: enemy.position)
                    self.stopMovement()
                    return true
                } else {
                    let goal = enemy.targetPositionFromPosition(self.presentation.position)
                    moveTowards(position: SCNVector2(int2: goal))
                    return true
//                    // Update path to enemy
//                    if (lastEnemyPathSearch > 1) {
//                        lastEnemyPathSearch = 0
//                        pathToEnemy = self.gameUtility.pathFrom(start: self.presentation.position.to_int2(),
//                                                                end: enemy.targetPositionFromPosition(self.presentation.position))
//                    }
//                    
//                    if pathToEnemy != nil {
//                        prunePath(path: &pathToEnemy!)
//                    }
//                    
//                    // Targeted but not close enough to attack
//                    if let target = pathToEnemy?.first {
//                        moveTowards(position: SCNVector2(int2_down: target.gridPosition))
//                    }
//                    return true
                }
            }
        }
        return false
    }
    
    func moveTowards(position: SCNVector2) {
        if state != .walking {
            
            state = .walking
            beginWalkAnimation()
        }
        self.transform = self.presentation.transform
        self.lookAt(destPoint: SCNVector3(position.x, self.presentation.position.y, -position.y))
        let currentRotation = (self.modelNode.presentation.rotation.w * self.modelNode.presentation.rotation.y + (Float.pi / 2))
        physicsBody!.velocity.x = cos(currentRotation) * self.speed
        physicsBody!.velocity.z = -sin(currentRotation) * self.speed
    }
    
    func stopMovement() {
        physicsBody?.velocity.x = 0
        physicsBody?.velocity.z = 0
        physicsBody?.clearAllForces()
        self.transform = self.presentation.transform
        physicsBody?.angularVelocity = SCNVector4Zero
    }
    
    func prunePath( path: inout [GKGridGraphNode]) {
        let currentPosition = self.presentation.position.to_int2()
        if let target = path.first {
            let distance = abs(target.gridPosition.x - currentPosition.x) + abs(target.gridPosition.y - currentPosition.y)
            
            if distance < 8 {
                if (path.count > 2) {
                    path.remove(at: 0)
                }
            }
        }
    }
    
    override func update(dt: TimeInterval) {
        super.update(dt: dt)
        lastEnemySearch += dt
        lastEnemyPathSearch += dt
        lastPathSearch += dt
        
        if (attackEnemy()) {
            return
        }
        
        if (lastPathSearch > 1) {
            path = self.gameUtility.pathFrom(start: self.presentation.position.to_int2(),
                                             end: self.target.targetPositionFromPosition(self.presentation.position))
            lastPathSearch = 0
        }
        
        if (path != nil) {
            prunePath(path: &path!)
        }
        
        if let target = path?.first {
            moveTowards(position: SCNVector2(int2: target.gridPosition))
        } else {
            stopMovement()
        }
    }
}

class AttackUnit: AutoUnit {
    let radius: CGFloat = 0.4
    
    var bodyModel: SCNSphere!
    var body: SCNNode!
    var noseModel: SCNCone!
    var nose: SCNNode!
    
    var referenceNode: SCNNode!
    
    override func configureObject() {
        super.configureObject()
        
        bodyModel = SCNSphere(radius: radius)
        body = SCNNode(geometry: bodyModel)
        
        let path = Bundle.main.path(forResource: "Grunt", ofType: "dae")!
        referenceNode = collada2SCNNode(filepath: path)
        referenceNode.eulerAngles.y = Float.pi
        self.modelNode.addChildNode(referenceNode)
        
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
    
    func collada2SCNNode(filepath:String) -> SCNNode {
        assert(FileManager.default.fileExists(atPath: filepath))
        var node = SCNNode()
        let scene = SCNScene(named: "Grunt")
        var nodeArray = scene!.rootNode.childNodes
        
        for childNode in nodeArray {
            
            node.addChildNode(childNode as SCNNode)
            
        }
        node.scale = SCNVector3(0.015, 0.015, 0.015)
        return node
        
    }
    
    override func update(dt: TimeInterval) {
        super.update(dt: dt)
    }
    
    override func runAttackAnimation(completeness: Float) {
    }
    
    override func beginWalkAnimation() {
    }
    
    override func attackEnemy(enemy: BaseObject) {
        let damage = Float(arc4random_uniform(10) + 10)
        enemy.attackedWithDamage(damage: damage)
    }
}

//class DefenseUnit: AutoUnit {
//    
//    var bodyModel: SCNBox!
//    var body: SCNNode!
//    var noseModel: SCNCone!
//    var nose: SCNNode!
//    
//    var referenceNode: SCNReferenceNode!
//    
//    override func configureObject() {
//        super.configureObject()
//        
//        bodyModel = SCNBox(width: 0.6, height: 0.6, length: 0.6, chamferRadius: 0.01)
//        body = SCNNode(geometry: bodyModel)
//        body = self.addGeometry(model: bodyModel)
//        
//        self.position.y = 0.2
//        
//        noseModel.materials.first?.diffuse.contents = UIColor.red
//        bodyModel.materials.first?.diffuse.contents = self.owner.color
//        
//        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: body, options: nil))
//        self.physicsBody?.angularVelocityFactor = SCNVector3(x: 0, y: 0, z: 0)
//        self.physicsBody?.velocityFactor = SCNVector3(x: 1, y: 0, z: 1)
//        self.physicsBody?.rollingFriction = 0
//        self.physicsBody?.friction = 0
//        
//        healthBar = self.addHealthBar(y: 0.6, health: health, size: .medium, showsProgress: false)
//        
//        self.health = 100
//        self.targetingRange = 8
//        self.attackRange = 2
//        self.mineralValue = 2
//    }
//    
//    override func update(dt: TimeInterval) {
//        super.update(dt: dt)
//        print(referenceNode.isLoaded)
//    }
//    
//    override func runAttackAnimation(completeness: Float) {
//        let out = 0.25 - pow(0.5 - pow(completeness, 2), 2)
//        nose.position.z = -Float(radius + noseModel.height/2) - out
//    }
//    
//    override func beginWalkAnimation() {
//        nose.position.z = -(Float(radius + noseModel.height/2))
//    }
//    
//    override func attackEnemy(enemy: BaseObject) {
//        let damage = Float(arc4random_uniform(10) + 10)
//        enemy.attackedWithDamage(damage: damage)
//    }
//}

class RangedUnit: AutoUnit {
    
    var bodyModel: SCNCone!
    var body: SCNNode!
    
    override func configureObject() {
        super.configureObject()
        
        bodyModel = SCNCone(topRadius: 0.0, bottomRadius: 0.3, height: 0.8)
        body = self.addGeometry(model: bodyModel)
        bodyModel.materials.first?.diffuse.contents = self.owner.color
        
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: body, options: nil))
        self.physicsBody?.angularVelocityFactor = SCNVector3(x: 0, y: 0, z: 0)
        self.physicsBody?.velocityFactor = SCNVector3(x: 1, y: 0, z: 1)
        self.physicsBody?.rollingFriction = 0
        self.physicsBody?.friction = 0
        
        self.position.y = 0.4
        
        healthBar = self.addHealthBar(y: 0.6, health: health, size: .medium, showsProgress: false)
        
        self.health = 70
        self.attackRange = 6
        self.targetingRange = 9
        self.mineralValue = 3
    }
    
    override func runAttackAnimation(completeness: Float) {
    }
    
    override func beginWalkAnimation() {
    }
    
    override func attackEnemy(enemy: BaseObject) {
        let missile = Missile(player: self.owner,
                              position: self.presentation.position,
                              target: enemy,
                              damage: Float(arc4random_uniform(15) + 10))
        self.gameUtility.spawn(missile: missile)
    }
}

