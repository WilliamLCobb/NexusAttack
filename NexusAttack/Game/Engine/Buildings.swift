//
//  Building.swift
//  NexusAttack
//
//  Created by Will Cobb on 6/16/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import SceneKit
import GameKit


class Building: BaseOwnedObject, AttackableObject {
    var level: Int = 1
    var size: int2!
    var cost: Int!
    
    var health: Int = 100 {
        didSet {
            healthBar?.health = health
        }
    }
    
    init(player: Player, position: SCNVector3) {
        super.init(player: player)
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attackedWithDamage(damage: Int) {
        health -= damage
        if (health < 0) {
            die()
        }
    }
    
    override func die() {
        super.die()
        self.gameUtility.buildingDidDie(building: self)
    }
    
//    @discardableResult override func setModel(named name: String, scale: Float) -> SCNNode {
//        let childNode = super.setModel(named: name, scale: scale)
//    }
    
    //  ------
    //  |    |
    //  |X   |
    //  ------
    
    //  --------
    //  |      |
    //  |   X  |
    //  |      |
    //  --------
    
    override func targetPositionFromPosition(_ position: SCNVector3) -> int2 {
        let myPosition = self.presentation.position.to_int2()
        //let target = position.to_int2()
        
        // TODO: Set these smartly...
        // Needs to be rethought for 3x3
        var x = size.x/2 + 1
        var y = size.y/2 + 1
//        if (size.x % 2) == 0 {
//            x += 1
//        }
//        if (size.y % 2) == 0 {
//            y += 1
//        }
        var dx = 0
        var dy = 1
        let numNodes = ((x * 2) + (y * 2) - 4)
        for _ in 0..<numNodes {
            let thisPosition = int2(myPosition.x + x, myPosition.y + y)
            if (self.gameUtility.isValidNodeInGrid(nodePosition: thisPosition)) {
                return thisPosition
            }
            if x == y || x == -y {
                let temp = dx
                dx = -dy
                dy = temp
            }
            x += dx
            y += dy
        }
        assertionFailure()
        return myPosition
    }
    
    func occupiedNodesInGraph(graph: GKGridGraph<GKGridGraphNode>, generateNodes: Bool) -> [GKGraphNode]? {
        var nodes = [GKGraphNode]()
        let position = self.position.to_int2()
        for x in position.x..<(position.x + self.size.x) {
            for y in position.y..<(position.y + self.size.y) {
                if generateNodes {
                    nodes.append(GKGridGraphNode(gridPosition: int2(x, y)))
                } else {
                    if let node = graph.node(atGridPosition: int2(x, y)) {
                        nodes.append(node)
                    } else {
                        return nil
                    }
                }
            }
        }
        return nodes
    }
    
}

class Tower: Building {
    var closestEnemy: BaseOwnedObject?
    var attackRate: Double = 5
    var attackTime: TimeInterval = 0
    var lastEnemySearchTime: TimeInterval = 0
    var damage: Int = 0
    
    
    override func update(dt: TimeInterval) {
        super.update(dt: dt)
        lastEnemySearchTime += dt
        if (lastEnemySearchTime > 1) {
            lastEnemySearchTime = 0
            closestEnemy = self.gameUtility.closestEnemyTo(object: self)
        }
        
        if let enemy = closestEnemy {
            attackTime += dt
            if (attackTime > attackRate) {
                let missile = Missile(player: self.owner,
                                      position: self.presentation.position,
                                      target: enemy,
                                      damage: Int(arc4random_uniform(15)) + (damage - 7))
                self.gameUtility.spawn(missile: missile)
                attackTime = 0
            }
        }
    }
}

class BuildingSpawner: Building {
    // Seconds passed until next unit spawns
    var spawnRate: Double = 20
    var spawnTime: TimeInterval = 19
    
    var target: Building
    
