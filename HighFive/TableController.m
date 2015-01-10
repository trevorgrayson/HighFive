//
//  TableController.m
//  HighFive
//
//  Created by Trevor Grayson on 1/5/15.
//  Copyright (c) 2015 Ipsum LLC. All rights reserved.
//

#import "TableController.h"
#import "ContactCell.h"

#import "AllYourAddress.h"
#import "Inbox.h"

@interface TableController ()

@end

@implementation TableController

const int kHeaderSection  = 0;
const int kInboxSection   = 1;
const int kContactSection = 2;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Avoiding status bar?
    [self.tableView setContentInset:UIEdgeInsetsMake(20,
                                                     self.tableView.contentInset.left,
                                                     self.tableView.contentInset.bottom,
                                                     self.tableView.contentInset.right)];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch( section ) {
        case kContactSection: return [AllYourAddress allContactsCount];
        case kInboxSection:   return [Inbox count];
        case kHeaderSection:  return 1;
        default: return 0;
    }
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch( section ) {
        case kContactSection: return @"High Five Someone";
        case kInboxSection:   return @"You've been High Fived!";
        default: return nil;
    }
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch( [indexPath section] ) {
        case kHeaderSection:  return [self contactForHeader:tableView cellForRowAtIndexPath: indexPath];
        case kInboxSection:   return [self contactForInbox: tableView cellForRowAtIndexPath: indexPath];
        case kContactSection: return [self contactForRow:   tableView cellForRowAtIndexPath: indexPath];
        default: return [self contactForRow:  tableView cellForRowAtIndexPath: indexPath];
    }

}

- (UITableViewCell *) contactForHeader:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"headerCell"];
    return cell;
}

- (UITableViewCell *) contactForInbox:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier: @"inboxCell"];
    Slap *slap = [Inbox messageAtIndex: [indexPath row]];
    cell.name.text = slap.slapper.name;
    cell.icon.image = [UIImage imageNamed:@"internet-high-five.jpeg"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if( [indexPath section] == 0 ) {
        return self.view.frame.size.height - 20;
    } else {
        return 60.0;
    }
}

- (UITableViewCell *) contactForRow:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier: @"inboxCell"];
    
    ABRecordRef contact = [AllYourAddress contactAtIndex: [indexPath row]];
    
    NSString *first = (__bridge NSString *)(ABRecordCopyValue(contact, kABPersonFirstNameProperty));
    NSString *last  = (__bridge NSString *)(ABRecordCopyValue(contact, kABPersonLastNameProperty));
    NSString *name = @"";
    
    if( first )
        name = first;
    if( last )
        name = [NSString stringWithFormat: @"%@ %@", name, last];
    
    NSData *imgData   = (__bridge NSData*)ABPersonCopyImageDataWithFormat(contact, kABPersonImageFormatThumbnail);
    UIImage  *icon    = [UIImage imageWithData: imgData];
    
    cell.name.text = name;
    cell.icon.image = icon;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == kHeaderSection ) {
        [self checkInbox];
    } else if( [indexPath section] == kContactSection ) {
        User *target = [[User alloc] init:@"bob" with:@"8603849759"];
        [[SlapMotionDelegate alloc] init: [AllYourAddress contactAtIndex:[indexPath row]]];
    }
}

- (void)checkInbox {
    NSIndexPath *path = [NSIndexPath indexPathForRow: 0 inSection: kInboxSection];
    [self.tableView scrollToRowAtIndexPath: path atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView cafnEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
