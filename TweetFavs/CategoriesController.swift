//
//  CategoriesController.swift
//  TweetFavs
//
//  Created by Javier Figueroa on 12/31/14.
//  Copyright (c) 2014 Mainloop LLC. All rights reserved.
//

import UIKit

class CategoriesController:UIViewController, UITableViewDelegate, UITextFieldDelegate {
    @IBOutlet
    var tableView: UITableView!
    @IBOutlet
    var tableFooter: UIView!
    var tableDataSource: TFCategoriesDataSource!
    var settingsButton: UIBarButtonItem {
        get {
            return UIBarButtonItem(image: UIImage(named: "settings"), style: UIBarButtonItemStyle.Plain, target: self, action: "toggleEditMode");
        }
    }
    var cancelButton: UIBarButtonItem {
        get {
            return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "toggleEditMode");
        }
    }
    var saveButton: UIBarButtonItem {
        get {
            return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "didPressRightBarButton");
        }
    }
    var accountsButton: UIBarButtonItem {
        get {
            return UIBarButtonItem(image: UIImage(named: "account"), style: UIBarButtonItemStyle.Plain, target: self, action: "didPressRightBarButton");
        }
    }
    
    override func viewDidLoad() {
        
        self.tableDataSource = TFCategoriesDataSource();
        self.tableView.dataSource = self.tableDataSource;
        
        self.tableView.registerNib(UINib(nibName: "TFCategoryCell", bundle: nil), forCellReuseIdentifier: "TFCategoryCell");
        self.tableView.registerNib(UINib(nibName: "TFEditCategoryCell", bundle: nil), forCellReuseIdentifier: "TFEditCategoryCell");

        let manager = TFTwitterManager.sharedManager();
        self.navigationItem.title = manager.twitterAccount.username;
        
        NSNotificationCenter.defaultCenter().addObserverForName(TFAccountSelected, object: nil, queue: nil) { (notification) -> Void in
            self.navigationItem.title = manager.twitterAccount.username;
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(TFCategoriesFetched, object: nil, queue: nil) { (notification) -> Void in
            self.reloadCategories();
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(TFCategoriesEdited, object: nil, queue: nil) { (notification) -> Void in
            self.reloadCategories();
        }
        
        self.navigationItem.leftBarButtonItem = self.settingsButton;
        self.navigationItem.rightBarButtonItem = self.accountsButton;
        
        TFTheme.customizeCategoriesController(self)
    }
    
    //TableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dataSource = self.tableView.dataSource as TFCategoriesDataSource;
        let category = dataSource.getCategoryByIndexPath(indexPath);
        
        if (self.tableView.editing) {
            if (!category.editing) {
                category.editing = true;
                self.tableView.beginUpdates();
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left);
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left);
                self.tableView.endUpdates();
            }
        }else{
            category.editing = false;
            let viewController = TweetsController(nibName: "TweetsController", bundle: nil);
            viewController.title = category.name;
            viewController.canLoadMore = false;
            viewController.pullToRefreshEnabled = false;
            viewController.setFooterViewVisibility(false);
            
            TFTweet.getByCategory(category, completion: { (tweets, error) -> Void in
                category.tweets = NSMutableArray(array: tweets);
                let feedDataSource = TFFeedDataSource();
                feedDataSource.tweets = category.tweets;
                viewController.dataSource = feedDataSource;
                TFTheme.setBackButton(viewController);
                self.navigationController?.pushViewController(viewController, animated: true);
            });
            
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44;
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.tableFooter;
    }
    
    //TextField Delegate

    func textFieldDidBeginEditing(textField: UITextField) {
        self.tableView.setContentOffset(CGPointMake(0, self.navigationController!.navigationBar.frame.size.height), animated: true);
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField.text != "") {
            TFCategory.addCategoryWithName(textField.text, completion: { (category, error) -> Void in
                if (error == nil){
                    textField.text = "";
                    let categories = TFCategories.sharedCategories().categories;
                    categories[category.ID] = category;
                    self.reloadCategories();
                }
            });
        }
        
        
        textField.resignFirstResponder();
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    //Actions
    
    func reloadCategories() {
        self.tableDataSource.sortedCategories = nil;
        self.tableView.reloadData();
    }
    
    func didPressRightBarButton() {
        //when editing this button is to save changes, otherwise it used to show the accounts actionsheet
        if (self.tableView.editing) {
            var categories = TFCategories.sharedCategories().categories;
            categories.enumerateKeysAndObjectsUsingBlock({ (key, obj, stop) -> Void in
                let category = obj as TFCategory;
                if (category.editing) {
                    TFCategory.updateCategory(category, completion: { (category, error) -> Void in
                        if (error == nil) {
                            categories[category.ID] = category;
                        }
                    });
                }
            });
            
            self.toggleEditMode();
        }else{
            NSNotificationCenter.defaultCenter().postNotificationName(TFGetAccounts, object: nil);
        }
    }
    
    func toggleEditMode() {
        var reloadItems : Array<NSIndexPath> = [];
        if (self.tableView.editing) {
            let categories = TFCategories.sharedCategories().categories;
                for (var i=0; i<categories.allKeys.count; i++) {
                let key = categories.allKeys[i] as NSString;
                let category = categories[key] as TFCategory;
                category.editing = false;
                reloadItems.append(NSIndexPath(forRow: i, inSection: 0));
            }
        }
        
        self.tableView.setEditing(!self.tableView.editing, animated: true);
        self.tableView.reloadRowsAtIndexPaths(reloadItems, withRowAnimation: UITableViewRowAnimation.Fade);
        
        if (self.tableView.editing) {
            self.navigationItem.leftBarButtonItem = self.cancelButton;
            self.navigationItem.rightBarButtonItem = self.saveButton;
        }else{
            self.navigationItem.leftBarButtonItem = self.settingsButton;
            self.navigationItem.rightBarButtonItem = self.accountsButton;
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(TFCategoriesEdited, object: nil);
    }
}
