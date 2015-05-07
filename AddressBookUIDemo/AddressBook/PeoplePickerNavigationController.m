//
//  PeoplePickerNavigationController.m
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14/11/26.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import "PeoplePickerNavigationController.h"
#import "AddressBookManager.h"
#import "PeoplePickerCell.h"

@interface PeoplePickerNavigationController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    
}

@end

@implementation PeoplePickerNavigationController

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect frame = self.view.frame;
    CGFloat y = self.searchBar.frame.size.height;
    CGFloat h = frame.size.height - self.searchBar.frame.size.height;
    if (self.navigationController && self.navigationController.navigationBarHidden) {
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        y += statusBarFrame.size.height;
        h -= statusBarFrame.size.height;
    }
    self.tableView.frame = CGRectMake(0, y, frame.size.width, h);
}

#pragma mark - search bar delegate methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    BOOL ret = [self shouldStartSearch];
    if (!ret) {
        [self adjustViewFrameForStartSearch:YES];
    }
    return ret;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self setDataSource:searchText];
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if (self.navigationController) {
        [self adjustViewFrameForStartSearch:NO];
    }
    if ([searchBar.text length] > 0) {
        searchBar.text = nil;
        [self searchBar:searchBar textDidChange:searchBar.text];
    }
    [searchBar resignFirstResponder];
}

#pragma mark -  private methods

- (void)setup {
    [super setup];
    
    if ([self shouldStartSearch]) {
        [self.searchBar setShowsCancelButton:YES animated:NO];
    }
}

- (void)custom {
    [super custom];
    
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
}

- (BOOL)shouldStartSearch {
    if (self.navigationController && !self.navigationController.navigationBarHidden) {
        return NO;
    }
    return YES;
}

- (void)adjustViewFrameForStartSearch:(BOOL)startSearch {
    if (self.navigationController) {
        self.navigationController.navigationBarHidden = startSearch;
        [self.searchBar setShowsCancelButton:startSearch animated:YES];
        if (startSearch) {
            [self.searchBar becomeFirstResponder];
        }
        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 6.0) {
            CGFloat dy = 20;
            if (!startSearch) {
                dy *= -1;
            }
            CGRect frame = self.searchBar.frame;
            frame.origin.y += dy;
            self.searchBar.frame = frame;
        }
    }
}

@end
