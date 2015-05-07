//
//  AddressBookUIDemoTests.m
//  AddressBookUIDemoTests
//
//  Created by allinpay-shenlong on 14-10-30.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "AddressBook.h"

#import "PinYinUtil.h"

#import "CoreDataManager.h"

@interface AddressBookUIDemoTests : XCTestCase

@end

@implementation AddressBookUIDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
#if 0
        // Put the code you want to measure the time of here.
        RHAddressBook *addressBook = [[RHAddressBook alloc] init];
        RHSource *source = addressBook.defaultSource;
        long long phoneStart = 18523013433;
        for (NSUInteger i = 0; i < 800; i++) {
            RHPerson *person = [RHPerson newPersonInSource:source];
            person.firstName = [NSString stringWithFormat:@"%4d", i];
            person.lastName = @"张三";
            RHMutableMultiValue *phoneNumbers = [[RHMutableMultiValue alloc] initWithType:kABPersonPhoneProperty];
            [phoneNumbers addValue:@(phoneStart + i) withLabel:@"phone"];
            person.phoneNumbers = phoneNumbers;
            [addressBook addPerson:person];
        }
        [addressBook save];
#endif
    }];
}

- (void)testPinYin {
    NSString *firstLetter = [PinYinUtil firstLetterOfHanzi:@"中华鲟"];
    firstLetter = [PinYinUtil firstLetterOfHanzi:@"行人"];
    firstLetter = [PinYinUtil firstLetterOfHanzi:@"zhangsan"];
    firstLetter = [PinYinUtil firstLetterOfHanzi:@"123567"];
}

- (void)testCoreData {
    CoreDataManager *cdm = [[CoreDataManager alloc] init];
    
#if 0
    NSArray *data = @[@{@"fullName":@"测试数据1",
                        @"phone":@"13951683006",
                        @"index":@"C",
                        @"tongLianMember":@(YES),
                        @"pinYinFullName":@"ceshishuju1"},
                      @{@"fullName":@"测试数据2",
                        @"email":@"bb@gmail.com",
                        @"index":@"C",
                        @"tongLianMember":@(NO),
                        @"pinYinFullName":@"ceshishuju2"}];
    [cdm insertCoreData:data inTable:@"Peoples"];
#endif
}

@end
