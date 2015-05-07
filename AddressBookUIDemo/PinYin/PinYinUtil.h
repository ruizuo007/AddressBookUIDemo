//
//  PinYin.h
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14/12/1.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PinYin4Objc.h"

#ifndef __PINYIN_FIRST_LETTER__

#define __PINYIN_FIRST_LETTER__
#include "pinyin.h"

#endif

@interface PinYinUtil : NSObject

+ (NSString *)firstLetterOfHanzi:(NSString *)hanzi;
+ (NSString *)pinyinOfHanzi:(NSString *)hanzi;
+ (NSArray *)hanziOfString:(NSString *)string;

@end
