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

 enum GameResult: Int {
    case winner
    case loser
 }
 
var globalGameUtility: GameUtilityDelegate!

 protocol GameSceneDelegate {
    func updatedPlayerGold(gold: Int)
    func gameEndedWithResult(result: GameResult)
 }
 
 protocol SpawnDelegate {
    func didSpawn(object: BaseObject)
    func didDie(object: BaseObject)
 }
 
class GameScene: SCNScene {
    var gameDelegate: GameSceneDelegate?
    var spawnDelegate: SpawnDelegate?
    var startTime: TimeInterval = 0.0
    var incomeTimer: TimeInterval = 0
    
    var cameraNode: SCNNode
    
    var worldNode = SCNNode()
    var buildings = [Building]()
    var base: SCNNode!
    var units = [Unit]()
    var missiles = [Missile]()
    let team1 = Team(id: 1, color: UIColor.blue)
    let team2 = Team(id: 2, color: UIColor.red)
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
        gameDelegate?.updatedPlayerGold(gold: player1.gold)
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
    
    // lane 61 x 8
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
        
        nexus1 = TownHall(player: player1, position: SCNVector3(x: -46, y: 0, z:0))
        nexus2 = Nexus(player: player2, position: SCNVector3(x: 46, y: 0, z:0))
        
        worldNode.addChildNode(nexus1)
        team1.add(building: nexus1)
        _=spawn(building: nexus1)
        worldNode.addChildNode(nexus2)
        team2.add(building: nexus2)
        _=spawn(building: nexus2)
        
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
    func searchForValidNode(from position: int2, skip: Int) -> GKGridGraphNode?
    func pathFrom(start: int2, end: int2) -> [GKGridGraphNode]?
    func isValidNodeInGrid(nodePosition: vector_int2) -> Bool
    func closestEnemyTo(object: BaseOwnedObject) -> BaseOwnedObject?
    func spawn(unit: Unit) -> Bool
    func spawn(building: Building) -> Bool
    func spawn(missile: Missile)
    func unitWillDie(unit: Unit)
    func buildingDidDie(building: Building)
    func missileDidDie(missile: Missile)
    func nexusDestroyed(nexus: Nexus)
}

extension GameScene: GameUtilityDelegate {
    func searchForValidNode(from position: int2, skip: Int = 0) -> GKGridGraphNode? {
        var x: Int32 = 0
        var y: Int32 = 0
        var dx: Int32 = 0
        var dy: Int32 = -1
        for i in 0..<100 {
            if i >= skip {
                if let node = graph.node(atGridPosition: int2(x, y) + position) {
                    return node
                }
            }
            if x == y || (x < 0 && x == -y) || (x > 0 && x == 1-y) {
                let temp = dx
                dx = -dy
                dy = temp
            }
            x += dx
            y += dy
        }
        print("Unable to find node!!!")
        return nil
    }
    
    func isValidNodeInGrid(nodePosition: vector_int2) -> Bool {
        return (self.graph.node(atGridPosition: nodePosition) != nil)
    }
    
    func pathFrom(start: int2, end: int2) -> [GKGridGraphNode]? {
        guard
            let startNode = graph.node(atGridPosition: start),
            let endNode = graph.node(atGridPosition: end)
        else {
            print("Error!, nodes not in grid")
            print(start.x, start.y)
            print(end.x, end.y)
            assert(graph.node(atGridPosition: end) != nil)
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
            if (!enemyUnit.alive ||
                (abs(object.presentation.position.x) < 30 && objectInTopLane != enemyInTopLane)) {
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
            spawnDelegate?.didSpawn(object: unit)
            print("Spawned Unit at:", unit.position.to_int2())
            return true
        }
        return false
    }
    
    func spawn(building: Building) -> Bool {
        // Check to make sure they can actually place it
        if let nodesToRemove = building.occupiedNodesInGraph(graph: graph, generateNodes: false) {
            let nodes = nodesToRemove as! [GKGridGraphNode]
            for node in nodes {
                print("Removing1:", node.gridPosition.x, node.gridPosition.y)
            }
            graph.remove(nodesToRemove)
            building.owner.spendMinerals(building.cost)
            self.buildings.append(building)
            building.team.add(building: building)
            worldNode.addChildNode(building)
            spawnDelegate?.didSpawn(object: building)
            return true
        } else {
            print("Can't place there")
            return false
        }
    }
    
    func canSpawn(building: Building) -> Bool {
        if let _ = building.occupiedNodesInGraph(graph: graph, generateNodes: false) {
            return true
        } else {
            return false
        }
    }
    
    func spawn(missile: Missile) {
        self.missiles.append(missile)
        worldNode.addChildNode(missile)
    }
    
    func unitWillDie(unit: Unit) {
        guard unit.alive else { return } // Make sure this is the first call
        
        let enemyTeam = self.enemyTeamFor(team: unit.team)
        enemyTeam.players.forEach { (player) in
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
    
    func nexusDestroyed(nexus: Nexus) {
        print("Game Over")
        let result: GameResult = nexus is TownHall ? .winner : .loser
        gameDelegate?.gameEndedWithResult(result: result)
        self.isPaused = true
    }
}

extension GameScene: SCNPhysicsContactDelegate {
    
}

