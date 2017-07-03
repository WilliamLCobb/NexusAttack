//
//  HealthBar.swift
//  NexusAttack
//
//  Created by Will Cobb on 6/23/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import SceneKit

enum HealthBarSize {
    case small
    case medium
    case large
}

class HealthBar: BaseObject {
    var maxHealth: Float
    var health: Float {
        didSet {
            if let bar = self.bar {
               bar.width = (CGFloat(health/maxHealth) * self.width)
            }
        }
    }
    var host: BaseObject
    var size: HealthBarSize
    var width: CGFloat!
    var bar: SCNBox!
    
    init(maxHealth: Float, position: SCNVector3, size: HealthBarSize, host: BaseObject) {
        self.maxHealth = maxHealth
        self.health = maxHealth
        self.size = size
        self.host = host
        super.init()
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureObject() {
        super.configureObject()
        
        //let healthBarBackground = SCNBox.init(width: self.width, height: 0.2, length: 0.01, chamferRadius: 0)
        //healthBarBackground.materials.first?.diffuse.contents = UIColor.red
        //addGeometry(model: healthBarBackground)
        var height: Float
        switch (self.size) {
        case .small:
            width = 0.5
            height = 0.1
        case .medium:
            width = 1
            height = 0.3
        case .large:
            width = 3
            height = 0.6
        }
        bar = SCNBox.init(width: width, height: CGFloat(height), length: 0.01, chamferRadius: 0)
        bar.materials.first?.diffuse.contents = UIColor.green
        let node = addGeometry(model: bar)
        node.eulerAngles.x = -0.1
    }
}
