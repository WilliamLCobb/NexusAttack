 //
//  GameScene.swift
//  NexusAttack
//
//  Created by Will Cobb on 6/16/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//
// SCNBillboardConstraint

import SceneKit
import GameplayKit

var globalGameUtility: GameUtilityDelegate!

class GameScene: SCNScene {
    var startTime: TimeInterval = 0.0
    var incomeTimer: TimeInterval = 0
    
    var cameraNode: SCNNode
    
    var worldNode = SCNNode()
    var buildings = [Building]()
    var base: SCNNode!
    var units = [Unit]()
    var missiles = [Missile]()
    let team1 = Team(id: 1, color: UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1))
    let team2 = Team(id: 2, color: UIColor(red: 142/255, green: 68/255, blue: 173/255, alpha: 1))
    var nexus1: Nexus!
    var nexus2: Nexus!
    
    var player1: Player
    var player2: Player
    
    var graph: GKGridGraph<GKGridGraphNode>!
    
    init(withCamera camera: SCNNode) {
        self.cameraNode = camera
        
        player1 = Player(id: 1,
                         name: "Player A",
                         color: UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1),
                         team: team1)
        player2 = Player(id: 2,
                         name: "Player B",
                         color: UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1),
                         team: team2)
        team1.players = [player1]
        team2.players = [player2]
        super.init()
        globalGameUtility = self
        
        startTime = CACurrentMediaTime()
        
        self.rootNode.addChildNode(worldNode)
        
        loadMap()

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(dt: TimeInterval) {
        incomeTimer += dt
        if (incomeTimer > 15) {
            incomeTimer -= 15
            player1.generateIncome()
            player2.generateIncome()
        }
        
        for building in buildings {
            building.update(dt: dt)
        }
        
        for unit in units {
            if unit.configured {
                unit.update(dt: dt)
            }
        }
        
        for missile in missiles {
            missile.update(dt: dt)
        }
    }
    
    func removeNodes(from start: vector_int2, to end: vector_int2) {
        var nodesToRemove = [GKGraphNode]()
        for x in start.x..<(end.x + 1) {
            for y in start.y..<(end.y + 1) {
                nodesToRemove.append(graph.node(atGridPosition: int2(x, y))!)
            }
        }
        graph.remove(nodesToRemove)
    }
    
    // lane 60 x 8
    // spawnArea 22 x 31
    
    func loadMap() {
        
        graph = GKGridGraph(fromGridStartingAt: int2(-51, -15), width: 102, height: 31, diagonalsAllowed: false)
        removeNodes(from: int2(-30, -15), to: int2(30, -11))
        removeNodes(from: int2(-30, -2), to: int2(30, 2))
        removeNodes(from: int2(-30, 11), to: int2(30, 15))
        
        let baseModel = SCNBox(width: 120, height: 0.1, length: 50, chamferRadius: 0)
        baseModel.materials.first?.diffuse.contents = UIColor.clear
        base = SCNNode(geometry: baseModel)
        base.position.y = -0.1
        worldNode.addChildNode(base)
        
        let floor = Floor()
        worldNode.addChildNode(floor)
        
        nexus1 = Nexus(player: player1, position: SCNVector3(x: -47, y: 0, z:0))
        nexus2 = Nexus(player: player2, position: SCNVector3(x: 47, y: 0, z:0))
        
        worldNode.addChildNode(nexus1)
        team1.add(building: nexus1)
        worldNode.addChildNode(nexus2)
        team2.add(building: nexus2)
        
        let spotLight = SCNLight()
        spotLight.type = SCNLight.LightType.spot
        spotLight.color = UIColor.white
        spotLight.spotInnerAngle = 360.0
        spotLight.spotOuterAngle = 360.0
        spotLight.zFar = 1000.0
        spotLight.castsShadow = true
        
        let spotLightNode = SCNNode()
        spotLightNode.name = "OmniLight"
        spotLightNode.light = spotLight
        spotLightNode.position = SCNVector3(x: -26.0, y: 5, z: -20.0)
        spotLightNode.eulerAngles.x = -2.7
        worldNode.addChildNode(spotLightNode)
        
        let ambientLight = SCNLight()
        ambientLight.type = SCNLight.LightType.ambient
        ambientLight.color = UIColor.white
        
        let ambientLightNode = SCNNode()
        ambientLightNode.name = "AmbientLight"
        ambientLightNode.light = ambientLight
        worldNode.addChildNode(ambientLightNode)
    }
}

protocol GameUtilityDelegate {
    func pathFrom(startPosition: SCNVector3, endPosition: SCNVector3) -> [GKGridGraphNode]?
    func closestEnemyTo(object: BaseOwnedObject) -> BaseOwnedObject?
    func spawn(unit: Unit) -> Bool
    func spawn(building: Building) -> Bool
    func spawn(missile: Missile)
    func unitDidDie(unit: Unit)
    func buildingDidDie(building: Building)
    func missileDidDie(missile: Missile)
}

