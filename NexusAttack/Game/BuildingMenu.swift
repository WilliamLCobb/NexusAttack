//
//  BuildingMenu.swift
//  NexusAttack
//
//  Created by Will Cobb on 7/1/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import UIKit

protocol BuildingMenuDelegate {
    func selectedBuilding(building: Building)
}

struct BuildingMenuItem {
    var name: String
    var color: UIColor
    var building: Building
    
    init(name: String, color: UIColor, building: Building) {
        self.name = name
        self.color = color
        self.building = building
    }
}

class MenuCollectionView: UICollectionView {
    var selectionDelegate: BuildingMenuDelegate?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if let cell = view?.superview as? BuildingMenuCell {
            self.selectionDelegate?.selectedBuilding(building: cell.item.building)
        }
        return nil
    }
}

class BuildingMenuView: UIView {
    var collectionView: MenuCollectionView
    var tab: UIView!
    var items: [BuildingMenuItem]
    var showing = false
    
    init(frame: CGRect, items: [BuildingMenuItem], delegate: BuildingMenuDelegate) {
        let layout = UICollectionViewFlowLayout()
        collectionView = MenuCollectionView(frame: CGRect(x: 0, y: 0, width: frame.size.width - 25, height: frame.size.height),
                                            collectionViewLayout: layout)
        collectionView.selectionDelegate = delegate
        self.items = items
        super.init(frame: frame)
        
        tab = UIView(frame: CGRect(x: frame.size.width - 35, y: frame.size.height/2 - 40, width: 35, height: 80))
        tab.backgroundColor = .brown
        tab.layer.cornerRadius = 10.0
        let tabTap = UITapGestureRecognizer(target: self, action: #selector(toggleMenu))
        tab.addGestureRecognizer(tabTap)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BuildingMenuCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = .brown
        layout.itemSize = CGSize(width: 50, height: 65)
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 0, 5)
        self.addSubview(tab)
        self.addSubview(collectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toggleMenu() {
        if (showing) {
            showing = false
            UIView.animate(withDuration: 0.2, animations: { 
                self.frame = CGRect(x: -self.frame.size.width + 25,
                                    y: 0,
                                    width: self.frame.size.width,
                                    height: self.frame.size.height)
            })
        } else {
            showing = true
            UIView.animate(withDuration: 0.2, animations: {
                self.frame = CGRect(x: 0,
                                    y: 0,
                                    width: self.frame.size.width,
                                    height: self.frame.size.height)
            })
        }
    }
}


extension BuildingMenuView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
    }
}

extension BuildingMenuView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                      for: indexPath) as! BuildingMenuCell
        let item = items[indexPath.row]
        cell.configure(item: item)
        cell.tag = indexPath.row
        return cell
    }
}

class BuildingMenuCell: UICollectionViewCell {
    var imageView = UIImageView(frame: CGRect(x: 5, y: 0, width: 40, height: 40))
    var title = UILabel(frame: CGRect(x: 0, y: 45, width: 50, height: 20))
    var item: BuildingMenuItem!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(title)
        
        title.font = UIFont.systemFont(ofSize: 8.0)
        title.textAlignment = .center
        title.textColor = .white
        title.numberOfLines = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(item: BuildingMenuItem) {
        self.item = item
        imageView.backgroundColor = item.color
        title.text = item.name
    }
}
