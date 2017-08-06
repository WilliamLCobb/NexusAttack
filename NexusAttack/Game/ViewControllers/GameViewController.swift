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

class GameViewController: UIViewController, GameSceneDelegate, MenuDelegate {
    var gameScene: GameScene!
    
    @IBOutlet weak var goldLabel: UILabel!
    @IBOutlet weak var poplationLabel: UILabel!
    
    var scnView: SCNView!
    var buildMenu: BuildMenuView!
    var cameraNode: SCNNode!
    var lastUpdateTime:TimeInterval = 0
    var placingBuilding = false
    var heldBuilding: Building!
    var gameAI: BaseAI!
    var myPlayer: Player!
    var hud: Hud!
    var cameraVelocity: CGPoint?
    
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
        
        DispatchQueue.main.async {
            print("Starting")
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        pan.maximumNumberOfTouches = 1
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture))
        scnView.addGestureRecognizer(pan)
        scnView.addGestureRecognizer(pinch)
    }
    
    func setupScene() {
        scnView.scene = gameScene
        scnView.delegate = self
        gameScene.gameDelegate = self
    }
    
    func createCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 15, z: 15)
        cameraNode.eulerAngles.x = -1
    }
    
    func setupMenu() {
        let buildingItems = [BuildMenuItem(name: "Militia",
                                           icon: #imageLiteral(resourceName: "human_farm"),
                                           building: Farm(player: myPlayer,
                                                                      position: SCNVector3(0, 100, 0),
                                                                      target: gameScene.nexus2)),
                             BuildMenuItem(name: "Rifleman",
                                           icon: #imageLiteral(resourceName: "human_workshop"),
                                           building: Workshop(player: myPlayer,
                                                              position: SCNVector3(0, 100, 0),
                                                              target: gameScene.nexus2)),
                             BuildMenuItem(name: "Footman",
                                           icon: #imageLiteral(resourceName: "human_barracks"),
                                           building: HumanBarracks(player: myPlayer,
                                                              position: SCNVector3(0, 100, 0),
                                                              target: gameScene.nexus2)),
                             BuildMenuItem(name: "Sorceress",
                                           icon: #imageLiteral(resourceName: "human_arcane_sanctum"),
                                           building: ArcaneSanctum(player: myPlayer,
                                                              position: SCNVector3(0, 100, 0),
                                                              target: gameScene.nexus2))]
        buildMenu = BuildMenuView(frame: CGRect(x: 8, y: view.frame.size.height - 145, width: 140, height: 140),
                                        items: buildingItems,
                                        delegate: self)
        self.view.addSubview(buildMenu)
    }
    
    func selectedBuilding(building: Building) {
        heldBuilding = building.copy() as! Building
        if myPlayer.gold >= building.cost && !placingBuilding {
            heldBuilding.setEmissionColor(UIColor.gray)
        } else {
            heldBuilding?.setEmissionColor(UIColor.red)
        }
        self.placingBuilding = true
        
        print(self.heldBuilding)
        self.gameScene.worldNode.addChildNode(self.heldBuilding)
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
    
    func tapGesture(sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            let touch = sender.location(in: self.view)
            let hitResults = self.scnView.hitTest(touch, options: nil)
            for result in hitResults {
                print("Tapped", result)
            }
        default:
            print("Ignoring Tap")
        }
    }
    
    func panGesture(sender: UIPanGestureRecognizer) {
        let touch = sender.location(in: self.view)
        switch sender.state {
        case .began:
            initialTouch = touch
        case .changed:
            if (self.placingBuilding) {
                let hitResults = scnView.hitTest(touch, options: nil)
                for result in hitResults {
                    if (result.node == self.gameScene.base) {
                        heldBuilding.position.x = result.localCoordinates.x.rounded(.toNearestOrAwayFromZero) - 1.0
                        heldBuilding.position.z = result.localCoordinates.z.rounded(.toNearestOrAwayFromZero) - 1.0
                        if gameScene.canSpawn(building: heldBuilding) && myPlayer.gold >= heldBuilding.cost {
                            heldBuilding.setEmissionColor(.black)
                        } else {
                            heldBuilding.setEmissionColor(.red)
                        }
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
                if myPlayer.gold < heldBuilding.cost || !gameScene.spawn(building: heldBuilding) {
                    heldBuilding.removeFromParentNode()
                }
                self.placingBuilding = false
                heldBuilding = nil
            } else {
                cameraVelocity = sender.velocity(in: self.view)
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
            print(cameraNode.position.y)
            let t = 0.5 + (cameraNode.position.y / 10)
            self.cameraNode.position.y = initialY - (Float(sender.scale) - 1) * sin(cameraNode.eulerAngles.x) * 13 * t
            self.cameraNode.position.y = initialY - (Float(sender.scale) - 1) * cos(cameraNode.eulerAngles.x) * 13 * t
            cameraNode.eulerAngles.x = -1 + (15 - self.cameraNode.position.y)/20
            if cameraNode.position.y < 12 {
                cameraNode.position.y = 12.05
            }
        default: break
        }
    }
    
    func updatedPlayerGold(gold: Int) {
        goldLabel.text = String(format: "%d", gold)
    }
    
    func gameEndedWithResult(result: GameResult) {
        
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
        
        if let velocity = cameraVelocity {
            if abs(velocity.x) > 5 || abs(velocity.y) > 5 {
                let dx = Double(velocity.x)
                self.cameraNode.position.x -= Float(dx / (50 / dt))
                let dz = Double(velocity.y)
                self.cameraNode.position.z -= Float(dz / (50 / dt))
                print(dx, dz)
                cameraVelocity = CGPoint(x: velocity.x * CGFloat(1 - (dt/0.4)),
                                         y: velocity.y * CGFloat(1 - (dt/0.4)))
            } else {
                cameraVelocity = nil
            }
        }
    }
}


