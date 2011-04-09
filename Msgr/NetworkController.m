//
//  NetworkController.m
//  Msgr
//
//  Created by Christopher Baltzer on 11-03-23.
//  Copyright 2011 Christopher Baltzer. All rights reserved.
//

#import "NetworkController.h"

#define SERVER_IP @"http://192.168.0.116:12345"

@implementation NetworkController

@synthesize cache;
@synthesize username, password;

-(id) init {
    self = [super init];
    if (self) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        self.username = [prefs objectForKey:@"username"];
        self.password = [prefs objectForKey:@"password"];
        
        NSLog(@"%@ %@", self.username, self.password);
        
        [self fetchContacts];
    }
    return self;
}

-(void) fetchContacts {
    NSLog(@"%s", __func__);
    NSMutableDictionary *body = [[[NSMutableDictionary alloc] init] autorelease];
    [body setValue:self.username forKey:@"Username"];
    [body setValue:self.password forKey:@"Password"];
    
    NSString *jsonBody = [body JSONRepresentation]; 
    
    NSString *host = [NSString stringWithFormat:@"%@/%@", SERVER_IP, MSGR_TYPE_CONTACTS];
	NSURL *url = [NSURL URLWithString:host];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[jsonBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"%@", request);
    
    
    NSHTTPURLResponse *resp;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:nil];
    if (resp.statusCode == 200) {
        NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *contacts = (NSArray*)[response JSONValue];
        NSLog(@"Contacts received: %@", contacts);
        
        for (NSString *c in contacts) {
            [[[MsgrAppDelegate getAppDelegate] ms ].contacts addObject:c]; 
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ReloadTableNotification object:nil];
        
    } else {
        NSLog(@"Request failed");
    }
    
}

-(void) sendMessage:(NSString *)message toUser:(NSString*)user {
    NSLog(@"%s", __func__);
    
    NSMutableDictionary *body = [[[NSMutableDictionary alloc] init] autorelease];
    [body setValue:self.username forKey:@"UserFrom"];
    [body setValue:self.password forKey:@"Password"];
    [body setValue:user forKey:@"UserTo"];
    [body setValue:message forKey:@"Message"];
    
    [self sendRequest:body ofType:MSGR_TYPE_MESSAGE];
}

-(void) sendRequest:(NSMutableDictionary*)body ofType:(NSString*)type {
    NSLog(@"%s", __func__);
    NSString *jsonBody = [body JSONRepresentation]; 
    
    NSString *host = [NSString stringWithFormat:@"%@/%@", SERVER_IP, @"message"];
	NSURL *url = [NSURL URLWithString:host];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[jsonBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}

@end
