//
//  AppDelegate.h
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/10.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;

@property (strong, nonatomic) UIWindow *window;

- (void)saveContext;


@end

