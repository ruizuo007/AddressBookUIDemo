//
//  ViewController.m
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14-10-30.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import "ViewController.h"
#import "ADBUIViewController.h"
#import "ADBViewController.h"
#import "AddressBookManager.h"
#import "AlertManager.h"

@interface ViewController () <UITextViewDelegate, ABPeoplePickerNavigationControllerDelegate, UINavigationControllerDelegate, UIWebViewDelegate>

@property (nonatomic, strong) UIButton *system;
@property (nonatomic, strong) UIButton *custom;
@property (nonatomic, strong) UIButton *custom2;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UIWebView *wv_local;
@property (nonatomic, strong) IBOutlet UIWebView *wv_remote;
@property (nonatomic, strong) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    _system = [self getButton:@"系统"];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:_system];
    _custom = [self getButton:@"自定义"];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:_custom];
    _custom2 = [self getButton:@"自定义2"];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithCustomView:_custom2];
    [self.navigationItem setRightBarButtonItems:@[item3, item2, item1]];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mobile" ofType:@"html" inDirectory:@"web"];
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [_wv_local loadRequest:req];
    
#define TAG 99
    
#if TAG == 0
    [self add];
#elif TAG == 1
    [self delete];
#endif

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *scheme = [request.URL scheme];
    NSString *query = [request.URL query];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSArray *queryElements = [query componentsSeparatedByString:@"&"];
    for (NSString *element in queryElements) {
        NSArray *keyVal = [element componentsSeparatedByString:@"="];
        if (keyVal.count > 0) {
            NSString *variableKey = [keyVal objectAtIndex:0];
            NSString *value = (keyVal.count == 2) ? [keyVal lastObject] : @"";
            value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [dic setObject:value forKey:variableKey];
        }
    }
    if ([scheme isEqualToString:@"contact"]) {
        if ([[dic objectForKey:@"action"] isEqualToString:@"transferAccounts"]) {
            [self onShow:_custom];
        } else if ([[dic objectForKey:@"action"] isEqualToString:@"mobileRecharge"]) {
            [self onShow:_system];
        }
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

#pragma mark - 

- (UIButton *)getButton:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onShow:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    UINavigationBar *bar = self.navigationController.navigationBar;
    CGFloat h = bar.frame.size.height;
    CGRect frame = button.frame;
    frame.size.height = h - 6 * 2;
    button.frame = frame;
    return button;
}

- (void)onShow:(id)sender {
    if (sender == _system) {
//        ADBUIViewController *controller = [[ADBUIViewController alloc] initWithNibName:nil bundle:nil];
//        controller.delegate = self;
//        controller.peoplePickerDelegate = self;
//        [self presentViewController:controller animated:YES completion:nil];
        __weak __typeof(&*self) weakSelf = self;
        [[AddressBookManager sharedManager] showSystemPeoplePickerFrom:self completion:nil withPropertySelecting:^BOOL(ABRecordRef person, ABPropertyID propertyId, ABMultiValueIdentifier identifier) {
            __strong __typeof(&*self) strongSelf = weakSelf;
            [strongSelf displayPersonInfo:person];
            if (propertyId != kABPersonPhoneProperty) {
                [[AlertManager sharedManager] alertMessage:@"手机号不正确" viewController:self];
                return YES;
            }
            ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            CFIndex index = ABMultiValueGetIndexForIdentifier(phones, identifier);
            NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, index);
            phone = [[AddressBookManager sharedManager] validatePhone:phone];
            if (phone.length <= 0) {
                [[AlertManager sharedManager] alertMessage:@"手机号不正确" viewController:self];
                return YES;
            }
            [strongSelf.wv_local stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"setText('%@')", phone]];
            [strongSelf.textField setText:phone];
            return NO;
        }];
    } else if (sender == _custom) {
//        ADBViewController *controller = [[ADBViewController alloc] initWithNibName:nil bundle:nil];
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
//        [self presentViewController:nav animated:YES completion:nil];
        __weak __typeof(&*self) weakSelf = self;
        [[AddressBookManager sharedManager] showPeoplePickerFrom:self completion:nil withPersonSelecting:^BOOL(Person *person) {
            __strong __typeof(&*self) strongSelf = weakSelf;
            NSString *text = nil;
            if (person.phone) {
                text = [[AddressBookManager sharedManager] validatePhone:person.phone];
                if (text.length <= 0) {
                    [[AlertManager sharedManager] alertMessage:@"手机号不正确" viewController:self];
                    return YES;
                }
            } else if (person.email) {
                text = [[AddressBookManager sharedManager] validateEmail:person.email];
                if (text.length <= 0) {
                    [[AlertManager sharedManager] alertMessage:@"邮箱不正确" viewController:self];
                    return YES;
                }
            }
            [strongSelf.wv_local stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"setText('%@')", text]];
            [strongSelf.textField setText:text];
            return YES;
        }];
    } else if (sender == _custom2) {
        __weak __typeof(&*self) weakSelf = self;
        [[AddressBookManager sharedManager] showNewPeoplePickerFrom:self completion:nil withPersonSelecting:^BOOL(Person *person) {
            __strong __typeof(&*self) strongSelf = weakSelf;
            NSString *text = nil;
            if (person.phone) {
                text = [[AddressBookManager sharedManager] validatePhone:person.phone];
                if (text.length <= 0) {
                    [[AlertManager sharedManager] alertMessage:@"手机号不正确" viewController:self];
                    return YES;
                }
            } else if (person.email) {
                text = [[AddressBookManager sharedManager] validateEmail:person.email];
                if (text.length <= 0) {
                    [[AlertManager sharedManager] alertMessage:@"邮箱不正确" viewController:self];
                    return YES;
                }
            }
            [strongSelf.wv_local stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"setText('%@')", text]];
            [strongSelf.textField setText:text];
            return YES;
        }];
    }
}

