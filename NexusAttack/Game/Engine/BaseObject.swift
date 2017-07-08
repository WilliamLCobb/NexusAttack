//
//  Object.swift
//  NexusAttack
//
//  Created by Will Cobb on 6/17/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//
// Qaternion math https://github.com/dotnet/corefx/blob/cd5ff1722aa15865b30ebd3b23d5364a9f6440e0/src/System.Numerics.Vectors/src/System/Numerics/Quaternion.cs

import Foundation
import SceneKit
import GameKit

// Possibly animated or collision enabled object class trees
class BaseObject: SCNNode {
    var configured = false
    var gameUtility: GameUtilityDelegate
    var modelNode: SCNNode
    var attackRadius: Float?
    var healthBar: HealthBar?
    var alive = true
    
    override var physicsBody: SCNPhysicsBody? {
        didSet {
            physicsBody?.isAffectedByGravity = false
        }
    }
    
    override init() {
        self.gameUtility = globalGameUtility
        self.modelNode = SCNNode()
        self.modelNode.position = SCNVector3(x:0, y:0, z:0)
        super.init()
        self.addChildNode(self.modelNode)
        DispatchQueue.main.async {
            self.configureObject()
            self.configured = true
        }
    }
    
    init(modelNode: SCNNode) {
        self.gameUtility = globalGameUtility
        self.modelNode = modelNode
        self.modelNode.position = SCNVector3(x:0, y:0, z:0)
        super.init()
        self.addChildNode(self.modelNode)
        DispatchQueue.main.async {
            self.configureObject()
            self.configured = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureObject() {
        // override
    }
    
    func update(dt: TimeInterval) {
        // override
    }
    
    func attackEnemy(enemy: BaseObject) {
        // override
        fatalError()
    }
    
    func attackedWithDamage(damage: Float) {
        // override
        fatalError()
    }
    
    @discardableResult func addGeometry(model: SCNGeometry) -> SCNNode {
        let childNode = SCNNode(geometry: model)
        self.modelNode.addChildNode(childNode)
        return childNode
    }
    
    // Flattens sprite node into a single node helping performance
    func flattenGeometry() {
        self.modelNode = self.modelNode.flattenedClone()
        self.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        addChildNode(modelNode)
    }
    
    func distanceTo(object: BaseObject) -> Float {
        return self.presentation.position.simpleDistanceTo(vector: object.presentation.position)
    }
    
    func die() {
        alive = false
        if self.parent != nil {
            self.removeFromParentNode()
        }
    }
    
    @discardableResult func addHealthBar(y: Float, health: Float, size: HealthBarSize, showsProgress: Bool) -> HealthBar {
        self.healthBar = HealthBar(maxHealth: health, position: SCNVector3(x: 0, y: y, z: 0), size: size, showsProgress: showsProgress)
        self.addChildNode(healthBar!)
        return healthBar!
    }
    
    func targetPositionFromPosition(_ position: SCNVector3) -> int2 {
        return self.presentation.position.to_int2()
    }
    
    //https://stackoverflow.com/questions/12435671/quaternion-lookat-function
    func lookAt(destPoint: SCNVector3) {
        let sourcePoint = self.presentation.position
        let forwardVector = (destPoint - sourcePoint).normalized()
        let VectorForward = SCNVector3(0, 0, -1)
        let VectorUp = SCNVector3(0, 1, 0)

        let dot = SCNVector3DotProduct(left: VectorForward, right:forwardVector)
        if (abs(dot - (-1.0)) < 0.000001) {
            self.modelNode.rotation = SCNVector4(VectorUp.x, VectorUp.y, VectorUp.z, Float.pi);
            return
        }
        if (abs(dot - (1.0)) < 0.000001)
        {
            self.modelNode.rotation = SCNVector4Zero;
            return
        }
        
        let rotAngle = acos(dot)
        var rotAxis = SCNVector3CrossProduct(left: VectorForward, right: forwardVector)
        rotAxis = rotAxis.normalized()
        let newRotation = CreateFromAxisAngle(axis: rotAxis, angle: rotAngle)
        self.modelNode.rotation = newRotation
    }
    
    // https://github.com/dotnet/corefx/issues/71
    func CreateFromAxisAngle(axis: SCNVector3, angle: Float) -> SCNVector4 {
//        let halfAngle = angle * 0.5
//        let s = sin(halfAngle)
//        var q = SCNVector4Zero
//        q.x = axis.x * s;
//        q.y = axis.y * s;
//        q.z = axis.z * s;
//        q.w = cos(halfAngle);
//        return q;
        return SCNVector4(0, axis.y, 0, angle)
    }
}

class BaseOwnedObject: BaseObject {
    var owner: Player
    var team: Team { return owner.team }
    
    init(player: Player) {
        self.owner = player
        super.init()
    }
    
    init(modelNode: SCNNode, player: Player) {
        self.owner = player
        super.init(modelNode: modelNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


protocol AttackableObject {
    func attackedWithDamage(damage: Float)
    func die()
}

