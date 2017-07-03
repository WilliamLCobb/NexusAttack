//
//  Team.swift
//  NexusAttack
//
//  Created by Will Cobb on 6/18/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import UIKit

class Team {
    var id: Int
    var color: UIColor
    var units = [Unit]()
    var buildings = [Building]()
    var players = [Player]()
    
    init(id: Int, color: UIColor) {
        self.id = id
        self.color = color
    }
    
    func add(unit: Unit) {
        self.units.append(unit)
    }
    func add(building: Building) {
        self.buildings.append(building)
    }
}

extension Team: Equatable {
    static func == (lhs: Team, rhs: Team) -> Bool {
        return lhs.id == rhs.id
    }
}
