//
//  HomeViewDelegate.swift
//  Twitter
//
//  Created by Donatea Zefi on 3/01/16
//  Copyright © 2016 Donatea. All rights reserved.
//

import UIKit

protocol TweetTableViewDelegate: class, UITableViewDelegate {
    func reloadTableCellAtIndex(cell: UITableViewCell, indexPath: NSIndexPath);
    
    func openProfile(userScreenname: NSString);
    
    func openCompose(viewController: UIViewController);
}
