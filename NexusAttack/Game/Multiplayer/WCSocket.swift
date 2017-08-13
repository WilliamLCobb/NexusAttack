  //
//  WCSocket.swift
//  NexusAttack
//
//  Created by Will Cobb on 8/5/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
import SceneKit

enum ConnectionRole {
    case host
    case client
}

protocol WCSocketDelegate {
    func startGame()
    func updatedPlayer(player: Player)
    func receivedObject(object: BuildingSpawner, atTime: TimeInterval)
}

var objectList = [String(describing: HumanBarracks.self): HumanBarracks.self,
                  String(describing: Workshop.self): Workshop.self]

class WCSocket: NSObject, GCDAsyncSocketDelegate {
    var delegate: WCSocketDelegate?
    var role: ConnectionRole
    var player: Player
    var hostSocket: GCDAsyncSocket!
    var socket: GCDAsyncSocket!
    
    let delegateQueue = DispatchQueue(label: "Delegate Queue")
    
    init(withPlayer player: Player, role: ConnectionRole) {
        self.role = role
        self.player = player
        super.init()
        if role == .host {
            setUpServer()
        } else {
            setUpClient()
        }
    }
    
    func sendObject(_ object: BaseObject) {
        let encodedString = encodeObject(object) + "!"
        sendString(encodedString)
    }
    
    private func encodeObject(_ object: BaseObject) -> String {
        var components: [Any] = [globalGameUtility.currentTime]
        components.append(object.networkObjects())
        var objectString = String(describing: object) + " "
        
        for component in components {
            if component is SCNVector3 {
                let vec = component as! SCNVector3
                objectString += "\(vec.x),\(vec.y),\(vec.z)"
            } else if component is Double {
                objectString += "\(component)"
            }
            objectString += " "
        }
        return objectString
    }
    
    private func decodeObject(_ string: String) -> (building: BuildingSpawner, captureTime: TimeInterval)  {
        let components = string.components(separatedBy: " ")
        let objectName: String = components[0] 
        let captureTime: TimeInterval = TimeInterval(components[1])!
        let position = SCNVector3.from(codedString: components[2])
        let buildingType = objectList[objectName]!
        let newBuilding = buildingType.init(player: self.player, position: position)
        return (newBuilding, captureTime)
    }
    
    private func sendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8)!
        socket.write(data, withTimeout: 30, tag: 0)
    }
    
    func receivedString(_ string: String) {
        var networkObjects = [Any]()
        let components = string.components(separatedBy: " ")
        for object in components {
            let objectComponents = object.components(separatedBy: ":")
            let type = objectComponents[0]
            let data = objectComponents[1]
            if type == "sv3" {
                let values = data.components(separatedBy: ",")
                let x = Float(values[0])!
                let y = Float(values[0])!
                let z = Float(values[0])!
                networkObjects.append(SCNVector3(x, y, z))
            }
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let dataString = String(data: data, encoding: String.Encoding.utf8)!
        let newObject = decodeObject(dataString)
        DispatchQueue.main.async {
            self.delegate?.receivedObject(object: newObject.building, atTime: newObject.captureTime)
        }
        
        socket.readData(to: "!".data(using: String.Encoding.utf8)!, withTimeout: 30, tag: 0)
    }
    
    /* Host */
    func setUpServer() {
        hostSocket = GCDAsyncSocket(delegate: self, delegateQueue: delegateQueue)
        do {
            try hostSocket.accept(onPort: 5020)
        } catch {
            assertionFailure("Unable to start server")
        }
    }

    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        socket = newSocket
        socket.readData(to: "!".data(using: String.Encoding.utf8)!, withTimeout: 30, tag: 0)
    }

    /* Client */
    func setUpClient() {
        socket = GCDAsyncSocket(delegate: self, delegateQueue: delegateQueue)
    }
    
    func connectToHost(_ host: String) {
        do {
            try socket.connect(toHost: host, onPort: 5020)
        } catch {
            print("Error connecting: \(error)")
        }
        
        socket.readData(to: "!".data(using: String.Encoding.utf8)!, withTimeout: 30, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("Connected to host!")
    }
}

extension SCNVector3 {
    
    static func from(codedString string: String) -> SCNVector3 {
        let components = string.components(separatedBy: ",")
        return SCNVector3(Float(components[0])!, Float(components[1])!, Float(components[2])!)
    }
}

