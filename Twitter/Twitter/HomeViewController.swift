//
//  HomeViewController.swift
//  Twitter
//
//  Created by Donatea Zefi on 3/01/16
//  Copyright © 2016 Donatea. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, TweetTableViewDelegate {
    
    var refreshControl: UIRefreshControl!;
    var isMoreDataLoading = false;
    var loadingMoreView: InfiniteScrollActivityView?;
    
    var lastTweetId: Int?;

    var tweets: [Tweet]? {
        didSet {
            lastTweetId = tweets![tweets!.endIndex - 1].TweetID as Int;
        }
    };
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        UIApplication.sharedApplication().statusBarStyle = .Default;

        
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 160.0;
        
        reloadData();
        
        // Set up Pull To Refresh loading indicator
        refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: "reloadData:", forControlEvents: UIControlEvents.ValueChanged);
        tableView.insertSubview(refreshControl, atIndex: 0);
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
        loadingMoreView = InfiniteScrollActivityView(frame: frame);
        loadingMoreView!.hidden = true;
        tableView.addSubview(loadingMoreView!);
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tweets == nil) {
            return 0;
        } else {
            return tweets!.count;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCompactCell", forIndexPath: indexPath) as! TweetCompactCell;
        cell.indexPath = indexPath;
        cell.tweet = tweets![indexPath.row];
        cell.delegate = self;
        return cell;
    }
    
    var reloadedIndexPaths = [Int]();
    
    func reloadTableCellAtIndex(cell: UITableViewCell, indexPath: NSIndexPath) {
        if(reloadedIndexPaths.indexOf(indexPath.row) == nil) {
            reloadedIndexPaths.append(indexPath.row);
            try! tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic);
        }
    }
        
    func reloadData(append: Bool = false) {
        var completion = { (tweets: [Tweet]) -> () in
            self.tweets = tweets;
            self.tableView.reloadData();
            self.refreshControl.endRefreshing()
        };
        
        if(append) {
            completion = { (tweets: [Tweet]) -> () in
                var cleaned = tweets;
                if(tweets.count > 0) {
                    cleaned.removeAtIndex(0); // api param "max_id" is inclusive
                }
                if(cleaned.count > 0) {
                    self.tweets?.appendContentsOf(cleaned);
                    self.isMoreDataLoading = false
                    self.loadingMoreView!.stopAnimating()
                    self.tableView.reloadData();
                }
            };
        } else {
            lastTweetId = nil;
        }
        
        TwitterClient.sharedInstance.homeTimeline(lastTweetId, success: completion, failure: { (error: NSError) -> () in
                print(error.localizedDescription);
        });
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading && tweets?.count > 0) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height;
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                reloadData(true);
                // ... Code to load more results ...
            }
        }
    }
    
    func openProfile(userScreenname: NSString){
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle());
        let vc = storyboard.instantiateViewControllerWithIdentifier("ProfileViewNavigationController") as! UINavigationController;
        let pVc = vc.viewControllers.first as! ProfileViewController;
        pVc.userScreenname = userScreenname;
        self.presentViewController(vc, animated: true, completion: nil);
    }
    
    func openCompose(vc: UIViewController) {
        self.presentViewController(vc, animated: true, completion: nil);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toDetails") {
            let backItem = UIBarButtonItem();
            backItem.title = "";
            navigationItem.backBarButtonItem = backItem;

            let cell = sender as! UITableViewCell;
            let indexPath = tableView.indexPathForCell(cell);
            let tweet = tweets![indexPath!.row];
            self.navigationController?.navigationBarHidden = false;
        }
    }

}
