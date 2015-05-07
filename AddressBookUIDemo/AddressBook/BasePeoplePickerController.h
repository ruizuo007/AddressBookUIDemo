//
//  BasePeoplePickerController.h
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14/12/19.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressBookManager.h"
#import "PeoplePickerCell.h"

@interface BasePeoplePickerController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    @public
     NSArray *_peoples;//当前列表中展示的数据,搜索前搜索后
}

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) void (^personSelecting)(Person *person);

//初始化search+table视图
- (void)setup;
//定制视图等属性
- (void)custom;
//设置显示联系人的数据源
- (void)setDataSource:(NSString *)searchText;
//从存储读取
- (void)readAvailablePeoples;
//响应外部通信录更改
- (void)addressBookChanged:(NSNotification*)notification;

@end
