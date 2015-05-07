//
//  Person.m
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14/12/3.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import "Person.h"
#import "RHPerson.h"

NSString *const kPersonTable = @"Peoples";//存储数据的表名称
NSString *const kFullName = @"fullName";
NSString *const kPhone = @"phone";
NSString *const kEmail = @"email";
NSString *const kPinYinFullName = @"pinYinFullName";
NSString *const kIndex = @"index";
NSString *const kTongLianMember = @"tongLianMember";
NSString *const kLastName = @"lastName";
NSString *const kMiddleName = @"middleName";
NSString *const kFirstName = @"firstName";

@implementation Person

@dynamic fullName, phone, email, index, tongLianMember, pinYinFullName, lastName, middleName, firstName;

+ (NSString *)showingPropertyOfPerson:(Person *)person {
    if (person.fullName != nil) {
        return person.fullName;
    }
    if (person.phone != nil) {
        return person.phone;
    }
    if (person.email != nil) {
        return person.email;
    }
    return nil;
}

+ (NSString *)subShowingPropertyOfPerson:(Person *)person {
    if (person.fullName != nil) {
        if (person.phone != nil) {
            return person.phone;
        } else if (person.email != nil) {
            return person.email;
        }
    }
    return nil;
}

+ (NSString *)indexOfPerson:(Person *)person {
    NSString *firstLetter = @"";
    if (person.lastName != nil) {
        firstLetter = [PinYinUtil firstLetterOfHanzi:person.lastName];
    } else if (person.middleName != nil) {
        firstLetter = [PinYinUtil firstLetterOfHanzi:person.middleName];
    } else if (person.firstName != nil) {
        firstLetter = [PinYinUtil firstLetterOfHanzi:person.firstName];
    } else if (person.fullName != nil) {
        firstLetter = [PinYinUtil firstLetterOfHanzi:person.fullName];
    }else if (person.phone != nil) {
        firstLetter = [PinYinUtil firstLetterOfHanzi:person.phone];
    } else if (person.email != nil) {
        firstLetter = [PinYinUtil firstLetterOfHanzi:person.email];
    }
    if (isalpha([firstLetter characterAtIndex:0]) == 0) {
        firstLetter = @"#";
    }
    return [firstLetter uppercaseString];
}

+ (BOOL)person:(Person *)person haveInfo:(NSDictionary *)info {
    //不确定是否为nil
    BOOL ret = YES;
    if (person.phone || info[kPhone]) {
        ret = (ret && [person.phone isEqualToString:info[kPhone]]);
    }
    if (person.email || info[kEmail]) {
        ret = (ret && [person.email isEqualToString:info[kEmail]]);
    }
    if (person.fullName || info[kFullName]) {
        ret = (ret && [person.fullName isEqualToString:info[kFullName]]);
    }
    return ret;
}

+ (void)setPerson:(Person *)person info:(NSDictionary *)info {
    person.fullName = info[kFullName];
    person.lastName = info[kLastName];
    person.middleName = info[kMiddleName];
    person.firstName = info[kFirstName];
    person.phone = info[kPhone];
    person.email = info[kEmail];
    person.index = [Person indexOfPerson:person];
    person.pinYinFullName = [PinYinUtil pinyinOfHanzi:person.fullName];
}

+ (NSMutableDictionary *)infoOfRHPerson:(RHPerson *)rhperson {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:1];
    if (rhperson.name) {
        info[kFullName] = rhperson.name;
    }
    if (rhperson.lastName) {
        info[kLastName] = rhperson.lastName;
    }
    if (rhperson.middleName) {
        info[kMiddleName] = rhperson.middleName;
    }
    if (rhperson.firstName) {
        info[kFirstName] = rhperson.firstName;
    }
    return info;
}

@end
