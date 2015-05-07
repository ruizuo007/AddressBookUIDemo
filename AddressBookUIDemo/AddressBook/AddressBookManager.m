//
//  AddressBookManager.m
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14/11/25.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import "AddressBookManager.h"
#import "PeoplePickerNavigationController.h"
#import "NewPeoplePickerNavigationController.h"
#import "NNewPeoplePickerNavigationController.h"
#import "CoreDataManager.h"

static NSString *const msg_addressBookDenied = @"通信录访问拒绝";
static NSString *const msg_addressBookRestricted = @"通信录访问受限";
NSString *const ABMExternalAddressBookChangeNotification = @"ABMExternalAddressBookChangeNotification";
NSString *const ABMTongLianMemberUpdateNotification = @"ABMTongLianMemberUpdateNotification";

static AddressBookManager *instance = nil;

@interface AddressBookManager () <ABPeoplePickerNavigationControllerDelegate, UINavigationControllerDelegate> {
    
}

@property (nonatomic, strong) CoreDataManager *coreDataManager;
@property (nonatomic, copy) BOOL (^propertySelecting)(ABRecordRef, ABPropertyID, ABMultiValueIdentifier);

@end

@implementation AddressBookManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AddressBookManager alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _peoples = [NSMutableArray arrayWithCapacity:1];
        _indexes = [NSMutableArray arrayWithCapacity:1];
        _addressBook = [[RHAddressBook alloc] init];
        _coreDataManager = [[CoreDataManager alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookChanged:) name:RHAddressBookExternalChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - show system people picker

- (void)showSystemPeoplePickerFrom:(UIViewController *)fromVC delegate:(id<ABPeoplePickerNavigationControllerDelegate,UINavigationControllerDelegate>)delegate {
    ABPeoplePickerNavigationController *peoplePicker = [self peoplePickerWithDelegate:delegate];
    [fromVC presentViewController:peoplePicker animated:YES completion:nil];
}

- (void)showSystemPeoplePickerFrom:(UIViewController *)fromVC completion:(void (^)(void))completion withPropertySelecting:(BOOL (^)(ABRecordRef, ABPropertyID, ABMultiValueIdentifier))propertySelecting {
    ABPeoplePickerNavigationController *peoplePicker = [self peoplePickerWithDelegate:self];
    self.propertySelecting = propertySelecting;
    [fromVC presentViewController:peoplePicker animated:YES completion:nil];
}

#pragma mark - show custom people picker

- (void)showPeoplePickerFrom:(UIViewController *)fromVC completion:(void (^)(void))completion withPersonSelecting:(BOOL (^)(Person *))personSelecting {
    PeoplePickerNavigationController *peoplePicker = [[PeoplePickerNavigationController alloc] initWithNibName:nil bundle:nil];
    [self showPeoplePicker:peoplePicker from:fromVC completion:completion withPersonSelecting:personSelecting];
}

- (void)showNewPeoplePickerFrom:(UIViewController *)fromVC completion:(void (^)(void))completion withPersonSelecting:(BOOL (^)(Person *))personSelecting {
    BasePeoplePickerController *peoplePicker;
#if __IPHONE_8_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        peoplePicker = [[NNewPeoplePickerNavigationController alloc] initWithNibName:nil bundle:nil];
    } else {
        peoplePicker = [[NewPeoplePickerNavigationController alloc] initWithNibName:nil bundle:nil];
    }
#else 
    peoplePicker = [[NewPeoplePickerNavigationController alloc] initWithNibName:nil bundle:nil];
#endif
    [self showPeoplePicker:peoplePicker from:fromVC completion:completion withPersonSelecting:personSelecting];
}

#pragma mark - ABPersonViewControllerDelegate methods

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    if (self.propertySelecting) {
        self.propertySelecting(person, property, identifier);
    }
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    if (self.propertySelecting) {
        self.propertySelecting(person, property, identifier);
    }
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

#pragma mark - tool methods

