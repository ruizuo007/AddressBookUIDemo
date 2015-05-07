//
//  PinYin.m
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14/12/1.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import "PinYinUtil.h"

@implementation PinYinUtil

+ (NSString *)firstLetterOfHanzi:(NSString *)hanzi {
    if (hanzi.length <= 0) {
        return nil;
    }
    unichar firstLetter = pinyinFirstLetter([hanzi characterAtIndex:0]);
    NSString *firstLetterText = [NSString stringWithCharacters:&firstLetter length:1];

    return firstLetterText;
}

//多音字...
+ (NSString *)pinyinOfHanzi:(NSString *)hanzi {
    if (hanzi.length <= 0) {
        return nil;
    }
    HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];
    
    NSString *pinyinText = [PinyinHelper toHanyuPinyinStringWithNSString:hanzi withHanyuPinyinOutputFormat:outputFormat withNSString:@""];

    return pinyinText;
}

//提取字符串中的汉字
+ (NSArray *)hanziOfString:(NSString *)string {
    NSString *regex = @"[\u4E00-\u9FFF]+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    NSMutableArray *marray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < string.length; i++) {
        [marray addObject:[string substringWithRange:NSMakeRange(i, 1)]];
    }
    return [marray filteredArrayUsingPredicate:predicate];
}

@end