#pragma mark -

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//>= 8.0
//- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person {
//    [self displayPersonView:person];
//    [self displayPersonInfo:person];
//}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
}

//< 8.0

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    return YES;
}

#pragma mark -

- (void)displayPersonView:(ABRecordRef)person {
    __weak __typeof(&*self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong __typeof(&*self) strongSelf = weakSelf;
        ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
        personViewController.displayedPerson = person;
        [strongSelf presentViewController:personViewController animated:YES completion:nil];
    });
}

- (void)displayPersonInfo:(ABRecordRef)person {
    NSMutableString *personInfo = [NSMutableString string];
    ABRecordID recordId = ABRecordGetRecordID(person);
    [personInfo appendString:@"记录编号:"];
    [personInfo appendFormat:@"%d", recordId];
    [personInfo appendString:@"\n"];
    ABRecordType recordType = ABRecordGetRecordType(person);
    NSString *recordTypeStr;
    if (recordType == kABPersonType) {
        recordTypeStr = @"个人";
    } else if (recordType == kABGroupType) {
        recordTypeStr = @"群组";
    } else if (recordType == kABSourceType) {
        recordTypeStr = @"资源";
    } else {
        recordTypeStr = @"[unknown]";
    }
    [personInfo appendString:@"记录类型:"];
    [personInfo appendString:recordTypeStr];
    [personInfo appendString:@"\n"];
    [personInfo appendString:@"姓名:"];
    NSString *fName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *mName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonMiddleNamePhoneticProperty);
    NSString *lName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (lName) {
        [personInfo appendString:lName];
    }
    if (mName) {
        [personInfo appendString:mName];
    }
    if (fName) {
        [personInfo appendString:fName];
    }
    if (fName == nil && lName == nil) {
        [personInfo appendString:@"[none]"];
    }
    [personInfo appendString:@"\n"];
    [personInfo appendString:@"手机号:"];
    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFIndex count = ABMultiValueGetCount(phones);
    if (count > 0) {
        for (CFIndex index = 0; index < count; ++index) {
            NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, index);
            if (phone) {
                [personInfo appendString:@"\n"];
                [personInfo appendString:phone];
            }
        }
    } else {
        [personInfo appendString:@"[none]"];
    }
    [personInfo appendString:@"\n"];
    [personInfo appendString:@"邮箱"];
    ABMultiValueRef mails = ABRecordCopyValue(person, kABPersonEmailProperty);
    count = ABMultiValueGetCount(mails);
    if (count > 0) {
        for (CFIndex index = 0; index < count; ++index) {
            NSString *mail = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(mails, index);
            if (mail) {
                [personInfo appendString:@"\n"];
                [personInfo appendString:mail];
            }
        }
    } else {
        [personInfo appendString:@"[none]"];
    }
    [personInfo appendString:@"\n"];
    [_textView setText:personInfo];
}

- (void)add {
    //2014-12-02 14:37:42.703 AddressBookUIDemo[570:707] 写入通讯录 [ 800 ] 条数据，共花费时间 [ 12.248916 ] 秒
#if DEBUG
    clock_t start_time = clock();
#endif
    NSArray *lastNames = [NSArray arrayWithObjects:@"",@"阿凡达",@"芭芭拉",@"曹操",@"典韦",@"额",@"范海辛",@"哥伦布",@"华山",@"ibooks",@"jack",@"卡哇伊",@"拉布拉多",@"mother",@"难啊",@"oppo",@"品牌",@"quick",@"日啊",@"stop",@"天哪",@"uname",@"virus",@"王",@"夏",@"杨",@"张", nil];
    RHAddressBook *addressBook = [[RHAddressBook alloc] init];
    long long phoneStart = 18523013433;
    NSUInteger i;
    for (i = 0; i < 400; i++) {
        RHPerson *person = [addressBook newPersonInDefaultSource];
        NSInteger index = arc4random() % 27; //以分为计算单位
        if (index != 0) {
            person.firstName = [NSString stringWithFormat:@"%4d", i];
        }
        person.lastName = [lastNames objectAtIndex:index];
        RHMutableMultiValue *phoneNumbers = [[RHMutableMultiValue alloc] initWithType:kABPersonPhoneProperty];
        [phoneNumbers addValue:[NSString stringWithFormat:@"%lld", (phoneStart + i)] withLabel:@"phone"];
        person.phoneNumbers = phoneNumbers;
        [addressBook addPerson:person];
    }
    [addressBook save];
#if DEBUG
    clock_t end_time = clock();
    NSLog(@"写入通讯录 [ %d ] 条数据，共花费时间 [ %f ] 秒", i, (double)(end_time - start_time) / (double)CLOCKS_PER_SEC);
#endif
}

- (void)delete {
#if DEBUG
    clock_t start_time = clock();
#endif
    RHAddressBook *addressBook = [[RHAddressBook alloc] init];
    NSArray *groups = [addressBook groups];
    for (RHGroup *group in groups) {
        [addressBook removeGroup:group];
    }
    [addressBook save];
#if DEBUG
    clock_t end_time = clock();
    NSLog(@"删除通讯录数据，共花费时间 [ %f ] 秒", (double)(end_time - start_time) / (double)CLOCKS_PER_SEC);
#endif
}

@end
