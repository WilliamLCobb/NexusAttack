//
//  Player.swift
//  NexusAttack
//
//  Created by Will Cobb on 6/17/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import UIKit

class Player {
    var id: Int
    var name: String
    var color: UIColor
    var minerals: Int
    private var mineralsSpent: Int = 0
    var income: Int {
        return 10 + (mineralsSpent / 50) * 2
    }
    var team: Team
    
    init(id: Int, name: String, color: UIColor, team: Team) {
        self.id = id
        self.name = name
        self.color = color
        self.team = team
        self.minerals = 250
    }
    
    func addMinerals(_ minerals: Int) {
        self.minerals += minerals
    }
    
    func spendMinerals(_ minerals: Int) {
        self.minerals -= minerals
        self.mineralsSpent += minerals
        assert(self.minerals >= 0)
    }
    
    func generateIncome() {
        self.minerals += income
    }
}
