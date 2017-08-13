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
    var gold: Int
    var target: Building!
    private var goldSpent: Int = 0
    var income: Int {
        return 10 + (goldSpent / 50) * 1
    }
    var team: Team
    
    init(id: Int, name: String, color: UIColor, team: Team) {
        self.id = id
        self.name = name
        self.color = color
        self.team = team
        self.gold = 400
    }
    
    func addMinerals(_ gold: Int) {
        self.gold += gold
    }
    
    func spendMinerals(_ gold: Int) {
        self.gold -= gold
        self.goldSpent += gold
        assert(self.gold >= 0)
    }
    
    func generateIncome() {
        self.gold += income
    }
}
