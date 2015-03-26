//
//  TweetsController.swift
//  TweetFavs
//
//  Created by Javier Figueroa on 12/31/14.
//  Copyright (c) 2014 Mainloop LLC. All rights reserved.
//

import UIKit

typealias CompletionBlock = (tweet: TFTweet) -> ()

class TweetsController: STableViewController, UITableViewDelegate {
    @IBOutlet weak var table: UITableView!
    @IBOutlet var emptyStateView: UIView!
    
    var dataSource: TFFeedDataSource!
    var refreshBlock: CompletionBlock!
    var loadMoreBlock: CompletionBlock!
    
    override func viewDidLoad() {
        self.tableView = self.table;
        self.tableView.dataSource = self.dataSource;
        self.tableView.registerNib(UINib(nibName: "TFFeedCell", bundle: nil), forCellReuseIdentifier: "FeedCell");
        
        if (self.pullToRefreshEnabled){
            self.headerView = TFRefreshHeaderView();
        }
        
        if (self.canLoadMore) {
            self.footerView = TFRefreshFooterView();
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(TFCategoriesEdited, object: nil, queue: nil) { (notification) -> Void in
            self.reloadTable();
        }
        
        TFTheme.customizeFeedController(self);
        
    }
    
    func reloadTable() {
        self.tableView.reloadData();
        
        if ((self.tableView.dataSource as TFFeedDataSource).tweets.count == 0) {
            self.tableView.addSubview(self.emptyStateView);
        }else{
            self.emptyStateView.removeFromSuperview();
        }
    }

    //TableView Delegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 125;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = TFTweetViewController(nibName: "TFTweetViewController", bundle: nil) as TFTweetViewController;
        controller.tweet = (self.tableView.dataSource as TFFeedDataSource).tweets[indexPath.row] as TFTweet;
        self.navigationController?.pushViewController(controller, animated: true);
    }
    
    //Pull to refresh
    
    override func pinHeaderView() {
        let header = self.headerView as TFRefreshHeaderView;
        header.activityIndicator.startAnimating();
        header.label.text = "Loading";
    }
    
    override func unpinHeaderView() {
        let header = self.headerView as TFRefreshHeaderView;
        header.activityIndicator.stopAnimating();
    }
    
    override func headerViewDidScroll(willRefreshOnRelease: Bool, scrollView: UIScrollView!) {
        if (self.pullToRefreshEnabled) {
            
            let header = self.headerView as TFRefreshHeaderView;
            if(willRefreshOnRelease){
                header.label.text = "Release to refresh..";
            }else{
                header.label.text = "Pull down to refresh...";
            }
            
        }
    }
    
    override func refresh() -> Bool {
        if (!super.refresh()) {
            self.refreshCompleted();
            return false;
        }
        
        let tweets = (self.tableView.dataSource as TFFeedDataSource).tweets;
        if (tweets.count == 0) {
            self.refreshCompleted();
            return false;
        }
        
        let firstTweet = tweets[0] as TFTweet;
        self.refreshBlock(tweet: firstTweet);
        
        return true;
    }
    
    //Load more 
    
    override func willBeginLoadingMore() {
        (self.footerView as TFRefreshFooterView).activityIndicator.startAnimating();
    }
    
    override func loadMoreCompleted() {
        super.loadMoreCompleted();
        (self.footerView as TFRefreshFooterView).activityIndicator.stopAnimating();
        if (!self.canLoadMore) {
            self.setFooterViewVisibility(false);
        }
    }
    
    override func loadMore() -> Bool {
        if(!super.loadMore()){
            self.loadMoreCompleted();
            return false;
        }
        
        let tweets = (self.tableView.dataSource as TFFeedDataSource).tweets;
        if (tweets.count == 0) {
            self.loadMoreCompleted();
            return false;
        }
        
        let lastTweet = tweets[tweets.count - 1] as TFTweet;
        self.loadMoreBlock(tweet: lastTweet);
        
        return true;
    }
}