    init(player: Player,
         position: SCNVector3,
         target: Building) {
        
        self.target = target
        super.init(player: player, position: position)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(dt: TimeInterval) {
        super.update(dt: dt)
        spawnTime += dt
        if (spawnTime > spawnRate) {
            DispatchQueue.main.async {
                let newUnit = self.createUnit()!
                self.spawnUnit(unit: newUnit)
            }
            spawnTime -= spawnRate
        }
        self.healthBar?.progress = Float(spawnTime/spawnRate)
    }
    
    func spawnUnit(unit: Unit) {
        if let validNode = self.gameUtility.searchForValidNode(from: self.presentation.position.to_int2(), skip: Int(size.x * size.y)) {
            let position = validNode.gridPosition
            unit.position = SCNVector3(Float(position.x), 0, Float(position.y))
            if (!self.gameUtility.spawn(unit: unit)) {
                fatalError()
            }
        } else {
            fatalError()
        }
    }
    
    func createUnit() -> Unit? {
        // override
        return nil
    }
    
    func findSpawnPosition() -> SCNVector3 {
        // TODO: Look at surrounding nodes and pick one to spawn on
        return SCNVector3(self.presentation.position.x,
                          0,
                          self.presentation.position.z + 2.5)
    }
}

class Nexus: Building {
    
    override func configureNode() {
        self.size = int2(3, 3)
        health = 4000
        cost = 0
        attackRadius = 3
    }
    
    override func configureModel() {
        let baseModel = SCNPyramid(width: 3, height: 4, length: 3)
        baseModel.materials.first?.diffuse.contents = self.owner.team.color
        let base = addGeometry(model: baseModel)
        self.position.y = 0
        
        healthBar = addHealthBar(y: 3.5, health: health, size: .large, showsProgress: false)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: base, options: nil))
    }
    
    override func die() {
        self.gameUtility.nexusDestroyed(nexus: self)
    }
    
}

//class AttackSpawner: BuildingSpawner {
//    var bodyModel: SCNSphere!
//    
//    override func configureModel() {
//        self.attackRadius = 3
//        self.size = int2(2, 2)
//        bodyModel = SCNSphere(radius: 1)
//        let body = self.addGeometry(model: bodyModel)
//        bodyModel.materials.first?.diffuse.contents = self.owner.color
//        self.position.y = 1
//        
//        health = 2000
//        healthBar = addHealthBar(y: 2.5, health: health, size: .large, showsProgress: true)
//        
//        let collisionBody = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
//        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: collisionBody, options: nil))
//        self.physicsBody?.friction = 0
//        
//        self.cost = 100
//    }
//    
//    override func createUnit() -> Unit {
//        let unit = AttackUnit(player: self.owner,
//                              position: SCNVector3Zero,
//                              target: self.target)
//        return unit
//    }
//    
//    override func copy() -> Any {
//        return AttackSpawner.init(player: self.owner, position: self.position, target: self.target)
//    }
//}
//
//class RangedSpawner: BuildingSpawner {
//    var bodyModel: SCNCone!
//    
//    override func configureModel() {
//        self.attackRadius = 3
//        self.size = int2(2, 2)
//        bodyModel = SCNCone(topRadius: 0, bottomRadius: 1, height: 2)
//        let body = self.addGeometry(model: bodyModel)
//        bodyModel.materials.first?.diffuse.contents = self.owner.color
//        self.position.y = 1
//        
//        health = 1800
//        healthBar = addHealthBar(y: 2.5, health: health, size: .large, showsProgress: true)
//        
//        let collisionBody = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
//        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: collisionBody, options: nil))
//        self.physicsBody?.friction = 0
//        
//        self.cost = 150
//    }
//    
//    override func createUnit() -> Unit {
//        let unit = RangedUnit(player: self.owner,
//                              position: SCNVector3Zero,
//                              target: self.target)
//        return unit
//    }
//    
//    override func copy() -> Any {
//        return RangedSpawner(player: self.owner, position: self.position, target: self.target)
//    }
//}
