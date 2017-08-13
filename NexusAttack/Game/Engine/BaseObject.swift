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


protocol AttackableObject {
    func attackedWithDamage(damage: Int)
    func die()
}

enum AnimationType {
    case idle
    case running
    case attacking
}

protocol AnimatableObject {
    func beginAnimation(animation: AnimationType)
}


class BaseObject: SCNNode {
    var configured = false
    var gameUtility: GameUtilityDelegate
    var modelNode: SCNNode
    var attackRadius: Float?
    var healthBar: HealthBar?
    var alive = true
    private var lockTime: TimeInterval = 0
    var locked: Bool { return lockTime > CACurrentMediaTime() }
    var materials: [SCNMaterial]?
    
    override var physicsBody: SCNPhysicsBody? {
        didSet {
            physicsBody?.isAffectedByGravity = false
            physicsBody?.mass = 1000
        }
    }
    
    override init() {
        self.gameUtility = globalGameUtility
        self.modelNode = SCNNode()
        self.modelNode.position = SCNVector3(x:0, y:0, z:0)
        super.init()
        self.addChildNode(self.modelNode)
        self.configureNode()
        DispatchQueue.main.async {
            self.configureModel()
            self.configured = true
        }
    }
    
    init(modelNode: SCNNode) {
        self.gameUtility = globalGameUtility
        self.modelNode = modelNode
        self.modelNode.position = SCNVector3(x:0, y:0, z:0)
        super.init()
        self.addChildNode(self.modelNode)
        self.configureNode()
        DispatchQueue.main.async {
            self.configureModel()
            self.configured = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Run immediately after initialization
    func configureNode() {
        // override
    }
    
    // Run once on main thread after initialization
    func configureModel() {
        // override
    }
    
    func update(dt: TimeInterval) {
        assert(self.configured)
        // override
    }
    
    func attackEnemy(enemy: BaseObject) {
        // override
        fatalError()
    }
    
    // Attackable Object
    func attackedWithDamage(damage: Int) {
        // override
        fatalError()
    }
    
    // Animatable Object
    func beginAnimation(animation: AnimationType) {
        // override
        fatalError()
    }
    
    func networkObjects() -> [Any] {
        let objects: [Any] = [self.position]
        return objects
    }
    
    // Creates a time lock useful for locking animations or actions
    func lock(forTime time: TimeInterval) {
        self.lockTime = CACurrentMediaTime() + time
    }
    
    func setEmissionColor(_ color: UIColor) {
        guard let materials = self.materials else { return }
        for material in materials {
            material.emission.contents = color
        }
    }
    
    func setTeamColor(_ color: UIColor) {
        guard let materials = self.materials else { return }
        for material in materials {
            if let image = material.diffuse.contents as? UIImage {
                let teamImage = UIImage.from(color: color, withSize: image.size)
                material.diffuse.contents = layerImage(image, onTopOf: teamImage)
            }
        }
    }
    
    @discardableResult func addGeometry(model: SCNGeometry) -> SCNNode {
        let childNode = SCNNode(geometry: model)
        self.modelNode.addChildNode(childNode)
        return childNode
    }
    
    @discardableResult func setModel(named name: String, scale: Float) -> SCNNode {
        let childNode = loadModel(named: name)
        childNode.scale = SCNVector3(scale, scale, scale)
        self.modelNode.addChildNode(childNode)
        self.materials = getModelMaterials()
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
        self.modelNode = SCNNode()
        if self.parent != nil {
            self.removeFromParentNode()
        }
    }
    
    @discardableResult func addHealthBar(y: Float, health: Int, size: HealthBarSize, showsProgress: Bool) -> HealthBar {
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
    
    private func runAnimationFrom(onNode node: SCNNode, start startTime: TimeInterval, to stopTime: TimeInterval, repeats: Bool) {
        for key in node.animationKeys {
            let animation = node.animation(forKey: key)!
            animation.timeOffset = startTime
            animation.duration = stopTime - startTime
            if (repeats) {
                animation.repeatCount = 1000
            } else {
                animation.repeatCount = 0
            }
            
            if (animation .isKind(of: CAAnimationGroup.self)) {
                let group = animation as! CAAnimationGroup
                for subAnimation in group.animations! {
                    subAnimation.timeOffset = startTime
                }
            }

            node.addAnimation(animation, forKey: key)
        }
        
        for childNode in node.childNodes {
            runAnimationFrom(onNode: childNode, start: startTime, to: stopTime, repeats: repeats)
        }
    }
    
    //TODO: Extend with var get
    private func getModelMaterials() -> [SCNMaterial]? {
        guard let children = modelNode.childNodes.first?.childNodes else {
            print("Node does not have a material")
            assertionFailure()
            return nil
        }
        
        var materials = Set<SCNMaterial>()
        for child in children {
            if let childGeometry = child.geometry {
                for material in childGeometry.materials {
                    materials.insert(material)
                }
            }
        }
        return Array<SCNMaterial>(materials)
    }
    
    func runAnimationFrom(start startTime: TimeInterval, to stopTime: TimeInterval, repeats: Bool) {
        runAnimationFrom(onNode: self, start: startTime, to: stopTime, repeats: true)
    }
    
    func animationFromSceneNamed(path: String) -> CAAnimation? {
        let scene  = SCNScene(named: path)
        var animation:CAAnimation?
        scene?.rootNode.enumerateChildNodes({ child, stop in
            for animKey in child.animationKeys {
                animation = child.animation(forKey: animKey)
                child.isPaused = false
                //print(child)
                //print(child.animationKeys)
                if animation != nil {
                    scene!.rootNode.addAnimation(animation!, forKey: animKey)
                }
                //child.resumeAnimation(forKey: animKey)
                //stop.pointee = false
            }
        })
        return animation
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
    
    override func setModel(named name: String, scale: Float) -> SCNNode {
        let node = super.setModel(named: name, scale: scale)
        setTeamColor(owner.team.color)
        return node
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

