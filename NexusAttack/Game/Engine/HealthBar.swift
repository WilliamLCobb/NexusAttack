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
    let bgColor = UIColor(red: 22/255, green: 26/255, blue: 30/255, alpha: 1)
    let damageLabel = SCNText(string: nil, extrusionDepth: 1)
    var maxHealth: Int
    var oldY: Float = 0
    var health: Int {
        didSet {
            if let bar = self.bar {
                bar.width = ((CGFloat(health)/CGFloat(maxHealth)) * self.width)
                barNode.position.x = Float((bar.width/2) - (width/2))
                if health == maxHealth && !showsProgress{
                    oldY = self.position.y
                    self.position.y = 1000
                    //forEachChild(runAction: { $0.isHidden = true })
                } else {
                    //forEachChild(runAction: { $0.isHidden = false })
                    self.position.y = oldY
                }
            }
        }
    }
    var progress: Float = 0 {
        didSet {
            if let progressBar = self.progressBar {
                progressBar.width = CGFloat(progress) * self.width
                progressBarNode!.position.x = Float((progressBar.width/2) - (width/2))
            }
        }
    }
    
    var size: HealthBarSize
    var showsProgress: Bool
    var width: CGFloat!
    var height: CGFloat!
    var bar: SCNBox!
    var barNode: SCNNode!
    var progressBar: SCNBox?
    var progressBarNode: SCNNode?
    
    init(maxHealth: Int, position: SCNVector3, size: HealthBarSize, showsProgress: Bool) {
        self.maxHealth = maxHealth
        self.health = maxHealth
        self.size = size
        self.showsProgress = showsProgress
        super.init()
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureModel() {
        super.configureModel()
        
        switch (self.size) {
        case .small:
            width = 0.5
            height = 0.1
        case .medium:
            width = 1
            height = 0.2
        case .large:
            width = 3
            height = 0.2
        }
        
        let healthBarBackground = SCNBox.init(width: width + 0.02, height: height + 0.02, length: 0.01, chamferRadius: 0)
        healthBarBackground.materials.first?.diffuse.contents = bgColor
        let bgNode = addGeometry(model: healthBarBackground)
        bgNode.position = SCNVector3(-0.01, Float(height) * 2 + 0.1 - 0.01, -0.01)
        
        bar = SCNBox.init(width: width, height: height, length: 0.01, chamferRadius: 0)
        bar.materials.first?.diffuse.contents = UIColor.green
        barNode = addGeometry(model: bar)
        barNode.position.y = Float(height) * 2 + 0.1
        
        if (showsProgress) {
            let progressBarBackground = SCNBox.init(width: width + 0.02, height: height + 0.02, length: 0.01, chamferRadius: 0)
            progressBarBackground.materials.first?.diffuse.contents = bgColor
            let progressBgNode = addGeometry(model: progressBarBackground)
            progressBgNode.position.z = -0.01
            progressBgNode.position = SCNVector3(-0.01, 0.01, -0.01)
            
            progressBar = SCNBox.init(width: 0, height: height, length: 0.01, chamferRadius: 0)
            progressBar!.materials.first?.diffuse.contents = UIColor.init(red: 0, green: 177/255, blue: 1, alpha: 1)
            progressBarNode = addGeometry(model: progressBar!)
            progressBarNode!.position.y = 0
        } else {
            self.position.y = 1000
        }
        
        self.eulerAngles.x = -0.3
    }
}