extension GameScene: GameUtilityDelegate {
    func searchForValidNode(from position: int2) -> GKGridGraphNode? {
        var x: Int32 = position.x
        var y: Int32 = position.y
        var dx: Int32 = 0
        var dy: Int32 = -1
        for _ in 0..<100 {
            if let node = graph.node(atGridPosition: int2(x, y)) {
                return node
            }
            if x == y || (x < 0 && x == -y) || (x > 0 && x == 1-y) {
                let temp = dx
                dx = -dy
                dy = temp
            }
            x += dx
            y += dy
        }
        return nil
    }
    
    func pathFrom(startPosition: SCNVector3, endPosition: SCNVector3) -> [GKGridGraphNode]? {
        let start = int2(Int32(startPosition.x.rounded(.toNearestOrAwayFromZero)), Int32(startPosition.z.rounded(.toNearestOrAwayFromZero)))
        let end = int2(Int32(endPosition.x.rounded(.toNearestOrAwayFromZero)), Int32(endPosition.z.rounded(.toNearestOrAwayFromZero)))
        guard
            let startNode = graph.node(atGridPosition: start),
            let endNode = graph.node(atGridPosition: end)
        else {
            print("Error!, nodes not in grid")
            print(start.x, start.y)
            if let node = searchForValidNode(from: start) {
                return [node]
            } else {
                print("Coudn't save node")
            }
            return nil
        }
        return graph.findPath(from: startNode, to: endNode) as? [GKGridGraphNode]
    }
    
    func enemyTeamFor(team: Team) -> Team {
        if team == self.team1 {
            return team2
        }
        return team1
    }
    
    func closestEnemyTo(object: BaseOwnedObject) -> BaseOwnedObject? {
        let enemyTeam = enemyTeamFor(team: object.team)
        let objectInTopLane = object.presentation.position.z < 0
        var closestEnemy: BaseOwnedObject?
        var closestDistance: Float = Float.infinity
        
        for enemyUnit in enemyTeam.units {
            assert(enemyUnit != object)
            let enemyInTopLane = enemyUnit.presentation.position.z < 0
            if (abs(object.presentation.position.x) < 30 && objectInTopLane != enemyInTopLane) {
                continue
            }
            let distance = object.distanceTo(object: enemyUnit)
            if distance < closestDistance {
                closestDistance = distance
                closestEnemy = enemyUnit
            }
        }
        
        for enemyBuilding in enemyTeam.buildings {
            let enemyInTopLane = enemyBuilding.presentation.position.z < 0
            if (objectInTopLane != enemyInTopLane) {
                continue
            }
            let distance = object.distanceTo(object: enemyBuilding) -  enemyBuilding.attackRadius!
            if distance < closestDistance {
                closestDistance = distance
                closestEnemy = enemyBuilding
            }
        }
        
        return closestEnemy
    }
    
    func spawn(unit: Unit) -> Bool {
        if (graph.node(atGridPosition: unit.position.to_int2()) != nil) {
            self.units.append(unit)
            unit.team.add(unit: unit)
            worldNode.addChildNode(unit)
            return true
        }
        return false
    }
    
    func spawn(building: Building) -> Bool {
        // Check to make sure they can actually place it
        if let nodesToRemove = building.occupiedNodesInGraph(graph: graph, generateNodes: false) {
            building.owner.spendMinerals(building.cost)
            graph.remove(nodesToRemove)
            self.buildings.append(building)
            building.team.add(building: building)
            worldNode.addChildNode(building)
            return true
        } else {
            print("Can't place there")
            return false
        }
    }
    
    func spawn(missile: Missile) {
        self.missiles.append(missile)
        worldNode.addChildNode(missile)
    }
    
    func unitDidDie(unit: Unit) {
        let enemyTeam = self.enemyTeamFor(team: unit.team)
        enemyTeam.players.forEach { (player) in
            // TODO: fix for multiplayer
            player.addMinerals(unit.mineralValue)
        }
        
        if let index = self.units.index(of: unit) {
            self.units.remove(at: index)
        }
        
        if let index = unit.team.units.index(of: unit) {
            unit.team.units.remove(at: index)
        }
    }
    
    func buildingDidDie(building: Building) {
        if let index = self.buildings.index(of: building) {
            self.buildings .remove(at: index)
        }
        
        if let index = building.team.buildings.index(of: building) {
            building.team.buildings.remove(at: index)
        }
        
        graph.add(building.occupiedNodesInGraph(graph: graph, generateNodes: true)!)
    }
    
    func missileDidDie(missile: Missile) {
        if let index = self.missiles.index(of: missile) {
            self.missiles.remove(at: index)
        }
    }
}

extension GameScene: SCNPhysicsContactDelegate {
    
}

