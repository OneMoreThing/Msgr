//
//  MsgrAppDelegate.m
//  Msgr
//
//  Created by Christopher Baltzer on 11-03-23.
//  Copyright 2011 Christopher Baltzer. All rights reserved.
//

#import "MsgrAppDelegate.h"

@implementation MsgrAppDelegate

static MsgrAppDelegate* _delegate;

@synthesize window=_window;
@synthesize navigationController=_navigationController;
@synthesize ms;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _delegate = self;
    self.ms = [[MessageStore alloc] init];
    
    NSLog(@"Registering for push");
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
            (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:@"test1" forKey:@"username"];
    [prefs setValue:@"test1" forKey:@"password"];
    [prefs synchronize];
    
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [self application:application didReceiveRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
        
        
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

+(MsgrAppDelegate*) getAppDelegate {
	return _delegate;
}

- (void)application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"%s", __func__);
    NSString *userFrom = [[userInfo objectForKey:@"UserFrom"] lowercaseString];
    NSString *message = [userInfo objectForKey:@"Message"];
    
    if ([ms.messages objectForKey:userFrom]) {
        [[ms.messages objectForKey:userFrom] insertObject:message atIndex:0];
    } else {
        NSMutableArray *msgCache = [[NSMutableArray alloc] init];
        [ms.messages setObject:msgCache forKey:userFrom];
        [[ms.messages objectForKey:userFrom] insertObject:message atIndex:0];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ReloadTableNotification object:nil];
    
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%s", __func__);
    NSLog(@"%@", [self convertTokenToDeviceID:deviceToken]);
}

/* This function found online at:
    http://stackoverflow.com/questions/1355837/help-trying-to-use-apple-push-notification-service-through-java
 */
- (NSString *)convertTokenToDeviceID:(NSData *)token {
    NSMutableString *deviceID = [NSMutableString string];
    // iterate through the bytes and convert to hex
    unsigned char *ptr = (unsigned char *)[token bytes];
    for (NSInteger i=0; i < 32; ++i) {
        [deviceID appendString:[NSString stringWithFormat:@"%02x", ptr[i]]];
    }
    return deviceID;
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

@end
