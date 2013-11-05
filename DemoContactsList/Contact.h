//
// Created by Krzysztof Kunowski on 30.10.2013.
// Copyright (c) 2013 Krzysztof Kunowski. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>

typedef enum {
    kMale,
    kFemale,
    kUnknown
} Sex;

@interface Contact : NSObject

@property(nonatomic) NSString *firstName;
@property(nonatomic) NSString *lastName;
@property(nonatomic) int age;
@property(nonatomic) Sex sex;
@property(nonatomic) UIImage *picture;
@property(nonatomic) NSString *pictureUrl;
@property(nonatomic) NSString *notes;
@property(nonatomic) NSIndexPath *currentIndexPath;

@end