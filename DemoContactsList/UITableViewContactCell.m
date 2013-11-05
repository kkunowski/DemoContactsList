//
// Created by Krzysztof Kunowski on 30.10.2013.
// Copyright (c) 2013 Krzysztof Kunowski. All rights reserved.
//

#import "UITableViewContactCell.h"

@implementation UITableViewContactCell

- (void)configWithContact:(Contact *)contact {
    if (contact.picture) {
        self.pictureImageView.image = contact.picture;
    } else {
        self.pictureImageView.image = [UIImage imageNamed:@"PicturePlaceholder.png"];
    }
    NSMutableString *nameText = [NSMutableString new];
    if (contact.firstName) {
        [nameText appendString:contact.firstName];
    }
    if (contact.lastName) {
        [nameText appendString:@" "];
        [nameText appendString:contact.lastName];
    }
    self.nameLabel.text = nameText;
    NSMutableString *detailText = [NSMutableString new];
    if (contact.sex == kMale) {
        [detailText appendString:@"Male"];
    } else if (contact.sex == kFemale) {
        [detailText appendString:@"Female"];
    }
    if (contact.age > 0) {
        [detailText appendString:@" "];
        [detailText appendString:[NSString stringWithFormat:@"%d", contact.age]];
    }
    self.detailsLabel.text = detailText;
}

@end