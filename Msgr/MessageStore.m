//
//  MessageStore.m
//  Msgr
//
//  Created by Christopher Baltzer on 11-04-04.
//  Copyright 2011 Christopher Baltzer. All rights reserved.
//

#import "MessageStore.h"


@implementation MessageStore

@synthesize contacts, messages;

-(id) init {
    self = [super init];
    if (self) {
        self.contacts = [[NSMutableArray alloc] init];
        self.messages = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}

@end
