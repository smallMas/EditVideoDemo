//
//  AppDelegate.m
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/10.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import "AppDelegate.h"
#import "FSCameraViewController.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    
//    [self test];
    return YES;
}

- (void)test {
    NSDictionary *d = @{@"msg":@"ajaaaaaa",@"sender":@"12355"};
    NSString *json = [self jsonStringWithDict:d];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{@"name":@"fansj",@"url":@"https://www.baidu.com"}];
    [dict setValue:json forKey:@"json"];
    NSLog(@"dict >>> %@",dict);
    NSLog(@"json >>>> %@",dict[@"json"]);
    NSString *str = [self jsonStringWithDict:dict];
    NSLog(@"str >>>> %@",str);
    
//    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
//    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    NSLog(@"1str >>>> %@",str);
//    NSLog(@"1md5 >>>> %@",[str MD5_32]);
//
//    NSMutableString *responseString = [NSMutableString stringWithString:str];
//    NSString *character = nil;
//        for (int i = 0; i < responseString.length; i ++) {
//            character = [responseString substringWithRange:NSMakeRange(i, 1)];
//            if ([character isEqualToString:@"\r"])
//                 [responseString deleteCharactersInRange:NSMakeRange(i, 1)];
//    }
//    str = responseString;
//    NSLog(@"2str >>>> %@",str);
//    NSLog(@"2md5 >>>> %@",[str MD5_32]);
//
//    NSDictionary *tmpDict = [self dictWithJsonString:str];
//    NSLog(@"tmpDict >>> %@",tmpDict);
//
//    if (tmpDict) {
//        NSString *str2 = [self jsonStringWithDict:tmpDict];
//        NSLog(@"str2 >>>> %@",str2);
//    }
}

- (NSString *)jsonStringWithDict:(NSDictionary *)dict {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (id)dictWithJsonString:(NSString *)string {
    NSError *error;
    return [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
}

#pragma mark - UISceneSession lifecycle


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"FSGPUImage"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
