//
//  TabController.swift
//  TweetFavs
//
//  Created by Javier Figueroa on 12/30/14.
//  Copyright (c) 2014 Mainloop LLC. All rights reserved.
//

import UIKit

@objc class TabController: UITabBarController, UIActionSheetDelegate{
    var accounts: [ACAccount]!;
    override func viewDidLoad() {
        TFTheme.styleNavigationBar();
        TFTheme.styleTabBar(self.tabBar);
        
        //set all favorites controller
        let tweetsController = TweetsController(nibName: "TweetsController", bundle: nil);
        tweetsController.title = "Favs";
        tweetsController.refreshBlock = { (tweet) -> Void in
            TFTweetsAdapter.getFavoriteTweetsSinceID(tweet.tweetID, andMaxID: nil) { (tweets) -> Void in
                (tweetsController.tableView.dataSource as TFFeedDataSource).tweets = NSMutableArray(array: tweets);
                tweetsController.reloadTable();
                tweetsController.refreshCompleted();
            };
        };
        tweetsController.loadMoreBlock = { (tweet) -> Void in
            TFTweetsAdapter.getFavoriteTweetsSinceID(nil, andMaxID: tweet.tweetID) { (tweets) -> Void in
                (tweetsController.tableView.dataSource as TFFeedDataSource).tweets = NSMutableArray(array: tweets);
                tweetsController.reloadTable();
                tweetsController.loadMoreCompleted();
            };
        };
        
        let dataSource = TFFeedDataSource();
        tweetsController.dataSource = dataSource;
        tweetsController.pullToRefreshEnabled = true;
        tweetsController.canLoadMore = true;
        
        NSNotificationCenter.defaultCenter().addObserverForName(TFCategoriesFetched, object: nil, queue: nil) { (notifcation) -> Void in
            TFTweetsAdapter.getFavoriteTweetsWithCompletion({ (tweets) -> Void in
                dataSource.tweets = NSMutableArray(array: tweets);
                tweetsController.reloadTable();
            });
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(TFGetAccounts, object: nil, queue: nil) { (notifcation) -> Void in
            self.showAccountsActionSheet(nil);
        }
        
        let tweetsNavController = UINavigationController(rootViewController: tweetsController);
        
        //set categories controller
        let categoriesController = CategoriesController(nibName: "CategoriesController", bundle: nil);
        let categoriesNavController = UINavigationController(rootViewController: categoriesController);

        //set tab bar items
        let tweetsItem = UITabBarItem(title: "Favs", image:UIImage(named: "outline-star"), tag: 0);
        let categoriesItem = UITabBarItem(title: "Categories", image: UIImage(named: "check"), tag: 1);
        tweetsNavController.tabBarItem = tweetsItem;
        categoriesNavController.tabBarItem = categoriesItem;
        
        //assign controllers
        self.viewControllers = [tweetsNavController, categoriesNavController];
    }
    
    override func viewDidAppear(animated: Bool) {
        //check for twitter accounts
        self.checkTwitterAccounts();
    }
    
    func checkTwitterAccounts() {
        let manager = TFTwitterManager.sharedManager();
        if (manager.twitterAccount != nil) {
            TFTweetsAdapter.getCategories();
        }else{
            let username = NSUserDefaults.standardUserDefaults().stringForKey("twitter_username");
            self.showAccountsActionSheet(username);
        }
    }
    
    func showAccountsActionSheet(existingUsername: String?) {
        let manager = TFTwitterManager.sharedManager();
        manager.getTwitterAccounts({ (accounts, error) -> Void in
            if (error != nil && error.code != 600 || accounts.count == 0) {
                UIAlertView(title: "No Twitter Accounts", message: "We couldn't find any authorized twitter accounts in your phone, please add one and try again", delegate: nil, cancelButtonTitle: nil).show();
            }else{
                if (existingUsername != nil) {
                    for account in accounts as [ACAccount] {
                        if (account.username == existingUsername) {
                            self.selectAccount(account);
                            break;
                        }
                    }
                }else{
                    let sheet = UIActionSheet();
                    sheet.title = "Select a twitter account";
                    sheet.delegate = self;
                    
                    for account in accounts as [ACAccount] {
                        sheet.addButtonWithTitle(account.username);
                    }
                    
                    sheet.addButtonWithTitle("Cancel");
                    sheet.cancelButtonIndex = accounts.count;
                    self.accounts = accounts as [ACAccount];
                    sheet.showFromTabBar(self.tabBar);
                }
            }
        });
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            self.selectAccount(self.accounts[buttonIndex]);
        }
    }
    
    func selectAccount(account: ACAccount) {
        NSUserDefaults.standardUserDefaults().setValue(account.username, forKey: "twitter_username");
        TFTwitterManager.sharedManager().twitterAccount = account;
        TFTweetsAdapter.getCategories();
        NSNotificationCenter.defaultCenter().postNotificationName(TFAccountSelected, object: nil);
    }
}