//
//  AddressBookManager.h
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14/11/25.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "AddressBook.h"
#import "PinYinUtil.h"
#import "AlertManager.h"
#import "Person.h"

#define DIV255(x) (((float)x) / 255.0)

extern NSString *const ABMExternalAddressBookChangeNotification;
extern NSString *const ABMTongLianMemberUpdateNotification;

@interface AddressBookManager : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *peoples;
@property (nonatomic, strong, readonly) NSMutableArray *indexes;
@property (nonatomic, strong, readonly) RHAddressBook *addressBook;

+ (instancetype)sharedManager;

//系统

- (void)showSystemPeoplePickerFrom:(UIViewController *)fromVC
                          delegate:(id<ABPeoplePickerNavigationControllerDelegate,
                                    UINavigationControllerDelegate>)delegate;

- (void)showSystemPeoplePickerFrom:(UIViewController *)fromVC
                        completion:(void (^)(void))completion
             withPropertySelecting:(BOOL (^)(ABRecordRef person,
                                             ABPropertyID propertyId,
                                             ABMultiValueIdentifier identifier))propertySelecting;

//自定义

- (void)showPeoplePickerFrom:(UIViewController *)fromVC
                  completion:(void (^)(void))completion
         withPersonSelecting:(BOOL (^)(Person *person))personSelecting;

- (void)showNewPeoplePickerFrom:(UIViewController *)fromVC
                     completion:(void (^)(void))completion
            withPersonSelecting:(BOOL (^)(Person *person))personSelecting;

//检查手机号和邮箱的合法性

- (NSString *)validatePhone:(NSString *)phone;
- (NSString *)validateEmail:(NSString *)email;

//读取系统通讯录/本地归档数据内容

- (NSArray *)availablePeoples;

//接收外部通信录变更消息

- (void)addressBookChanged:(NSNotification*)notification;

//根据搜索关键字过滤联系人

- (NSArray *)filterPeopleWithSearchText:(NSString *)searchText;

//网络请求，更新会员状态

- (NSArray *)checkTongLianMember:(NSArray *)peoples;

@end
