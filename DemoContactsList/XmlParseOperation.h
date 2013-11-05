//
// Created by Krzysztof Kunowski on 30.10.2013.
// Copyright (c) 2013 Krzysztof Kunowski. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>

@interface XmlParseOperation : NSOperation <NSXMLParserDelegate>

@property(copy, readonly) NSData *parseData;
@property(copy, readonly) NSMutableArray *currentContacts;

- (id)initWithData:(NSData *)parseData;

@end