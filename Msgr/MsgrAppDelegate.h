//
//  MsgrAppDelegate.h
//  Msgr
//
//  Created by Christopher Baltzer on 11-03-23.
//  Copyright 2011 Christopher Baltzer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageStore.h"
#import "Notifications.h"

@interface MsgrAppDelegate : NSObject <UIApplicationDelegate> {
    MessageStore *ms;
}


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) MessageStore *ms;


+(MsgrAppDelegate*) getAppDelegate;
- (NSString *)convertTokenToDeviceID:(NSData *)token;

@end
