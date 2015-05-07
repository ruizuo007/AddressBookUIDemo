//
//  PeoplePickerCell.h
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14/12/2.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeoplePickerCell : UITableViewCell

@property (nonatomic, strong, readonly) UILabel *lb_main;
@property (nonatomic, strong, readonly) UILabel *lb_sub;
@property (nonatomic, strong, readonly) UIImageView *imgv_member;

@property (nonatomic, strong, readonly) UIImageView *imgv_rightArrow;
@property (nonatomic, strong, readonly) UIImageView *imgv_backGround;

@property (nonatomic, strong, readonly) UIView *seperatorLine;

@end
