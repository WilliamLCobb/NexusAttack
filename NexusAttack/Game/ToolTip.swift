//
//  ToolTip.swift
//  NexusAttack
//
//  Created by William Cobb on 8/9/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import UIKit

class ToolTipView: UIView {
    var titleLabel = UILabel(frame: CGRect(x: 8, y: 8, width: 200, height: 20))
    var goldImage = UIImageView(frame: CGRect(x: 8, y: 30, width: 13, height: 13))
    var costLabel = UILabel(frame: CGRect(x: 24, y: 28, width: 200, height: 15))
    var spawnLabel = UILabel(frame: CGRect(x: 8, y: 43, width: 200, height: 15))
    var descriptionLabel = UILabel(frame: CGRect(x: 8, y: 58, width: 200, height: 50))
    
    var title: String
    var cost: String
    var spawnTime: String
    var descriptionText: String
    
    init(frame: CGRect, title: String, cost: String, spawnTime: String, description: String) {
        self.title = title
        self.cost = cost
        self.spawnTime = spawnTime
        self.descriptionText = description
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: 200, height: 132))
        
        addSubview(titleLabel)
        addSubview(goldImage)
        addSubview(costLabel)
        addSubview(spawnLabel)
        addSubview(descriptionLabel)
        
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        goldImage.image = #imageLiteral(resourceName: "gold.png")
        costLabel.text = cost
        costLabel.textColor = .white
        costLabel.font = UIFont.boldSystemFont(ofSize: 13)
        spawnLabel.text = spawnTime
        spawnLabel.textColor = .white
        spawnLabel.font = UIFont.boldSystemFont(ofSize: 13)
        descriptionLabel.text = descriptionText
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 13)
        
        self.layer.borderColor = UIColor(white: 179/255, alpha: 1.0).cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 3
        self.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 40/255, alpha: 0.9)
    }
    
    convenience init(frame: CGRect, building: BuildingSpawner) {
        self.init(frame: frame,
                  title: building.name ?? "Unknown Name",
                  cost: String(building.cost),
                  spawnTime: String(format: "Spawn Rate: %d seconds", Int(building.spawnTime)),
                  description: "Generic description")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
