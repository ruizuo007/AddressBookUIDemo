//
//  ManagedObjectDelegate.h
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14/12/5.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#ifndef AddressBookUIDemo_ManagedObjectDelegate_h
#define AddressBookUIDemo_ManagedObjectDelegate_h

#import <Foundation/Foundation.h>

@protocol ManagedObjectDelegate <NSObject>

//将对象要持久化存储的信息转化为字典
- (NSDictionary *)persistentInfo;

@end

#endif
