//
//  Unit.swift
//  NexusAttack
//
//  Created by Will Cobb on 6/17/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import SceneKit
import GameplayKit


class Missile: BaseOwnedObject {
    var speed: Float = 8
    var body: SCNNode!
    weak var target: BaseObject?
    var damage: Float
    private var flightDistance: Float

    
    init(player: Player, position: SCNVector3, target: BaseObject, damage: Float) {
        self.target = target
        flightDistance = position.simpleDistanceTo(vector: target.presentation.position)
        self.damage = damage
        super.init(player: player)
        DispatchQueue.main.async {
            self.position = position
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureObject() {
        self.constraints = [SCNLookAtConstraint.init(target: target)]
        let bodyModel = SCNCone(topRadius: 0.05, bottomRadius: 0.1, height: 0.3)
        bodyModel.materials.first?.diffuse.contents = self.owner.color
        body = self.addGeometry(model: bodyModel)
        body.eulerAngles = SCNVector3(x:-Float.pi/2 , y: 0, z: 0)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        self.physicsBody?.velocityFactor.y = 0
        self.physicsBody?.collisionBitMask = 0
    }
    
    override func update(dt: TimeInterval) {
        guard let target = target else {
            die()
            return
        }
        
        var currentDistance = self.presentation.position.simpleDistanceTo(vector: target.presentation.position)
        if let attackRadius = target.attackRadius {
            currentDistance -= pow(attackRadius, 2)
        }
        if (currentDistance < 0.7) {
            target.attackedWithDamage(damage: self.damage)
            die()
        } else {
            let progress = flightDistance - currentDistance
            let currentRotation = (self.presentation.rotation.w * self.presentation.rotation.y + (Float.pi / 2))
            physicsBody?.velocity.x = cos(currentRotation) * self.speed
            physicsBody?.velocity.z = -sin(currentRotation) * self.speed
        }
    }
    
    override func die() {
        DispatchQueue.main.async {
            self.gameUtility.missileDidDie(missile: self)
            super.die()
        }
    }
}

