//
//  CoreDataManager.m
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14/12/4.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import "CoreDataManager.h"

@implementation CoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Save context

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
#if DEBUG
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
#endif
        }
    }
}

#pragma mark -

- (NSEntityDescription *)entityWithName:(NSString *)name {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:managedObjectContext];
    return entity;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AppDataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AppDataModel.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
#if DEBUG
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
#endif
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Tool methods

//插入数据
- (BOOL)insertData:(NSArray *)data inTable:(NSString *)table {
    NSManagedObjectContext *context = [self managedObjectContext];
    for (NSManagedObject *mo in data) {
        [context insertObject:mo];
    }
    [context processPendingChanges];
    NSError *error;
    BOOL ret = [context save:&error];
    if(!ret) {
#if DEBUG
        NSLog(@"不能保存数据: %@",[error localizedDescription]);
#endif
    }
    return ret;
}

//查询
- (NSArray *)selectData:(NSUInteger)pageSize andOffset:(NSUInteger)currentPage inTable:(NSString *)table withPredicate:(NSPredicate *)predicate {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setFetchLimit:pageSize];
    [fetchRequest setFetchOffset:currentPage];
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:table inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:1];
    if (!error && [fetchedObjects count] > 0) {
        for (NSManagedObjectContext *mo in fetchedObjects) {
            [results addObject:mo];
        }
    }
    return results;
}

- (NSArray *)selectData:(NSUInteger)pageSize andOffset:(NSUInteger)currentPage inTable:(NSString *)table {
    return [self selectData:pageSize andOffset:currentPage inTable:table withPredicate:nil];
}

- (NSArray *)selectAllDataInTable:(NSString *)table {
    NSUInteger currentPage = 0;
    NSUInteger pageSize = 50;
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:1];
    NSArray *page = nil;
    do {
        page = [self selectData:pageSize andOffset:currentPage inTable:table];
        if ([page count] > 0) {
            [results addObjectsFromArray:page];
        }
        currentPage += pageSize;
    } while ([page count] > 0);
    return results;
}

//删除
-(void)deleteDataInTable:(NSString *)table withPredicate:(NSPredicate *)predicate {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:table inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setIncludesPropertyValues:NO];
    [request setEntity:entity];
    if (predicate) {
        [request setPredicate:predicate];
    }
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
    
    if (!error && [fetchedObjects count] > 0) {
        for (NSManagedObject *mo in fetchedObjects) {
            [context deleteObject:mo];
        }
        if (![context save:&error]) {
#if DEBUG
            NSLog(@"error:%@",error);
#endif
        }
    }
}

- (void)deleteAllDataInTable:(NSString *)table {
    [self deleteDataInTable:table withPredicate:nil];
}

//更新
- (void)updateData:(NSString *)attribute toValue:(id)value inTable:(NSString *)table withPredicate:(NSPredicate *)predicate {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    //首先你需要建立一个request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:table inManagedObjectContext:context]];
    [request setPredicate:predicate];
    //这里相当于sqlite中的查询条件，具体格式参考苹果文档
    //https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Predicates/Articles/pCreating.html
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    //这里获取到的是一个数组，你需要取出你要更新的那个obj
    if (!error && [results count] > 0) {
        for (NSManagedObject *mo in results) {
            [mo setValue:value forKey:attribute];
        }
        //保存
        if ([context save:&error]) {
#if DEBUG
            //更新成功
            NSLog(@"更新成功");
#endif
        } else {
#if DEBUG
            //更新失败
            NSLog(@"更新失败");
#endif
        }
    }
}

@end
