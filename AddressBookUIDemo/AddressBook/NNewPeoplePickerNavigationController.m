//
//  NNewPeoplePickerNavigationController.m
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14/12/17.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import "NNewPeoplePickerNavigationController.h"

@implementation NNewPeoplePickerNavigationController

#pragma mark - search controller delegate methods

#pragma mark - search bar delegate methods

#pragma mark - search updating delegate methods

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self setDataSource:_searchController.searchBar.text];
    [self.tableView reloadData];
}

#pragma mark - inherit methods

- (void)setup {
    [super setup];
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.delegate = self;
    _searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
    
    [_searchController.searchBar sizeToFit];
    
    [self.searchBar removeFromSuperview];
    self.searchBar = nil;
    
    self.tableView.tableHeaderView = _searchController.searchBar;
}

- (void)addressBookChanged:(NSNotification *)notif {
    [self setDataSource:_searchController.searchBar.text];
    [self.tableView reloadData];
}

@end
