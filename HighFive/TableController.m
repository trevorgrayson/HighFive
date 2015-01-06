//
//  TableController.m
//  HighFive
//
//  Created by Trevor Grayson on 1/5/15.
//  Copyright (c) 2015 Ipsum LLC. All rights reserved.
//

#import "TableController.h"
#import "AllYourAddress.h"

@interface TableController ()

@end

@implementation TableController

- (void)viewDidLoad {
    [super viewDidLoad];

    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"headerCell"];
    //[self.storyboard instantiateViewControllerWithIdentifier: @"tableController"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch( section ) {
        case 2: return [AllYourAddress allContactsCount];
        case 1: return 2;
        case 0: return 1;
        default: return 0;
    }

}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch( section ) {
        case 2: return @"High Five Someone";
        case 1: return @"You've been High Fived!";
        default: return nil;
    }
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch( [indexPath section] ) {
        case 0: return [self contactForHeader:tableView cellForRowAtIndexPath: indexPath];
        case 1: return [self contactForInbox: tableView cellForRowAtIndexPath: indexPath];
        case 2: return [self contactForRow:   tableView cellForRowAtIndexPath: indexPath];
        default: return [self contactForRow:  tableView cellForRowAtIndexPath: indexPath];
    }

}

- (UITableViewCell *) contactForHeader:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"headerCell"];
    
    if( !cell ) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"headerCell"];
        cell.textLabel.text = @"HIGH FIVE!";
    }
    return cell;
}

- (UITableViewCell *) contactForInbox:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"inboxCell"];
    
    if( !cell ) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"inboxCell"];
        cell.textLabel.text = @"XXX Slapped you!";
    }
    return cell;
}

- (UITableViewCell *) contactForRow:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell"];

    if( !cell ) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"contactCell"];
    }
    // Configure the cell..
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
    
    cell.textLabel.text = name;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
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
