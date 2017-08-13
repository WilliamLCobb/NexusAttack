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

enum TouchType {
    case tap
    case pan
}

class GameViewController: UIViewController, GameSceneDelegate, MenuDelegate {
    var gameScene: GameScene!
    
    @IBOutlet weak var goldLabel: UILabel!
    @IBOutlet weak var poplationLabel: UILabel!
    
    @IBOutlet weak var gameChoiceView: UIView!
    @IBOutlet weak var hostOrJoinView: UIView!
    @IBOutlet weak var hostView: UIView!
    @IBOutlet weak var hostIPLabel: UILabel!
    @IBOutlet weak var connectView: UIView!
    @IBOutlet weak var connectIPEntry: UITextField!
    
    var scnView: SCNView!
    var buildMenu: BuildMenuView!
    var cameraNode: SCNNode!
    var lastUpdateTime:TimeInterval = 0
    var placingBuilding = false
    var heldBuilding: Building!
    var gameAI: BaseAI?
    var networkPlayer: NetworkPlayer?
    var myPlayer: Player!
    var hud: Hud!
    var cameraVelocity: CGPoint?
    var touchType: TouchType = .tap
    var toolTip: ToolTipView?
    var selectedBuilding: Building?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createCamera()
        
        gameScene = GameScene(withCamera: self.cameraNode)
        gameScene.rootNode.addChildNode(cameraNode)
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
        scnView.addGestureRecognizer(tap)
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
                                                          position: SCNVector3(-200, 100, 0))),
                             BuildMenuItem(name: "Rifleman",
                                           icon: #imageLiteral(resourceName: "human_workshop"),
                                           building: Workshop(player: myPlayer,
                                                              position: SCNVector3(-200, 100, 0))),
                             BuildMenuItem(name: "Footman",
                                           icon: #imageLiteral(resourceName: "human_barracks"),
                                           building: HumanBarracks(player: myPlayer,
                                                              position: SCNVector3(-200, 100, 0))),
                             BuildMenuItem(name: "Sorceress",
                                           icon: #imageLiteral(resourceName: "human_arcane_sanctum"),
                                           building: ArcaneSanctum(player: myPlayer,
                                                              position: SCNVector3(-200, 100, 0)))]
        buildMenu = BuildMenuView(frame: CGRect(x: 8, y: view.frame.size.height - 145, width: 140, height: 140),
                                        items: buildingItems,
                                        delegate: self)
        self.view.addSubview(buildMenu)
    }
    
    func selectedBuilding(building: Building) {
        selectedBuilding = building
    }
    
    func holdBuilding(_ building: Building) {
        heldBuilding = building.copy() as! Building
        heldBuilding.showPlacingFloor()
        building.position.y = 100
        if myPlayer.gold >= building.cost && !placingBuilding {
            heldBuilding.setEmissionColor(UIColor.gray)
        } else {
            heldBuilding?.setEmissionColor(UIColor.red)
        }
        
        self.gameScene.worldNode.addChildNode(self.heldBuilding)
        DispatchQueue.main.async {
            self.placingBuilding = true
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
    
    func tapGesture(sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            let touch = sender.location(in: self.view)
//            let hitResults = self.scnView.hitTest(touch, options: nil)
//            for result in hitResults {
//                print("Tapped", result)
//            }
            print("TAP!")
            if let building = selectedBuilding as? BuildingSpawner {
                toolTip?.removeFromSuperview()
                toolTip = ToolTipView(frame: CGRect(x: 8, y: 80, width: 100, height: 62),
                                      building: building)
                self.view.addSubview(toolTip!)
                selectedBuilding = nil
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
             print("PAN!")
            if let building = self.selectedBuilding {
                holdBuilding(building)
                selectedBuilding = nil
            }
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
                guard heldBuilding != nil else { return }
                if myPlayer.gold < heldBuilding.cost || !gameScene.spawn(building: heldBuilding) {
                    heldBuilding.removeFromParentNode()
                }
                self.placingBuilding = false
                heldBuilding.hidePlacingFloor()
                heldBuilding = nil
                buildMenu.deselect()
                toolTip?.removeFromSuperview()
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
            let t = 0.5 + (cameraNode.position.y / 10)
            self.cameraNode.position.y = initialY - (Float(sender.scale) - 1) * sin(cameraNode.eulerAngles.x) * 13 * t
            self.cameraNode.position.y = initialY - (Float(sender.scale) - 1) * cos(cameraNode.eulerAngles.x) * 13 * t
            cameraNode.eulerAngles.x = -1 + (15 - self.cameraNode.position.y)/20
            if cameraNode.position.y < 4 {
                cameraNode.position.y = 4.05
            }
        default: break
        }
    }
    
    func updatedPlayerGold(gold: Int) {
        goldLabel.text = String(format: "%d", gold)
    }
    
    func gameEndedWithResult(result: GameResult) {
        
    }
    
    @IBAction func singlePlayerPressed() {
        self.gameChoiceView.isHidden = true
        
        myPlayer = gameScene.player1
        
        setupView()
        setupScene()
        setupMenu()
        gameScene.loadMap()
        lastUpdateTime = CACurrentMediaTime()
        gameAI = BaseAI(gameScene: gameScene, player: gameScene.player2)
        
        DispatchQueue.main.async {
            print("Starting")
            self.scnView.isPlaying = true
        }
    }
    
    @IBAction func multiPLayerPressed() {
        gameChoiceView.isHidden = true
        hostOrJoinView.isHidden = false
    }
    
    @IBAction func hostGamePress() {
        hostOrJoinView.isHidden = true
        hostView.isHidden = false
        myPlayer = [gameScene.player1, gameScene.player2].randomItem()
        networkPlayer = NetworkPlayer(player: myPlayer, networkRole: .host)
        hostIPLabel.text = getWiFiAddress()
    }
    
    @IBAction func joinGamePressed() {
        hostOrJoinView.isHidden = true
        connectView.isHidden = false
        if let lastConnectIp = UserDefaults.standard.string(forKey: "connectString") {
            connectIPEntry.text = lastConnectIp
        }
    }
    
    @IBAction func connectToGamePressed() {
        networkPlayer = NetworkPlayer(player: gameScene.player1, networkRole: .client)
        UserDefaults.standard.setValue(connectIPEntry.text!, forKey: "connectString")
        networkPlayer!.connectToHost(connectIPEntry.text!)
    }
    
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
    
}  

var tick: TimeInterval = 0

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time:
        TimeInterval) {
        
        guard scnView.isPlaying else { return }
        
        let dt = CACurrentMediaTime() - lastUpdateTime
        lastUpdateTime = CACurrentMediaTime()
        
        tick += dt
        
        if (tick > 0.05) {
            DispatchQueue.main.async {
                self.gameScene.update(dt: 0.05)
                self.gameAI?.update(dt: 0.05)
                self.networkPlayer?.update(dt: 0.05)
                self.hud.update(dt: 0.05)
                tick -= 0.05
            }
        }
        
        if let velocity = cameraVelocity {
            if abs(velocity.x) > 5 || abs(velocity.y) > 5 {
                let dx = Double(velocity.x)
                self.cameraNode.position.x -= Float(dx / (50 / dt))
                let dz = Double(velocity.y)
                self.cameraNode.position.z -= Float(dz / (50 / dt))
                cameraVelocity = CGPoint(x: velocity.x * CGFloat(1 - (dt/0.4)),
                                         y: velocity.y * CGFloat(1 - (dt/0.4)))
            } else {
                cameraVelocity = nil
            }
        }
    }
}


