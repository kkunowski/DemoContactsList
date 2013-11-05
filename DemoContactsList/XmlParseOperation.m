//
// Created by Krzysztof Kunowski on 30.10.2013.
// Copyright (c) 2013 Krzysztof Kunowski. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "XmlParseOperation.h"
#import "Contact.h"

@implementation XmlParseOperation {
    NSMutableString *_currentElementData;
    Contact *_currentContact;
}

- (id)initWithData:(NSData *)parseData {
    self = [super init];
    if (self) {
        _parseData = parseData;
        _currentElementData = [[NSMutableString alloc] init];
    }
    return self;
}

// call when xml parse finished
- (void)addContacts:(NSMutableArray *)contacts {
    assert([NSThread isMainThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kContactCreatedNotification object:contacts];
}

// call when parser error occurred
- (void)handleError:(NSError *)parseError {
    assert([NSThread isMainThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kContactParsingErrorNotification object:parseError];
}

- (void)main {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.parseData];
        [parser setDelegate:self];
        [parser parse];
}

#pragma mark - NSXMLParse const

static NSString *const kContactsElementName = @"contacts";
static NSString *const kContactElementName = @"contact";
static NSString *const kFirstNameElementName = @"firstName";
static NSString *const kLastNameElementName = @"lastName";
static NSString *const kAgeElementName = @"age";
static NSString *const kSexElementName = @"sex";
static NSString *const kPictureElementName = @"picture";
static NSString *const kNotesElementName = @"notes";

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:kContactsElementName]) {
        _currentContacts = [NSMutableArray array];
    }
    else if ([elementName isEqualToString:kContactElementName]) {
        _currentContact = [[Contact alloc] init];
    }
    else if ([elementName isEqualToString:kFirstNameElementName]
            || [elementName isEqualToString:kLastNameElementName]
            || [elementName isEqualToString:kAgeElementName]
            || [elementName isEqualToString:kSexElementName]
            || [elementName isEqualToString:kPictureElementName]
            ) {
    }
    [_currentElementData setString:@""];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:kContactsElementName]) {
        if (!self.isCancelled) {
                    [self performSelectorOnMainThread:@selector(addContacts:) withObject:_currentContacts waitUntilDone:NO];
                _currentElementData = nil;
         
        }
    }
    else if ([elementName isEqualToString:kContactElementName]) {
        [_currentContacts addObject:_currentContact];
        _currentContact = nil;
    }
    else if ([elementName isEqualToString:kFirstNameElementName]) {
        _currentContact.firstName = [_currentElementData mutableCopy];
    }
    else if ([elementName isEqualToString:kLastNameElementName]) {
        _currentContact.lastName = [_currentElementData mutableCopy];
    }
    else if ([elementName isEqualToString:kAgeElementName]) {
        _currentContact.age = [[_currentElementData mutableCopy] intValue];
    }
    else if ([elementName isEqualToString:kSexElementName]) {
        if ([[_currentElementData mutableCopy] isEqualToString:@"m"]) {
            _currentContact.sex = kMale;
        } else if ([[_currentElementData mutableCopy] isEqualToString:@"f"]) {
            _currentContact.sex = kFemale;
        } else {
            _currentContact.sex = kUnknown;
        }
    }
    else if ([elementName isEqualToString:kPictureElementName]) {
        _currentContact.pictureUrl = [_currentElementData copy];
    }
    else if ([elementName isEqualToString:kNotesElementName]) {
        _currentContact.notes = [_currentElementData copy];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [_currentElementData appendString:string];
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
    NSString *someString = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
    [_currentElementData appendString:someString];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    
    if ([parseError code] != NSXMLParserDelegateAbortedParseError) {
        [self performSelectorOnMainThread:@selector(handleError:) withObject:parseError waitUntilDone:NO];
                  }
}

@end