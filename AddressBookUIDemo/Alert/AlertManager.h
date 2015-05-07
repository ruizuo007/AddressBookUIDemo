//
//  AlertManager.h
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14/11/26.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AlertManager : NSObject

+ (instancetype)sharedManager;

- (void)alertMessage:(NSString *)message viewController:(UIViewController *)viewController;
- (void)dismissAlertInVC:(UIViewController *)viewController;
- (void)dismissAlertInView:(UIView *)view;
- (void)dismissAlert;

@end