- (NSString *)validatePhone:(NSString *)phone {
    if (phone.length <= 0) {
        return nil;
    }
    NSMutableString *mstring = [NSMutableString stringWithString:phone];
    [mstring replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, mstring.length)];
    [mstring replaceOccurrencesOfString:@"-" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, mstring.length)];
    [mstring replaceOccurrencesOfString:@"+" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, mstring.length)];
    [mstring replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, mstring.length)];
    [mstring replaceOccurrencesOfString:@"#" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, mstring.length)];
    //on ipad , ; ' "
    if (mstring.length > 11) {
        //去除国家码
        //匹配11位的连续数字字符串
        NSUInteger len = mstring.length - 11;
        [mstring replaceCharactersInRange:NSMakeRange(0, len) withString:@""];
    }
    if (mstring.length > 0) {
        NSString *regex = @"^1[3|4|5|8][0-9]\\d{8}$";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if ([predicate evaluateWithObject:mstring] == NO) {
            return nil;
        }
    };
    return mstring;
}

- (NSString *)validateEmail:(NSString *)email {
    if (email.length <= 0) {
        return nil;
    }
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    //@"^w+[-+.]w+)*@w+([-.]w+)*.w+([-.]w+)*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:email] == NO) {
        return nil;
    }
    return email;
}

- (NSArray *)availablePeoples {
    NSMutableArray *marray = [NSMutableArray arrayWithCapacity:1];
    NSMutableSet *mset = [NSMutableSet setWithCapacity:1];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"persistentedPeoples"]) {//首次安装系统通讯录未读取
        __weak __typeof(&*self) weakSelf = self;
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __strong __typeof(&*self) strongSelf = weakSelf;
            NSMutableArray *mmarray = [NSMutableArray arrayWithCapacity:1];
            [strongSelf readSystemPeoplesToArray:mmarray];
            for (NSDictionary *dic in mmarray) {
                Person *person = [[Person alloc] initWithEntity:[_coreDataManager entityWithName:kPersonTable ] insertIntoManagedObjectContext:_coreDataManager.managedObjectContext];
                [Person setPerson:person info:dic];
                [mset addObject:person.index];
                [marray addObject:person];
            }
            [strongSelf groupPeoples:marray index:mset];
        });
        dispatch_barrier_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
            __strong __typeof(&*self) strongSelf = weakSelf;
            [strongSelf persistentPeoples:marray];
        });
    } else {
        [self readPersistentedPeopleToArray:marray index:mset];
        [self groupPeoples:marray index:mset];
#if 1
        [self addressBookChanged:nil];
#endif
    }
    return _peoples;
}

- (void)addressBookChanged:(NSNotification *)notification {
    //
#if DEBUG
    NSLog(@"%@", @"通信录发生外部更改");
#endif
    __weak __typeof(&*self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong __typeof(&*self) strongSelf = weakSelf;
        NSMutableArray *sysPeoples = [NSMutableArray arrayWithCapacity:1];
        [strongSelf readSystemPeoplesToArray:sysPeoples];
        
        NSMutableArray *currPeoples = [NSMutableArray arrayWithCapacity:1];
        NSMutableSet *currIndexes = [NSMutableSet setWithArray:strongSelf.indexes];
        [strongSelf.peoples enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [currPeoples addObjectsFromArray:(NSArray *)obj];
        }];
        
        NSMutableArray *updatePeoples = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *info in sysPeoples) {
            BOOL needUpdate = YES;
            for (Person *p in currPeoples) {
                if ([Person person:p haveInfo:info]) {
                    needUpdate = NO;
                    break;
                }
            }
            if (needUpdate) {
                Person *person = [[Person alloc] initWithEntity:[_coreDataManager entityWithName:kPersonTable ] insertIntoManagedObjectContext:_coreDataManager.managedObjectContext];
                [Person setPerson:person info:info];
                [updatePeoples addObject:person];
                __block NSUInteger index = 0;
                if ([currIndexes containsObject:person.index]) {
                    [strongSelf.peoples enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        Person *pp = (Person *)[(NSArray *)obj firstObject];
                        if ([pp.index isEqualToString:person.index]) {
                            index = idx;
                            *stop = YES;
                        }
                    }];
                    NSMutableArray *marray = [NSMutableArray arrayWithArray:[strongSelf.peoples objectAtIndex:index]];
                    [marray addObject:person];
                    [strongSelf.peoples replaceObjectAtIndex:index withObject:marray];
                } else {
                    [currIndexes addObject:person.index];
                    [strongSelf.peoples enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        Person *pp = (Person *)[(NSArray *)obj firstObject];
                        if ([pp.index compare:person.index options:NSCaseInsensitiveSearch] == NSOrderedDescending) {
                            index = idx;
                            *stop = YES;
                        }
                    }];
                    [strongSelf.peoples insertObject:@[person] atIndex:index];
                }
            }
        }
        
        [strongSelf persistentPeoples:updatePeoples];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ABMExternalAddressBookChangeNotification object:nil userInfo:nil];
    });
}

