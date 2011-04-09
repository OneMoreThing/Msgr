//
//  RootViewController.m
//  Msgr
//
//  Created by Christopher Baltzer on 11-03-23.
//  Copyright 2011 Christopher Baltzer. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

@synthesize net, ms;

#pragma mark
#pragma mark Table Functions
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([ms.contacts count]) {
        return [ms.contacts count];
    } else {
        return 0;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    NSString *contact = [self.ms.contacts objectAtIndex:[indexPath row]];
    NSString *lastMessage = [[ms.messages objectForKey:contact] objectAtIndex:0];
    
    cell.textLabel.text = contact;
    if (lastMessage) {
        cell.detailTextLabel.text = lastMessage;
    }
        
    // Configure the cell.
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
      
     // ...
     // Pass the selected object to the new view controller.
    TTMessageRecipientField *recip = [[[TTMessageRecipientField alloc] initWithTitle:[ms.contacts objectAtIndex:indexPath.row] 
                                                                           required:NO] autorelease];
    TTMessageController *mc = [[TTMessageController alloc] init]; //WithRecipients:[NSArray arrayWithObject:recip]];
    [mc setShowsRecipientPicker:NO];
    
    [mc setDelegate:self];
    [mc setFields:[NSArray arrayWithObject:recip]];
    
    [self.navigationController pushViewController:mc animated:YES];
    [mc release];
    
    NSLog(@"%s", __func__);
    //
}

#pragma mark
#pragma mark TTMessageController suff
-(void)composeControllerWillCancel:(TTMessageController *)controller {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)composeController:(TTMessageController *)controller didSendFields:(NSArray *)fields {
    NSString *message = [controller textForFieldAtIndex:controller.fields.count];
    NSString *userTo = [[fields objectAtIndex:0] title];
    NSLog(@"%@: %@", userTo, message);
    [net sendMessage:message toUser:userTo];
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark
#pragma mark View functions
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Msgr";
    [self registerNotificationHandlers];
    
    self.net = [[NetworkController alloc] init];
    self.ms = [MsgrAppDelegate getAppDelegate].ms;

}

-(void) refreshTable {
    NSLog(@"%s", __func__);
    self.ms = [MsgrAppDelegate getAppDelegate].ms;
    [self.tableView reloadData];
}

-(void) registerNotificationHandlers {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:ReloadTableNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [super dealloc];
}

@end