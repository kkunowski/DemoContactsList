//
//  DetailViewController.h
//  ContactsList
//
//  Created by Krzysztof Kunowski on 30.10.2013.
//  Copyright (c) 2013 Krzysztof Kunowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property(strong, nonatomic) id detailItem;

@property(weak, nonatomic) IBOutlet UITextView *noteTextView;
@property(weak, nonatomic) IBOutlet UIImageView *pictureImageView;

@end