- (NSArray *)filterPeopleWithSearchText:(NSString *)searchText {
#if DEBUG
    clock_t start_time = clock();
#endif
    NSString *trimedText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSArray *searchItems = nil;
    if (trimedText.length > 0) {
        searchItems = [trimedText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    NSMutableArray *andMatchPredicates = [NSMutableArray arrayWithCapacity:1];
    
    for (NSString *searchItem in searchItems) {
        
        NSMutableArray *orMatchPredicates = [NSMutableArray arrayWithCapacity:1];
        
        NSArray *keyPaths = @[kFullName, kPhone, kEmail];
        
        for (NSString *keyPath in keyPaths) {
            NSPredicate *predicate = [self predicateWithKeyPath:keyPath searchText:searchItem];
            [orMatchPredicates addObject:predicate];
        }
        
        if ([[PinYinUtil hanziOfString:searchItem] count] <= 0) {
            NSArray *keyPaths = @[kPinYinFullName];
            
            for (NSString *keyPath in keyPaths) {
                NSPredicate *predicate = [self predicateWithKeyPath:keyPath searchText:searchItem];
                [orMatchPredicates addObject:predicate];
            }
        }
        
        NSCompoundPredicate *orCompoundPredicate = (NSCompoundPredicate *)[NSCompoundPredicate orPredicateWithSubpredicates:orMatchPredicates];
        [andMatchPredicates addObject:orCompoundPredicate];
    }
    
    NSCompoundPredicate *andCompoundPredicate = (NSCompoundPredicate *)[NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    NSMutableArray *marray = [NSMutableArray arrayWithCapacity:1];
    [_peoples enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *array = [(NSArray *)obj filteredArrayUsingPredicate:andCompoundPredicate];
            if ([array count] > 0) {
                [marray addObject:array];
            }
        }
    }];
#if DEBUG
    clock_t end_time = clock();
    NSLog(@"搜索数据，共花费时间 [ %f ] 秒", (double)(end_time - start_time) / (double)CLOCKS_PER_SEC);
#endif
    return marray;
}

- (NSArray *)checkTongLianMember:(NSArray *)peoples {
    return nil;
}

#pragma mark - private methods

- (ABPeoplePickerNavigationController *)peoplePickerWithDelegate:(id<ABPeoplePickerNavigationControllerDelegate, UINavigationControllerDelegate>)delegate {
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.delegate = delegate;
    peoplePicker.peoplePickerDelegate = delegate;
    return peoplePicker;
}

- (void)showPeoplePicker:(BasePeoplePickerController *)peoplePicker from:(UIViewController *)fromVC completion:(void (^)(void))completion withPersonSelecting:(BOOL (^)(Person *))personSelecting {
    void (^select)(Person *person) = ^(Person *person) {
        if (personSelecting) {
            personSelecting(person);
        }
        [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    };
    peoplePicker.personSelecting = select;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:peoplePicker];
    [fromVC presentViewController:nav animated:YES completion:completion];
    if ([RHAddressBook authorizationStatus] == RHAuthorizationStatusNotDetermined) {
        [_addressBook requestAuthorizationWithCompletion:^(bool granted, NSError *error) {
            if (granted) {
                [peoplePicker addressBookChanged:nil];
            }
        }];
    } else if ([RHAddressBook authorizationStatus] == RHAuthorizationStatusDenied) {
        [[AlertManager sharedManager] alertMessage:msg_addressBookDenied viewController:peoplePicker];
    } else if ([RHAddressBook authorizationStatus] == RHAuthorizationStatusRestricted) {
        [[AlertManager sharedManager] alertMessage:msg_addressBookRestricted viewController:peoplePicker];
    }
}

- (NSPredicate *)predicateWithKeyPath:(NSString *)keyPath searchText:(NSString *)searchText {
    NSExpression *lexpression = [NSExpression expressionForKeyPath:keyPath];
    NSExpression *rexpression = [NSExpression expressionForConstantValue:searchText];
    NSPredicate *predicate = [NSComparisonPredicate
                              predicateWithLeftExpression:lexpression
                              rightExpression:rexpression
                              modifier:NSDirectPredicateModifier
                              type:NSContainsPredicateOperatorType
                              options:NSCaseInsensitivePredicateOption];
    return predicate;
}

//先以字典方式组织数据
- (void)readSystemPeoplesToArray:(NSMutableArray *)marray {
    if (!marray) {
        return;
    }
    [marray removeAllObjects];
#if DEBUG
    clock_t start_time = clock();
#endif
    NSArray *peoples = [_addressBook peopleOrderedByLastName];
#if DEBUG
    clock_t end_time = clock();
    NSLog(@"读取通讯录 [ %lu ] 条数据，共花费时间 [ %f ] 秒", (unsigned long)[peoples count], (double)(end_time - start_time) / (double)CLOCKS_PER_SEC);
#endif
#if DEBUG
    start_time = clock();
#endif
    for (NSUInteger i = 0; i < [peoples count]; i++) {
        RHPerson *rhperson = [peoples objectAtIndex:i];
        for (NSString *phone in [rhperson.phoneNumbers values]) {
            NSMutableDictionary *person = [Person infoOfRHPerson:rhperson];
            person[kPhone] = phone;
            [marray addObject:person];
        }
        for (NSString *email in [rhperson.emails values]) {
            NSMutableDictionary *person = [Person infoOfRHPerson:rhperson];
            person[kEmail] = email;
            [marray addObject:person];
        }
    }
#if DEBUG
    end_time = clock();
    NSLog(@"整理通讯录 [ %lu ] 条数据，共花费时间 [ %f ] 秒", (unsigned long)[marray count], (double)(end_time - start_time) / (double)CLOCKS_PER_SEC);
#endif
}

//以person对象组织数据
- (void)readPersistentedPeopleToArray:(NSMutableArray *)marray index:(NSMutableSet *)mset {
    if (!marray || !mset) {
        return;
    }
    [marray removeAllObjects];
    [mset removeAllObjects];
#if DEBUG
    clock_t start_time = clock();
#endif
    NSArray *peoples = [_coreDataManager selectAllDataInTable:kPersonTable];
    for (NSUInteger i = 0; i < [peoples count]; i++) {
        Person *person = [peoples objectAtIndex:i];
        [mset addObject:person.index];
        [marray addObject:person];
    }
#if DEBUG
    clock_t end_time = clock();
    NSLog(@"读取持久化通讯录 [ %lu ] 条数据，共花费时间 [ %f ] 秒", (unsigned long)[peoples count], (double)(end_time - start_time) / (double)CLOCKS_PER_SEC);
#endif
}

- (void)persistentPeoples:(NSArray *)peoples {
    __weak __typeof(&*self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([peoples count] <= 0) {
            return;
        }
#if DEBUG
        clock_t start_time = clock();
#endif
        __strong __typeof(&*self) strongSelf = weakSelf;
        BOOL ret = [strongSelf.coreDataManager insertData:peoples inTable:@"Peoples"];
        if (ret && ![[NSUserDefaults standardUserDefaults] objectForKey:@"persistentedPeoples"]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"persistentedPeoples"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
#if DEBUG
        clock_t end_time = clock();
        NSLog(@"持久化通讯录 [ %lu ] 条数据，共花费时间 [ %f ] 秒", (unsigned long)[peoples count], (double)(end_time - start_time) / (double)CLOCKS_PER_SEC);
#endif
    });
}

- (void)groupPeoples:(NSMutableArray *)peoples index:(NSMutableSet *)indexes {
#if DEBUG
    clock_t start_time = clock();
#endif
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    [_indexes setArray:[indexes sortedArrayUsingDescriptors:@[descriptor]]];
    NSMutableArray *group = [NSMutableArray arrayWithCapacity:1];
    [_indexes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSExpression *lhs = [NSExpression expressionForKeyPath:kIndex];
        NSExpression *rhs = [NSExpression expressionForConstantValue:(NSString *)obj];
        NSPredicate *predicate = [NSComparisonPredicate
                                  predicateWithLeftExpression:lhs
                                  rightExpression:rhs
                                  modifier:NSDirectPredicateModifier
                                  type:NSMatchesPredicateOperatorType
                                  options:NSCaseInsensitivePredicateOption];
        NSArray *array = [peoples filteredArrayUsingPredicate:predicate];
        [group addObject:array];
    }];
    _peoples = group;
#if DEBUG
    clock_t end_time = clock();
    NSLog(@"分组通讯录 [ %lu ] 条数据，共花费时间 [ %f ] 秒", (unsigned long)[peoples count], (double)(end_time - start_time) / (double)CLOCKS_PER_SEC);
#endif
}

@end
