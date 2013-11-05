//
//  MasterViewController.m
//  ContactsList
//
//  Created by Krzysztof Kunowski on 30.10.2013.
//  Copyright (c) 2013 Krzysztof Kunowski. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "XmlParseOperation.h"
#import "UITableViewContactCell.h"
#import "DownloadPictureOperation.h"

@interface MasterViewController ()
@property(nonatomic) NSMutableArray *contacts;
@end

@implementation MasterViewController {
    NSOperationQueue *_operationsQueue;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObservers];
    _contacts = [NSMutableArray new];
    _operationsQueue = [NSOperationQueue new];
    [_operationsQueue setMaxConcurrentOperationCount:kMaxNumberOfConcurrentPictureDownloads];
    [self reloadContacts];
}

 - (IBAction)reloadContacts {
    if ([[_operationsQueue operations] count] > 0) {
        [_operationsQueue cancelAllOperations];
    }
    if ([_contacts count] > 0) {
        [_contacts removeAllObjects];
        [self.tableView reloadData];
    }
    NSURLRequest *requestUrl = [NSURLRequest requestWithURL:[NSURL URLWithString:kDemoApiUrl]];
    [NSURLConnection sendAsynchronousRequest:requestUrl
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error != nil) {
                                   [self handleError:error];
                               }
                               else {
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                   if ([httpResponse statusCode] == kHTTPStatusCodeOK) {
                                       XmlParseOperation *parseOperation = [[XmlParseOperation alloc] initWithData:data];
                                       [_operationsQueue addOperation:parseOperation];
                                   } else {
                                       NSError *responseError = [NSError errorWithDomain:@"HTTP"
                                                                                    code:[httpResponse statusCode]
                                                                                userInfo:nil];
                                       [self handleError:responseError];
                                   }
                               }
                           }];
}

// called when contact in table cell needs picture to download
- (void)downloadPictureForContact:(Contact *)contact {
    DownloadPictureOperation *downloadPictureOperation = [[DownloadPictureOperation alloc] initWithContact:contact];
    [_operationsQueue addOperation:downloadPictureOperation];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Contact *object = [_contacts objectAtIndex:(NSUInteger) [indexPath row]];
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ContactCell";
    UITableViewContactCell *cell = (UITableViewContactCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Contact *contact = [_contacts objectAtIndex:(NSUInteger) [indexPath row]];
    if (!contact.currentIndexPath) {
        contact.currentIndexPath = indexPath;
    }
    if (!contact.picture) {
        [self downloadPictureForContact:contact];
    }
    if (contact.picture && ![self tableBusy]) {
        cell.pictureImageView.image = contact.picture;
    }
    [cell configWithContact:contact];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma - NSNotifications

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showError:)
                                                 name:kContactParsingErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addContacts:)
                                                 name:kContactCreatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateContactPicture:)
                                                 name:kContactPictureDownloadFinishedNotification object:nil];
}

- (void)addContacts:(NSNotification *)notification {
    assert([NSThread isMainThread]);
    [self handleAddContacts:[notification object]];
}

- (void)showError:(NSNotification *)notification {
    assert([NSThread isMainThread]);
    [self handleError:(NSError *) [notification object]];
}

- (void)updateContactPicture:(NSNotification *)notification {
    assert([NSThread isMainThread]);
    [self handleUpdateContactPicture:[notification object]];
}

#pragma - NSNotifications callback handlers

- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)handleUpdateContactPicture:(Contact *)contact {
    @synchronized (_contacts) {
        if ([_contacts count] > [contact.currentIndexPath row]) {
            [_contacts replaceObjectAtIndex:(NSUInteger) [contact.currentIndexPath row] withObject:contact];
        }
        if ([[self.tableView indexPathsForVisibleRows] containsObject:contact.currentIndexPath] && ![self tableBusy]) {
            [self.tableView reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:contact.currentIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (void)handleAddContacts:(NSMutableArray *)contacts {
    [_contacts addObjectsFromArray:contacts];
    [self.tableView reloadData];
}

-(BOOL)tableBusy {
    if(!self.tableView.dragging && !self.tableView.decelerating && !self.tableView.tracking) {
        return NO;
    }
    return YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kContactCreatedNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kContactParsingErrorNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kContactPictureDownloadFinishedNotification
                                                  object:nil];
}

@end