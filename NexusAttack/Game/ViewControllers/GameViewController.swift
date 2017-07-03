//
//  GameViewController.swift
//  NexusAttack
//
//  Created by Will Cobb on 6/16/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import UIKit
import SceneKit
import GameplayKit

class GameViewController: UIViewController, BuildingMenuDelegate {
    var gameScene: GameScene!
    
    var scnView: SCNView!
    var buildingMenu: BuildingMenuView!
    var cameraNode: SCNNode!
    var lastUpdateTime:TimeInterval = 0
    var placingBuilding = false
    var heldBuilding: Building!
    var gameAI: BaseAI!
    var myPlayer: Player!
    var hud: Hud!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCamera()
        
        gameScene = GameScene(withCamera: self.cameraNode)
        gameScene.rootNode.addChildNode(cameraNode)
        myPlayer = gameScene.player1
        
        setupView()
        setupScene()
        setupMenu()
        lastUpdateTime = CACurrentMediaTime()
        gameAI = BaseAI(gameScene: gameScene, player: gameScene.player2)
    }
    
    func setupView() {
        scnView = self.view as! SCNView
        scnView.showsStatistics = true
        scnView.autoenablesDefaultLighting = false
        scnView.delegate = self
        scnView.isPlaying = true
        hud = Hud(size: scnView.bounds.size, player: myPlayer)
        scnView.overlaySKScene = hud
        scnView.overlaySKScene?.isUserInteractionEnabled = false
    }
    
    func setupScene() {
        scnView.scene = gameScene
    }
    
    func createCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 15, z: 15)
        cameraNode.eulerAngles.x = -1
    }
    
    func setupMenu() {
        let buildingItems = [BuildingMenuItem(name: "Attack Spawner",
                                              color: .red,
                                              building: AttackSpawner(player: myPlayer, position: SCNVector3(0, 100, 0), target: gameScene.nexus2)),
                             BuildingMenuItem(name: "Ranged Spawner",
                                              color: .yellow,
                                              building: RangedSpawner(player: myPlayer, position: SCNVector3(0, 100, 0), target: gameScene.nexus2))]
        buildingMenu = BuildingMenuView(frame: CGRect(x: 0, y: 0, width: 130, height: self.view.frame.size.height),
                                        items: buildingItems,
                                        delegate: self)
        self.view.addSubview(buildingMenu)
    }
    
    func selectedBuilding(building: Building) {
        if myPlayer.minerals >= building.cost && !placingBuilding {
            self.placingBuilding = true
            self.heldBuilding = building.copy() as! Building
            print(self.heldBuilding)
            self.gameScene.worldNode.addChildNode(self.heldBuilding)
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

var lastTouch: CGPoint = CGPoint(x: 0, y: 0)

extension GameViewController {
    func handleSingleTouch(touch: CGPoint) {
        if (self.placingBuilding) {
            let hitResults = self.scnView.hitTest(touch, options: nil)
            for result in hitResults {
                if (result.node == self.gameScene.base) {
                    self.heldBuilding.position.x = result.localCoordinates.x.rounded(.toNearestOrAwayFromZero) - 1.0
                    self.heldBuilding.position.y = result.localCoordinates.y + 1
                    self.heldBuilding.position.z = result.localCoordinates.z.rounded(.toNearestOrAwayFromZero) - 1.5
                }
            }
        } else {
            let dx = Float(lastTouch.x - touch.x)
            self.cameraNode.position.x += (dx / 12)
            let dz = Float(lastTouch.y - touch.y)
            self.cameraNode.position.z += (dz / 12)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Single touch
        if (touches.count == 1) {
            let location = touches.first!.location(in: self.view)
            DispatchQueue.main.async {
                lastTouch = location
                self.handleSingleTouch(touch: location)
            }
        } else if (touches.count == 2) {
            print("2 Touches")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Single touch
        if (touches.count == 1) {
            let location = touches.first!.location(in: self.view)
            DispatchQueue.main.async {
                self.handleSingleTouch(touch: location)
                lastTouch = location
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (placingBuilding) {
            if gameScene.spawn(building: heldBuilding) {
                self.placingBuilding = false
                heldBuilding = nil
            } else {
                self.placingBuilding = false
                heldBuilding.removeFromParentNode()
                heldBuilding = nil
            }
        }
    }
}

var tick: TimeInterval = 0

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time:
        TimeInterval) {
        
        let dt = CACurrentMediaTime() - lastUpdateTime
        lastUpdateTime = CACurrentMediaTime()
        
        tick += dt
        
        if (tick > 0.1) {
            DispatchQueue.main.async {
                self.gameScene.update(dt: 0.1)
                self.gameAI.update(dt: 0.1)
                self.hud.update(dt: 0.1)
                tick -= 0.1
            }
        }
    }
}


