//
// Created by Krzysztof Kunowski on 30.10.2013.
// Copyright (c) 2013 Krzysztof Kunowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"

@interface UITableViewContactCell : UITableViewCell

@property(nonatomic) IBOutlet UILabel *nameLabel;
@property(nonatomic) IBOutlet UILabel *detailsLabel;
@property(nonatomic) IBOutlet UIImageView *pictureImageView;

- (void)configWithContact:(Contact *)contact;

@end