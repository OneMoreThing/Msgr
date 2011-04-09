//
//  NetworkController.h
//  Msgr
//
//  Created by Christopher Baltzer on 11-03-23.
//  Copyright 2011 Christopher Baltzer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageStore.h"
#import "MsgrAppDelegate.h"
#import "JSON.h"
#import "Notifications.h"

#define MSGR_TYPE_MESSAGE @"message"
#define MSGR_TYPE_CONTACTS @"contacts"

@interface NetworkController : NSObject  {
    NSMutableData *cache;
    
    NSString *username;
    NSString *password;
    

}

@property (nonatomic, retain) NSMutableData *cache;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;

-(void) fetchContacts;
-(void) sendMessage:(NSString*)message toUser:(NSString*)user;

-(void) sendRequest:(NSMutableDictionary*)body ofType:(NSString*)type;


@end
