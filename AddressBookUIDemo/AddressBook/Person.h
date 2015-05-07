//
//  Person.h
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14/12/3.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PinYinUtil.h"

@class RHPerson;

extern NSString *const kPersonTable;//存储数据的表名称
extern NSString *const kFullName;
extern NSString *const kPhone;
extern NSString *const kEmail;
extern NSString *const kPinYinFullName;
extern NSString *const kIndex;
extern NSString *const kTongLianMember;
extern NSString *const kLastName;
extern NSString *const kMiddleName;
extern NSString *const kFirstName;

@interface Person : NSManagedObject

//排序索引 [A,B... ...Z,#]
@property (nonatomic, strong) NSString *index;

@property (nonatomic, strong) NSString *fullName;

@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *middleName;
@property (nonatomic, strong) NSString *firstName;

//二者存一
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *email;
//通联会员
@property (nonatomic, strong) NSNumber *tongLianMember;

@property (nonatomic, strong) NSString* pinYinFullName;

//(姓名, 手机号 | 邮箱) 或者 (手机号 | 邮箱, 空)
+ (NSString *)showingPropertyOfPerson:(Person *)person;
+ (NSString *)subShowingPropertyOfPerson:(Person *)person;
+ (NSString *)indexOfPerson:(Person *)person;
+ (BOOL)person:(Person *)person haveInfo:(NSDictionary *)info;
+ (void)setPerson:(Person *)person info:(NSDictionary *)info;
+ (NSMutableDictionary *)infoOfRHPerson:(RHPerson *)rhperson;

@end
