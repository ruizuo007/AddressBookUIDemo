//
//  CoreDataManager.h
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14/12/4.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSEntityDescription *)entityWithName:(NSString *)name;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

#pragma mark - 插入数据 

//插入数据,在某个表中,
- (BOOL)insertData:(NSArray *)data inTable:(NSString *)table;

#pragma mark - 查询数据

//查询
- (NSArray *)selectData:(NSUInteger)pageSize
              andOffset:(NSUInteger)currentPage
                inTable:(NSString *)table
          withPredicate:(NSPredicate *)predicate;
- (NSArray *)selectData:(NSUInteger)pageSize andOffset:(NSUInteger)currentPage inTable:(NSString *)table;
- (NSArray *)selectAllDataInTable:(NSString *)table;

#pragma mark - 删除数据

//删除
- (void)deleteDataInTable:(NSString *)table withPredicate:(NSPredicate *)predicate;
- (void)deleteAllDataInTable:(NSString *)table;

#pragma mark - 更新数据

//更新
- (void)updateData:(NSString *)attribute
           toValue:(id)value
           inTable:(NSString *)table
     withPredicate:(NSPredicate *)predicate;

@end

