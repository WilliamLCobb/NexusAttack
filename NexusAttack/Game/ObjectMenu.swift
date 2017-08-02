//
//  ObjectMenu.swift
//  NexusAttack
//
//  Created by Will Cobb on 7/1/17.
//  Copyright © 2017 CobbWeb. All rights reserved.
//

import UIKit

struct ObjectMenuItem {
    var name: String
    var icon: UIImage
    var action: ((BaseObject) -> ())
    
    init(name: String, icon: UIImage, action: @escaping ((BaseObject) -> ())) {
        self.name = name
        self.icon = icon
        self.action = action
    }
}

class ObjectMenuView: UIView {
    var collectionView: MenuCollectionView
    var tab: UIView!
    var items: [ObjectMenuItem]
    var showing = false
    var selectedObject: BaseObject!
    
    init(frame: CGRect, items: [ObjectMenuItem], delegate: MenuDelegate) {
        let layout = UICollectionViewFlowLayout()
        collectionView = MenuCollectionView(frame: CGRect(x: 25, y: 0, width: frame.size.width - 25, height: frame.size.height),
                                            collectionViewLayout: layout)
        collectionView.selectionDelegate = delegate
        self.items = items
        super.init(frame: frame)
        
        tab = UIView(frame: CGRect(x: 0, y: frame.size.height/2 - 40, width: 35, height: 80))
        tab.backgroundColor = .brown
        tab.layer.cornerRadius = 10.0
        let tabTap = UITapGestureRecognizer(target: self, action: #selector(toggleMenu))
        tab.addGestureRecognizer(tabTap)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ObjectMenuCell.self, forCellWithReuseIdentifier: "Cell")
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
        let screenWidth = UIScreen.main.bounds.width
        if (showing) {
            showing = false
            UIView.animate(withDuration: 0.2, animations: {
                self.frame = CGRect(x: screenWidth - 25,
                                    y: 0,
                                    width: self.frame.size.width,
                                    height: self.frame.size.height)
            })
        } else {
            showing = true
            UIView.animate(withDuration: 0.2, animations: {
                self.frame = CGRect(x: screenWidth - self.frame.size.width,
                                    y: 0,
                                    width: self.frame.size.width,
                                    height: self.frame.size.height)
            })
        }
    }
}


extension ObjectMenuView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        item.action(selectedObject)
    }
}

extension ObjectMenuView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                      for: indexPath) as! ObjectMenuCell
        let item = items[indexPath.row]
        cell.configure(item: item)
        cell.tag = indexPath.row
        return cell
    }
}

class ObjectMenuCell: UICollectionViewCell {
    var imageView = UIImageView(frame: CGRect(x: 5, y: 0, width: 40, height: 40))
    var title = UILabel(frame: CGRect(x: 0, y: 45, width: 50, height: 20))
    var item: ObjectMenuItem!
    
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
    
    func configure(item: ObjectMenuItem) {
        self.item = item
        imageView.image = item.icon
        title.text = item.name
    }
}
