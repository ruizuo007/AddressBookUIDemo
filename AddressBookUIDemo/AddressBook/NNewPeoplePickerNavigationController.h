//
//  NNewPeoplePickerNavigationController.h
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14/12/17.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasePeoplePickerController.h"

@interface NNewPeoplePickerNavigationController : BasePeoplePickerController <UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong, readonly) UISearchController *searchController;

@end
