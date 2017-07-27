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
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.init(uptimeNanoseconds: 1000000)) { 
            self.scnView.isPlaying = true
        }
        
    }
    
    func setupView() {
        scnView = self.view as! SCNView
        scnView.showsStatistics = true
        scnView.autoenablesDefaultLighting = false
        scnView.delegate = self
        hud = Hud(size: scnView.bounds.size, player: myPlayer)
        scnView.overlaySKScene = hud
        scnView.overlaySKScene?.isUserInteractionEnabled = false
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        pan.maximumNumberOfTouches = 1
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture))
        scnView.addGestureRecognizer(pan)
        scnView.addGestureRecognizer(pinch)
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
                                              building: HumanBarracks(player: myPlayer,
                                                                      position: SCNVector3(0, 100, 0),
                                                                      target: gameScene.nexus2)),
                             BuildingMenuItem(name: "Ranged Spawner",
                                              color: .yellow,
                                              building: HumanBarracks(player: myPlayer,
                                                                      position: SCNVector3(0, 100, 0),
                                                                      target: gameScene.nexus2))]
        buildingMenu = BuildingMenuView(frame: CGRect(x: 0, y: 0, width: 145, height: self.view.frame.size.height),
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
    
    var initialTouch: CGPoint!
    func panGesture(sender: UIPanGestureRecognizer) {
        let touch = sender.location(in: self.view)
        
        switch sender.state {
        case .began:
            initialTouch = touch
        case .changed:
            if (self.placingBuilding) {
                let hitResults = self.scnView.hitTest(touch, options: nil)
                for result in hitResults {
                    if (result.node == self.gameScene.base) {
                        self.heldBuilding.position.x = result.localCoordinates.x.rounded(.toNearestOrAwayFromZero) - 1.0
                        self.heldBuilding.position.z = result.localCoordinates.z.rounded(.toNearestOrAwayFromZero) - 1.0
                    }
                }
            } else {
                let dx = Float(initialTouch.x - touch.x)
                self.cameraNode.position.x += (dx / 12)
                let dz = Float(initialTouch.y - touch.y)
                self.cameraNode.position.z += (dz / 12)
            }
        case .failed, .ended:
            if (placingBuilding) {
                if !gameScene.spawn(building: heldBuilding) {
                    heldBuilding.removeFromParentNode()
                }
                self.placingBuilding = false
                heldBuilding = nil
            }
        default: break
        }
        initialTouch = touch
    }
    
    var initialY: Float = 0
    func pinchGesture(sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .began:
            initialY = self.cameraNode.position.y
        case .changed:
            cameraNode.eulerAngles.x = -1 + (15 - self.cameraNode.position.y)/20
            self.cameraNode.position.y = initialY - (Float(sender.scale) - 1) * sin(cameraNode.eulerAngles.x) * 13
            self.cameraNode.position.y = initialY - (Float(sender.scale) - 1) * cos(cameraNode.eulerAngles.x) * 13
        default: break
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


