//
//  AlertManager.m
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14/11/26.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import "AlertManager.h"

static AlertManager *instance = nil;

@implementation AlertManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AlertManager alloc] init];
    });
    return instance;
}

- (void)alertMessage:(NSString *)message viewController:(UIViewController *)viewController {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
#if __IPHONE_8_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:cancel];
            [viewController presentViewController:alertController animated:YES completion:nil];
            return;
        }
#endif
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    });
}

- (void)dismissAlertInVC:(UIViewController *)viewController {
    UIViewController *vc = (UIViewController *)[viewController presentedViewController];
    if ([vc isKindOfClass:[UIAlertController class]]) {
        [vc dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)dismissAlertInView:(UIView *)view {
    if ([view isKindOfClass:[UIAlertView class]]) {
        UIAlertView *alertView = (UIAlertView *)view;
        [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:NO];
    } else if ([view isKindOfClass:[UIActionSheet class]]) {
        UIActionSheet *alertView = (UIActionSheet *)view;
        [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:NO];
    } else {
        NSArray *subviews = [view subviews];
        for (UIView *subview in subviews) {
            [self dismissAlertInView:subview];
        }
    }
}

- (void)dismissAlert {
    UIWindow *keyWindow=[UIApplication sharedApplication].keyWindow;
    if([keyWindow isKindOfClass:NSClassFromString(@"_UIAlertOverlayWindow")]) {
        NSArray *subViews = [keyWindow subviews];
        for (UIView *subview in subViews) {
            [self dismissAlertInView:subview];
        }
    }
}

@end
