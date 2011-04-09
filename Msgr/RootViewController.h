//
//  RootViewController.h
//  Msgr
//
//  Created by Christopher Baltzer on 11-03-23.
//  Copyright 2011 Christopher Baltzer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgrAppDelegate.h"
#import "NetworkController.h"
#import "MessageStore.h"
#import "Notifications.h"
#import "Three20/Three20.h"

@interface RootViewController : UITableViewController <TTMessageControllerDelegate> {
    NetworkController *net;

}

@property (nonatomic, retain) NetworkController *net;
@property (nonatomic, retain) MessageStore *ms;

-(void) refreshTable;
-(void) registerNotificationHandlers;

@end
