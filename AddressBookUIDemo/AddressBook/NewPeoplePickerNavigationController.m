//
//  NewPeoplePickerNavigationController.m
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14/12/17.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import "NewPeoplePickerNavigationController.h"

@interface NewPeoplePickerNavigationController ()

@end

@implementation NewPeoplePickerNavigationController

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect f1 = self.searchBar.frame;
    CGRect f2 = self.tableView.frame;
    f2.origin.y = f1.size.height;
    f2.size.height  -= f2.origin.y;
    self.tableView.frame = f2;
}

#pragma mark - search display controller delegate methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self setDataSource:self.searchDisplayController.searchBar.text];
    [self.tableView reloadData];
    return YES;
}

#pragma mark - search bar delegate methods

#pragma mark - inherit methods

- (void)setup {
    [super setup];
    
    _searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    _searchController.delegate = self;
    _searchController.searchResultsDataSource = self;
    _searchController.searchResultsDelegate = self;
}

- (void)custom {
    [super custom];
    
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
}

- (void)setDataSource:(NSString *)searchText {
    if (searchText.length <= 0) {
        _peoples = [[AddressBookManager sharedManager] peoples];
    } else {
        _peoples = [[AddressBookManager sharedManager] filterPeopleWithSearchText:searchText];
    }
}

- (void)addressBookChanged:(NSNotification *)notif {
    [self setDataSource:self.searchDisplayController.searchBar.text];
    [self.tableView reloadData];
}

@end
