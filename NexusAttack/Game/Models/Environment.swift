//
//  Environment.swift
//  NexusAttack
//
//  Created by Will Cobb on 7/1/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import UIKit
import SceneKit

//       22                        22
//     --------                   --------  15.5
//     |      |       60          |      |
//     |      |___________________|      |  10.5
//     |                                 |
//     |                                 |
//     |      |-------------------|      |  2.5
// 31  |      |                   |      |  0
//     |      |-------------------|      | -2.5
//     |                                 |
//     |                                 |
//     |      |___________________|      | -10.5
//     |      |                   |      |
//     --------                   --------  -15.5
//   -52     -30       0        30      52
//

class Floor: BaseObject {
    
    let green = UIColor(red: 1/255, green: 166/255, blue: 17/255, alpha: 1)
    let stone = UIColor(red: 139/255, green: 141/255, blue: 122/255, alpha: 1)
    
    let laneLength = 60
    let laneHeight = 8
    let laneHeightSpace = 5
    
    let baseLength = 22
    let baseHeight = 31
    let baseLeftEdge = -52
    let baseLeftInnerEdge = -30
    let baseRightEdge = 52
    let baseRightnnerEdge = 30
    
    override init() {
        super.init()
    }
    
    override func configureObject() {
        let buildZoneAModel = SCNBox(width: 22, height: 0.1, length: 31, chamferRadius: 0.0)
        buildZoneAModel.materials.first?.diffuse.contents = green
        let buildZoneANode = addGeometry(model: buildZoneAModel)
        buildZoneANode.position = SCNVector3(x: -41, y: 0, z: 0)
        
        let buildZoneBModel = SCNBox(width: 22, height: 0.1, length: 31, chamferRadius: 0.0)
        buildZoneBModel.materials.first?.diffuse.contents = green
        let buildZoneBNode = addGeometry(model: buildZoneBModel)
        buildZoneBNode.position = SCNVector3(x: 41, y: 0, z: 0)
        
        let lane1Model = SCNBox(width: 60, height: 0.1, length: 8, chamferRadius: 0.0)
        lane1Model.materials.first?.diffuse.contents = stone
        let lane1 = addGeometry(model: lane1Model)
        lane1.position = SCNVector3(x: 0, y: 0, z: 6.5)
        
        let lane2Model = SCNBox(width: 60, height: 0.1, length: 8, chamferRadius: 0.0)
        lane2Model.materials.first?.diffuse.contents = stone
        let lane2 = addGeometry(model: lane2Model)
        lane2.position = SCNVector3(x: 0, y: 0, z: -6.5)
        
        self.flattenGeometry()
        
        // Left spawn
        self.createVerticalWall(atPosition: SCNVector2(x: -52, y: 0), height: 31)
        self.createHorizontalWall(atPosition: SCNVector2(x: -41, y: 15.5), width: 22)
        self.createHorizontalWall(atPosition: SCNVector2(x: -41, y: -15.5), width: 22)
        self.createVerticalWall(atPosition: SCNVector2(x: -30, y: 13), height: 5)
        self.createVerticalWall(atPosition: SCNVector2(x: -30, y: 0), height: 5)
        self.createVerticalWall(atPosition: SCNVector2(x: -30, y: -13), height: 5)
        
        // Middle
        self.createHorizontalWall(atPosition: SCNVector2(x: 0, y: 10.5), width: 60)
        self.createHorizontalWall(atPosition: SCNVector2(x: 0, y: 2.5), width: 60)
        self.createHorizontalWall(atPosition: SCNVector2(x: 0, y: -2.5), width: 60)
        self.createHorizontalWall(atPosition: SCNVector2(x: 0, y: -10.5), width: 60)
        
        // Right spawn
        self.createVerticalWall(atPosition: SCNVector2(x: 52, y: 0), height: 31)
        self.createHorizontalWall(atPosition: SCNVector2(x: 41, y: 15.5), width: 22)
        self.createHorizontalWall(atPosition: SCNVector2(x: 41, y: -15.5), width: 22)
        self.createVerticalWall(atPosition: SCNVector2(x: 30, y: 13), height: 5)
        self.createVerticalWall(atPosition: SCNVector2(x: 30, y: 0), height: 5)
        self.createVerticalWall(atPosition: SCNVector2(x: 30, y: -13), height: 5)
    }
    
    func createHorizontalWall(atPosition position:SCNVector2, width: Float) {
        let wallModel = SCNBox(width: CGFloat(width), height: 2, length: 0.1, chamferRadius: 0.0)
        wallModel.materials.first?.diffuse.contents = UIColor(red: 0, green: 0, blue: 1, alpha: 0.3)
        let wall = addGeometry(model: wallModel)
        wall.position = SCNVector3(x: position.x, y: 0.5, z: position.y)
        wall.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: wall, options: nil))
        wall.physicsBody?.friction = 0
    }
    
    func createVerticalWall(atPosition position:SCNVector2, height: Float) {
        let wallModel = SCNBox(width: 0.1, height: 2, length: CGFloat(height), chamferRadius: 0.0)
        wallModel.materials.first?.diffuse.contents = UIColor(red: 0, green: 0, blue: 1, alpha: 0.3)
        let wall = addGeometry(model: wallModel)
        wall.position = SCNVector3(x: position.x, y: 0.5, z: position.y)
        wall.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: wall, options: nil))
        wall.physicsBody?.friction = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
