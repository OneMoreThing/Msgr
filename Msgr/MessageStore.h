//
//  MessageStore.h
//  Msgr
//
//  Created by Christopher Baltzer on 11-04-04.
//  Copyright 2011 Christopher Baltzer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MessageStore : NSObject {
    /* Use an array to store the contact list, and a dictionary of arrays to store actual conversations */
    
    NSMutableArray *contacts;
    NSMutableDictionary *messages;
}

@property (nonatomic, retain) NSMutableArray *contacts;
@property (nonatomic, retain) NSMutableDictionary *messages;

@end
