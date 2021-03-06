//
//  TableController.m
//  HighFive
//
//  Created by Trevor Grayson on 1/5/15.
//  Copyright (c) 2015 Ipsum LLC. All rights reserved.
//

// TODO
// get name
// register with all data

// uncomment out controller change before commit
// TextField delegate for search  SearchTextfieldDelegate
// dismissable
// can submit

// move search to top, if possible?
// each letter narrows down results?

#import "TableController.h"

//TODO -2 section situation
@interface TableController ()

@end

@implementation TableController

@synthesize headline;

const int kBaseSectionCount  = 2;

const int kHeaderSection     = 0;
const int kInboxSection      = 1;
const int kSearchSection     = 2;
const int kContactSection    = 3;

NSString *defaultHeadline = @"Tap to Slap";

CGPoint lastScrollOffset;

SlapMotionWorker *slapWorker1;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self reset];
    
    // Avoiding status bar
    [self.tableView setContentInset:UIEdgeInsetsMake(20, self.tableView.contentInset.left,
            self.tableView.contentInset.bottom,
            self.tableView.contentInset.right)];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(reset) name: @"harakiri" object:nil];
    [SlapNet registerDefaultUser];
}

- (void)viewDidAppear:(BOOL)animated {
    // ask for access to address book
    int contactCount = sizeof([AllYourAddress allContacts]);
    // ask for push notifications? double whammy needs work
    AppDelegate *deleg = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [deleg registerForNotifications];
    
    if( contactCount > 0 ) {
        [self.tableView reloadData];
    }
}

#pragma mark - Controller phase methods
- (void) reset {
    headline = defaultHeadline;
    
    if(slapWorker1) {
        [slapWorker1 harakiri];
    }
    
    slapWorker1 = nil;
    if(self.tableView) {
        [self.tableView reloadData];
    }
}

- (bool) inSlapMode {
    return slapWorker1 != nil;
}

- (void) slapModeFor:(User*) user {
    headline = [NSString stringWithFormat: @"Slap %@ some skin", user.name];
    //TODO Heavy handed?
    [self.tableView reloadData];
    slapWorker1 = [[SlapMotionWorker alloc] init: user];
}

- (void) receiveHighFive:(double) ferocity from:(User*) user
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kBaseSectionCount + ([AllYourAddress isSharingContacts] ? 2 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch( section ) {
        //case kContactSection: return [AllYourAddress allContactsCount];
        case kInboxSection:   return [Inbox count];
        case kHeaderSection:  return 1;
        case kSearchSection: return 1;
        default: return [AllYourAddress contactsStartingWithCount:
                         [self letterAt: section - 2]];
    }
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch( section ) {
        case kContactSection: return @"Send a High Five";
        case kInboxSection:
            if([Inbox count] > 0 )
                return @"You've been High Fived!";
            else return nil;
        default: return nil;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch( [indexPath section] ) {
        case kHeaderSection: return [self contactForHeader:tableView cellForRowAtIndexPath: indexPath];
        case kInboxSection:  return [self contactForInbox: tableView cellForRowAtIndexPath: indexPath];
        case kSearchSection: return [self searchCell: tableView];
        //case kContactSection: return [self contactForRow:   tableView cellForRowAtIndexPath: indexPath];
        default: return [self contactForRow:  tableView cellForRowAtIndexPath: indexPath];
    }

}

- (UITableViewCell *) contactForHeader:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HeaderCell *cell = [tableView dequeueReusableCellWithIdentifier: @"headerCell"];
    cell.headline.text = headline;
    return cell;
}

- (UITableViewCell *) searchCell:(UITableView *)tableView {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"searchCell"];
    //cell.headline.text = headline;
    return cell;
}

- (UITableViewCell *) contactForInbox:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier: @"inboxCell"];
    Slap *slap = [Inbox messageAtIndex: [indexPath row]];
    cell.name.text = [NSString stringWithFormat:@"%@ slapped a %0.2f", slap.slapper.name, slap.ferocity];
    cell.icon.image = [UIImage imageNamed:@"internet-high-five.jpeg"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if( [indexPath section] == 0 ) {
        return self.view.frame.size.height;
    } else {
        return 60.0;
    }
}

- (UITableViewCell *) contactForRow:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier: @"inboxCell"];
    //    ABRecordRef contact = [AllYourAddress contactAtIndex: [indexPath row]];
    NSInteger offset = [indexPath section] - 2;
    NSString *letter = [[self arrayOfLetters] objectAtIndex: offset];
    ABRecordRef contact =
    (__bridge ABRecordRef)([[AllYourAddress contactsStartingWith: letter] objectAtIndex: [indexPath row]]);
    
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
    Slap *slap;
    NSInteger contactLetterIndex = [indexPath section] - 2;
    NSInteger row = [indexPath row];
    
    switch ([indexPath section]) {
        case kSearchSection: return;
        case kHeaderSection:
            if(![self inSlapMode]) {
                [AllYourAddress isSharingContactsWithCallback:^(void){
                    [self.tableView reloadData];
                }];
                
                [self checkInbox];
            }

            break;
            
        case kInboxSection:
            slap = [Inbox messageAtIndex: [indexPath row]];
            [self slapModeFor: slap.slapper];
            [self scrollToTop];
            break;
        
        default:
            //NSIndexPath *path = [NSIndexPath indexPathForRow: 0 inSection: 0];
            [self slapModeFor: [AllYourAddress contactStartingWith: [self letterAt: contactLetterIndex] atIndex: row]];
            [tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: 0 inSection: 0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            break;
    }
}

-(void) scrollToTop {
    [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: 0 inSection: 0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

//SECTION TITLES
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {

    NSIndexPath *topRow = [[self.tableView indexPathsForVisibleRows] objectAtIndex:0];
    
    if( [topRow section] > 1) {
        return self.arrayOfLetters;
    } else {
        return nil;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index + 2;
}

-(NSArray*) arrayOfLetters {
    return [NSArray arrayWithObjects: @"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
}

-(NSString*) letterAt:(NSInteger) i {
    return [[self arrayOfLetters] objectAtIndex: i ];
}

- (void)checkInbox {
    NSIndexPath *path;
    
    path = [NSIndexPath indexPathForRow: 0 inSection: 0];
    
    if( [Inbox count] > 0) {
        path = [NSIndexPath indexPathForRow: 0 inSection: kInboxSection];
    } else if ([self.tableView numberOfSections] > 3) {
        path = [NSIndexPath indexPathForRow: 0 inSection: kContactSection];
    }
    
    [self.tableView scrollToRowAtIndexPath: path atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [AllYourAddress isSharingContactsWithCallback:^(void){
        [self.tableView reloadData];
    }];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.tableView reloadSectionIndexTitles];
    
    if( [self inSlapMode]  &&
        (scrollView.contentOffset.y > self.view.frame.size.height/2) &&
        (lastScrollOffset.y < scrollView.contentOffset.y)
       ) {
        [self reset];
    }
    
    lastScrollOffset = scrollView.contentOffset;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if( [self inSlapMode] &&
        (scrollView.contentOffset.y < self.view.frame.size.height/2)
       ) {
        [self scrollToTop];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 1) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        [Inbox removeMessageAtIndex: [indexPath row]];
        //[tableView reloadData];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
