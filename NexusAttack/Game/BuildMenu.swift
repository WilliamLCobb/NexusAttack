//
//  BuildMenu.swift
//  NexusAttack
//
//  Created by Will Cobb on 7/1/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import UIKit

protocol MenuDelegate {
    func selectedBuilding(building: Building)
}

struct BuildMenuItem {
    var name: String
    var icon: UIImage
    var building: Building
    
    init(name: String, icon: UIImage, building: Building) {
        self.name = name
        self.icon = icon
        self.building = building
    }
}

class MenuCollectionView: UICollectionView {
    var selectionDelegate: MenuDelegate?
    var oldCell: BuildMenuCell? // Hack
    var lastTime: TimeInterval = 0
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if event!.timestamp > lastTime {
            lastTime = event!.timestamp
            //canSelect = false
            let view = super.hitTest(point, with: event)
            if let cell = view?.superview as? BuildMenuCell { // TODO: Terrible hack
                cell.select()
                if let oldCell = self.oldCell {
                    if oldCell != cell {
                        oldCell.deselect()
                        self.selectionDelegate?.selectedBuilding(building: cell.item.building)
                    } else {
                        self.selectionDelegate?.selectedBuilding(building: cell.item.building)
                    }
                } else {
                    self.selectionDelegate?.selectedBuilding(building: cell.item.building)
                }
                oldCell = cell
            }
        } else {
            print("rejected")
        }
        return nil
    }
}

class BuildMenuView: UIView {
    var collectionView: MenuCollectionView
    var items: [BuildMenuItem]
    var showing = false
    
    init(frame: CGRect, items: [BuildMenuItem], delegate: MenuDelegate) {
        let layout = UICollectionViewFlowLayout()
        collectionView = MenuCollectionView(frame: CGRect(origin: CGPoint.zero, size: frame.size),
                                            collectionViewLayout: layout)
        collectionView.selectionDelegate = delegate
        self.items = items
        super.init(frame: frame)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BuildMenuCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = .black
        layout.itemSize = CGSize(width: 42, height: 42)
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 3
        self.addSubview(collectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func deselect() {
        collectionView.oldCell?.deselect()
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


extension BuildMenuView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected")
    }
}

extension BuildMenuView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                      for: indexPath) as! BuildMenuCell
        let item = items[indexPath.row]
        cell.configure(item: item)
        cell.tag = indexPath.row
        return cell
    }
}

class BuildMenuCell: UICollectionViewCell {
    var imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 32, height: 32))
    var title = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
    var item: BuildMenuItem!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(title)
        
        title.font = UIFont.systemFont(ofSize: 8.0)
        title.textAlignment = .center
        title.textColor = .white
        title.numberOfLines = 0
        title.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func select() {
        self.backgroundColor = .green
    }
    
    func deselect() {
        self.backgroundColor = .clear
    }
    
    func configure(item: BuildMenuItem) {
        self.item = item
        imageView.image = item.icon
        title.text = item.name
    }
}
