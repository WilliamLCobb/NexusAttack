//
//  Environment.swift
//  NexusAttack
//
//  Created by Will Cobb on 7/1/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import UIKit
import SceneKit

//       23                          23
//     --------                   --------  15
//     |      |       61          |      |
//     |      |___________________|      |  10
//     |                                 |
//     |                                 |
//     |      |-------------------|      |  2
// 31  |      |                   |      |  0
//     |      |-------------------|      | -2
//     |                                 |
//     |                                 |
//     |      |___________________|      | -10
//     |      |                   |      |
//     --------                   --------  -15
//   -53     -30       0        30      53
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
    
    
    lazy var dirtTiles: [UIImage] = { [weak self] in
        let dirtSet = UIImage(named: "dirt")!
        return self!.tilesFromSet(dirtSet)
        }()
    
    lazy var grassTiles: [UIImage] = { [weak self] in
        let grassSet = UIImage(named: "grass")!
        return self!.tilesFromSet(grassSet)
        }()
    lazy var grassShortTiles: [UIImage] = { [weak self] in
        let grassSet = UIImage(named: "grass_short")!
        return self!.tilesFromSmallSet(grassSet)
        }()
    var cachedTiles = [String: SCNGeometry]()
    
    override init() {
        super.init()
    }
    
    override func configureModel() {
//        let buildZoneAModel = SCNBox(width: 23, height: 0.1, length: 31, chamferRadius: 0.0)
//        buildZoneAModel.materials.first?.diffuse.contents = green
//        let buildZoneANode = addGeometry(model: buildZoneAModel)
//        buildZoneANode.position = SCNVector3(x: -42, y: 0, z: 0)
//        
//        let buildZoneBModel = SCNBox(width: 23, height: 0.1, length: 31, chamferRadius: 0.0)
//        buildZoneBModel.materials.first?.diffuse.contents = green
//        let buildZoneBNode = addGeometry(model: buildZoneBModel)
//        buildZoneBNode.position = SCNVector3(x: 42, y: 0, z: 0)
//        
//        let lane1Model = SCNBox(width: 61, height: 0.1, length: 8, chamferRadius: 0.0)
//        lane1Model.materials.first?.diffuse.contents = stone
//        let lane1 = addGeometry(model: lane1Model)
//        lane1.position = SCNVector3(x: 0, y: 0, z: 6.5)
//        
//        let lane2Model = SCNBox(width: 61, height: 0.1, length: 8, chamferRadius: 0.0)
//        lane2Model.materials.first?.diffuse.contents = stone
//        let lane2 = addGeometry(model: lane2Model)
//        lane2.position = SCNVector3(x: 0, y: 0, z: -6.5)
        
        loadMap()
        
        self.flattenGeometry()
        
        // Left spawn
        self.createVerticalWall(atPosition: SCNVector2(x: -53.5, y: 0), height: 31)
        self.createHorizontalWall(atPosition: SCNVector2(x: -42, y: 15.5), width: 23)
        self.createHorizontalWall(atPosition: SCNVector2(x: -42, y: -15.5), width: 23)
        self.createVerticalWall(atPosition: SCNVector2(x: -30.5, y: 13), height: 5)
        self.createVerticalWall(atPosition: SCNVector2(x: -30.5, y: 0), height: 5)
        self.createVerticalWall(atPosition: SCNVector2(x: -30.5, y: -13), height: 5)
        
        // Middle
        self.createHorizontalWall(atPosition: SCNVector2(x: 0, y: 10.5), width: 61)
        self.createHorizontalWall(atPosition: SCNVector2(x: 0, y: 2.5), width: 61)
        self.createHorizontalWall(atPosition: SCNVector2(x: 0, y: -2.5), width: 61)
        self.createHorizontalWall(atPosition: SCNVector2(x: 0, y: -10.5), width: 61)
        
        // Right spawn
        self.createVerticalWall(atPosition: SCNVector2(x: 53.5, y: 0), height: 31)
        self.createHorizontalWall(atPosition: SCNVector2(x: 42, y: 15.5), width: 23)
        self.createHorizontalWall(atPosition: SCNVector2(x: 42, y: -15.5), width: 23)
        self.createVerticalWall(atPosition: SCNVector2(x: 30.5, y: 13), height: 5)
        self.createVerticalWall(atPosition: SCNVector2(x: 30.5, y: 0), height: 5)
        self.createVerticalWall(atPosition: SCNVector2(x: 30.5, y: -13), height: 5)
    }
    
    func createHorizontalWall(atPosition position:SCNVector2, width: Float) {
        let wallModel = SCNBox(width: CGFloat(width), height: 2, length: 0.1, chamferRadius: 0.0)
        wallModel.materials.first?.diffuse.contents = UIColor(red: 0, green: 0, blue: 1, alpha: 0.0)
        let wall = addGeometry(model: wallModel)
        wall.position = SCNVector3(x: position.x, y: 0, z: position.y)
        wall.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: wall, options: nil))
        wall.physicsBody?.friction = 0
    }
    
    func createVerticalWall(atPosition position:SCNVector2, height: Float) {
        let wallModel = SCNBox(width: 0.1, height: 2, length: CGFloat(height), chamferRadius: 0.0)
        wallModel.materials.first?.diffuse.contents = UIColor(red: 0, green: 0, blue: 1, alpha: 0.0)
        let wall = addGeometry(model: wallModel)
        wall.position = SCNVector3(x: position.x, y: 0, z: position.y)
        wall.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: wall, options: nil))
        wall.physicsBody?.friction = 0
    }
    
    func loadMap() {
        let path = Bundle.main.path(forResource: "tileMap", ofType: "tm")!
        let mapString = (try? String(contentsOfFile: path))!
        let rows = mapString.components(separatedBy: "\n")
        var mapArray: [[Int]] = Array([])
        for y in 0..<rows.count {
            let row = rows[y]
            let values = row.components(separatedBy: " ")
            let intValues: [Int] = values.filter({ $0.characters.count > 0 }).map({ str in
                print("<", str, ">")
                return Int(str)!
            })
            mapArray.append(intValues)
        }
        
        print(mapArray)
        // mapArray[y][x]
        
        for y in 0..<mapArray.count - 2 {
            for x in 0..<mapArray[0].count - 1 {
                // Looks backwards right?
                let bl = mapArray[y][x]
                let br = mapArray[y][x+1]
                let tl = mapArray[y+1][x]
                let tr = mapArray[y+1][x+1]
                
                let tile = tileForCorners(tl, tr, bl, br)
                
                let node = SCNNode(geometry: tile)
                let xPosition: Float = Float((x - mapArray[0].count / 2) * 2)
                let yPosition: Float = Float(y - mapArray.count / 2) * 2 - 0.5
                node.position = SCNVector3(xPosition, 0.1, yPosition)
                self.modelNode.addChildNode(node)
                print(x, y)
            }
        }
    }
    
    func tileForCorners(_ tl: Int, _ tr: Int, _ bl: Int, _ br: Int) -> SCNGeometry  {
        let key = String(format: "%d%d%d%d", tl, tr, bl, br)
        var noCache = false
        if let cachedTile = cachedTiles[key] {
            if (tl == tr && tl == bl && tl == br) && arc4random_uniform(100) > 90 {
               noCache = true // Allow for some variety
            } else {
                print("Cached")
                return cachedTile
            }
            
        }
        
        var tile: UIImage?
        for tileId in 0..<3 {
            var index = 0
            if br == tileId {
                index += 1
            }
            if bl == tileId {
                index += 2
            }
            if tr == tileId {
                index += 4
            }
            if tl == tileId {
                index += 8
            }
            if index > 0 {
                print(index)
                var tileLayer: UIImage!
                switch tileId {
                case 0:
                    if index < 15 {
                        tileLayer = self.dirtTiles[index]
                    } else {
                        if noCache {
                           tileLayer = self.dirtTiles[Int(15 + arc4random_uniform(16))]
                        } else {
                            tileLayer = self.dirtTiles[0]
                        }
                    }
                case 1:
                    tileLayer = self.grassShortTiles[index]
                case 2:
                    if index < 15 {
                        tileLayer = self.grassTiles[index]
                    } else {
                        if noCache {
                            tileLayer = self.grassTiles[Int(15 + arc4random_uniform(16))]
                        } else {
                            tileLayer = self.grassTiles[0]
                        }
                    }
                default:
                    assertionFailure()
                }
                tile = layerImage(tileLayer, onTopOf: tile)
            }
        }
        
        let geometry = SCNBox(width: 2, height: 0.1, length: 2, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = tile!
        geometry.materials = [material]
        if !noCache {
            cachedTiles[key] = geometry
        }
        return geometry
    }
    
    func tilesFromSmallSet(_ aTileSet: UIImage) -> [UIImage] {
        let tileSet = aTileSet.cgImage!
        var tiles = [UIImage]()
        for x in 0..<4 {
            for y in 0..<4 {
                let imageRef = tileSet.cropping(to: CGRect(x: x * 64, y: y * 64, width: 64, height: 64))!
                if x < 4 {
                    tiles.append(UIImage(cgImage: imageRef))
                }
            }
        }
        return tiles
    }
    
    func tilesFromSet(_ aTileSet: UIImage) -> [UIImage] {
        let tileSet = aTileSet.cgImage!
        var full = [UIImage]()
        var tiles = [UIImage]()
        for x in 0..<8 {
            for y in 0..<4 {
                let imageRef = tileSet.cropping(to: CGRect(x: x * 64, y: y * 64, width: 64, height: 64))!
                if x < 4 {
                    tiles.append(UIImage(cgImage: imageRef))
                } else {
                    full.append(UIImage(cgImage: imageRef))
                }
            }
        }
        tiles.append(contentsOf: full)
        return tiles
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
