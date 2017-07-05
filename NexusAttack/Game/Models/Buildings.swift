//
//  Building.swift
//  NexusAttack
//
//  Created by Will Cobb on 6/16/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import SceneKit
import GameKit


//   ____
//  |    |
//  |X   |
//  ------

class Building: BaseOwnedObject, AttackableObject {
    var size: int2!
    var cost: Int!
    
    var health: Float = 100 {
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
    
    override func attackedWithDamage(damage: Float) {
        health -= damage
        if (health < 0) {
            die()
        }
    }
    
    override func die() {
        super.die()
        self.gameUtility.buildingDidDie(building: self)
    }
    
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
        var x = (size.x/2)
        var y = (size.y/2)
        if (size.x % 2) == 0 {
            x += 1
        }
        if (size.y % 2) == 0 {
            y += 1
        }
        var dx = 0
        var dy = 1
        let numNodes = ((x * 2) + (y * 2) - 4)
        for _ in 0..<numNodes {
            let thisPosition = int2(myPosition.x + x, myPosition.y + y)
            print("TP", thisPosition)
            if (self.gameUtility.isValidNodeInGrid(nodePosition: thisPosition)) {
                print("For", self.presentation.position.x, self.presentation.position.z, "I Found", thisPosition.x, thisPosition.y)
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

class BuildingSpawner: Building {
    // Seconds passed until next unit spawns
    var spawnRate: Double = 20
    var spawnTime: TimeInterval = 15
    var test = false
    
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
        if (spawnTime > spawnRate) { //&& !test) {
            test = true
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
    
    override func configureObject() {
        attackRadius = 3
        let baseModel = SCNPyramid(width: 2, height: 3, length: 2)
        baseModel.materials.first?.diffuse.contents = self.owner.team.color
        let base = addGeometry(model: baseModel)
        self.position.y = 0
        self.size = int2(2, 2)
        
        health = 4000
        cost = 0
        healthBar = addHealthBar(y: 3.5, health: health, size: .large, showsProgress: false)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: base, options: nil))
    }
    
    override func die() {
        print("Game Over!")
        while true {
            
        }
    }
    
}

class DefenseSpawner: BuildingSpawner {
    var bodyModel: SCNBox!
    
    override func configureObject() {
        self.attackRadius = 3
        self.size = int2(2, 2)
        bodyModel = SCNBox(width: CGFloat(2),
                           height: CGFloat(2),
                           length: CGFloat(2),
                           chamferRadius: 0.1)
        let body = self.addGeometry(model: bodyModel)
        bodyModel.materials.first?.diffuse.contents = self.owner.color
        self.position.y = 1
        
        health = 2000
        healthBar = addHealthBar(y: 2.5, health: health, size: .large, showsProgress: true)
        
        let collisionBody = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: collisionBody, options: nil))
        self.physicsBody?.friction = 0
        
        self.cost = 100
    }
    
    override func createUnit() -> Unit {
        let unit = AttackUnit(player: self.owner,
                              position: SCNVector3Zero,
                              target: self.target)
        return unit
    }
    
    override func copy() -> Any {
        return AttackSpawner.init(player: self.owner, position: self.position, target: self.target)
    }
}

class AttackSpawner: BuildingSpawner {
    var bodyModel: SCNSphere!
    
    override func configureObject() {
        self.attackRadius = 3
        self.size = int2(2, 2)
        bodyModel = SCNSphere(radius: 1)
        let body = self.addGeometry(model: bodyModel)
        bodyModel.materials.first?.diffuse.contents = self.owner.color
        self.position.y = 1
        
        health = 2000
        healthBar = addHealthBar(y: 2.5, health: health, size: .large, showsProgress: true)
        
        let collisionBody = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: collisionBody, options: nil))
        self.physicsBody?.friction = 0
        
        self.cost = 100
    }
    
    override func createUnit() -> Unit {
        let unit = AttackUnit(player: self.owner,
                              position: SCNVector3Zero,
                              target: self.target)
        return unit
    }
    
    override func copy() -> Any {
        return AttackSpawner.init(player: self.owner, position: self.position, target: self.target)
    }
}

class RangedSpawner: BuildingSpawner {
    var bodyModel: SCNCone!
    
    override func configureObject() {
        self.attackRadius = 3
        self.size = int2(2, 2)
        bodyModel = SCNCone(topRadius: 0, bottomRadius: 1, height: 2)
        let body = self.addGeometry(model: bodyModel)
        bodyModel.materials.first?.diffuse.contents = self.owner.color
        self.position.y = 1
        
        health = 1800
        healthBar = addHealthBar(y: 2.5, health: health, size: .large, showsProgress: true)
        
        let collisionBody = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: collisionBody, options: nil))
        self.physicsBody?.friction = 0
        
        self.cost = 150
    }
    
    override func createUnit() -> Unit {
        let unit = RangedUnit(player: self.owner,
                              position: SCNVector3Zero,
                              target: self.target)
        return unit
    }
    
    override func copy() -> Any {
        return RangedSpawner(player: self.owner, position: self.position, target: self.target)
    }
}
