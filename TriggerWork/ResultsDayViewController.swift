//
//  ResultsDayViewController.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/16/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import UIKit

class ResultsDayViewController: UIViewController {
    
    var storedOffsets = [Int: CGFloat]()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = Colors.defaultBlackColor()
        tableView.separatorStyle = .None
    }
}

extension ResultsDayViewController: UITableViewDelegate {
    
}

extension ResultsDayViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SessionTableViewCell
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title: String!
        switch (section) {
        case 0:
             title = "Session One: 0:43.2"
            break;
        case 1:
            title = "Session Two: 0:45.1"
            break;
        case 2:
            title = "Session Three: 0:37.9"
            break;
        default:
            title = ""
            break;
        }
        
        return title
        
    }
}

extension ResultsDayViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ShotCollectionViewCell
        
        cell.timeLabel.text = "0:03.2"
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Selected Item")
    }
}

extension ResultsDayViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 5
    }
    
}
