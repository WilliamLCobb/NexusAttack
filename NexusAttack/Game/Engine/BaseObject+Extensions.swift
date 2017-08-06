//
//  BaseObject+Extensions.swift
//  NexusAttack
//
//  Created by Will Cobb on 8/5/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import UIKit
import SceneKit

var loadedModels = [String: SCNNode]()

extension BaseObject {
    func loadModel(named name:String) -> SCNNode {
        if let node = loadedModels[name] {
            let clonedNode = node.clone()
            if clonedNode is Unit {
                clonedNode.forEachChild(runAction: { node in
                    node.geometry = node.geometry?.copy() as? SCNGeometry
                })
            }
        }
        let node = SCNNode()
        let scene = SCNScene(named: name)!
        scene.isPaused = false
        let nodeArray = scene.rootNode.childNodes
        
        for childNode in nodeArray {
            node.addChildNode(childNode as SCNNode)
        }
        
        loadedModels[name] = node
        return node.clone()
    }
    
    func layerImage(_ topImage: UIImage, onTopOf bottomImage: UIImage?) -> UIImage {
        guard let bottomImage = bottomImage else {
            return topImage
        }
        let imageRect = CGRect(x: 0, y: 0, width: 64, height: 64)
        UIGraphicsBeginImageContext(imageRect.size)
        bottomImage.draw(in: imageRect)
        topImage.draw(in: imageRect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension UIImage {
    static func from(color: UIColor, withSize size: CGSize) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
