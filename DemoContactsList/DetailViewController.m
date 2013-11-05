//
//  DetailViewController.m
//  ContactsList
//
//  Created by Krzysztof Kunowski on 30.10.2013.
//  Copyright (c) 2013 Krzysztof Kunowski. All rights reserved.
//

#import "DetailViewController.h"
#import "Contact.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        [self addObservers];
    }
}

- (void)configureView {
    if (self.detailItem) {
        self.noteTextView.text = [self.detailItem notes];
        if ([self.detailItem picture]) {
            self.pictureImageView.image = [self.detailItem picture];
        } else {
            self.pictureImageView.image = [UIImage imageNamed:@"PicturePlaceholder.png"];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

#pragma - NSNotifications

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateContactPicture:)
                                                 name:kContactPictureDownloadFinishedNotification object:nil];
}

- (void)updateContactPicture:(NSNotification *)notification {
    assert([NSThread isMainThread]);
    [self handleUpdateContactPicture:[notification object]];
}

#pragma - NSNotifications callback handlers

- (void)handleUpdateContactPicture:(Contact *)contact {
    if (contact.currentIndexPath == [_detailItem currentIndexPath] && ![self isMovingFromParentViewController] && ![self isMovingToParentViewController]) {
        _detailItem = contact;
        self.pictureImageView.image = [self.detailItem picture];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kContactPictureDownloadFinishedNotification
                                                  object:nil];
}

@end