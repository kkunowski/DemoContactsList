//
// Created by Krzysztof Kunowski on 30.10.2013.
// Copyright (c) 2013 Krzysztof Kunowski. All rights reserved.
//

#import "DownloadPictureOperation.h"

@implementation DownloadPictureOperation {

    Contact *_contact;
    NSData *_currentDownloadData;
}

- (id)initWithContact:(Contact *)contact {
    self = [super init];
    if (self) {
        _contact = contact;
        executing = NO;
        finished = NO;
    }
    return self;
}

- (void)start {
    if ([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }

    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main {
        if (![self isCancelled]) {
            _currentDownloadData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:_contact.pictureUrl]];
            UIImage *pictureImage = [UIImage imageWithData:_currentDownloadData];
            if (pictureImage) {
                _contact.picture = pictureImage;
            } else {
                _contact.picture = [UIImage imageNamed:@"ErrorPicturePlaceholder.png"];
            }
            
            [self completeOperation];
            [self performSelectorOnMainThread:@selector(updateContact:) withObject:_contact waitUntilDone:NO];
        }
}

- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    executing = NO;
    finished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    _currentDownloadData = nil;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return executing;
}

- (BOOL)isFinished {
    return finished;
}

- (void)updateContact:(Contact *)contact {
    assert([NSThread isMainThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kContactPictureDownloadFinishedNotification object:contact];
}

@end