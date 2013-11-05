//
// Created by Krzysztof Kunowski on 30.10.2013.
// Copyright (c) 2013 Krzysztof Kunowski. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Contact.h"

@interface DownloadPictureOperation : NSOperation {
    BOOL executing;
    BOOL finished;
}
- (void)completeOperation;

- (id)initWithContact:(Contact *)contact;

@end