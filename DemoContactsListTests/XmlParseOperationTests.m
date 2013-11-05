//
// Created by Krzysztof Kunowski on 30.10.2013.
// Copyright (c) 2013 Krzysztof Kunowski. All rights reserved.
//

#import "Kiwi.h"
#import "XmlParseOperation.h"
#import "Contact.h"

static NSString *contactsXmlValidString =
        @"<contacts>"
                @"<contact>"
                @"<firstName>Steve</firstName>"
                @"<lastName>Jobs</lastName>"
                @"<age>99</age>"
                @"<sex>m</sex>"
                @"<picture>http://steve.png</picture>"
                @"<notes><![CDATA[Steve notes]]></notes>"
                @"</contact>"
                @"<contact>"
                @"<firstName>Mary</firstName>"
                @"<lastName>Black</lastName>"
                @"<age>50</age>"
                @"<sex>f</sex>"
                @"<picture>http://mary.png</picture>"
                @"<notes><![CDATA[Mary notes]]></notes>"
                @"</contact>"
                @"</contacts>";

static NSString *contactsXmlNotValidString =
        @"<contacts>"
                @"<contact>"
                @"<firstName>Steve</firstName>"
                @"<age>vxcvx</age>"
                @"<sex>aaaaa</sex>"
                @"<picture></picture>"
                @"<notes><![CDATA[Steve notes]]></notes>"
                @"</contact>"
                @"<contact>"
                @"<firstName></firstName>"
                @"<strangeElement></strangeElement>"
                @"<lastName>Black</lastName>"
                @"<age>50</age>"
                @"<sex>f</sex>"
                @"<picture>http://mary.png</picture>"
                @"<notes><![CDATA[Mary notes]]></notes>"
                @"</contact>"
                @"</contacts>";

SPEC_BEGIN(XmlParseOperationSpec)

        describe(@"Contacts", ^{
            context(@"when parsed from valid XML file", ^{
                NSData *contactsString = [contactsXmlValidString dataUsingEncoding:NSUTF8StringEncoding];
                XmlParseOperation *parseOperation = [[XmlParseOperation alloc] initWithData:contactsString];
                [parseOperation main];
                it(@"should have right number of contacts", ^{
                    [[parseOperation.currentContacts should] haveCountOf:2];
                });
                it(@"should have right values", ^{
                    Contact *steveContact = [parseOperation.currentContacts objectAtIndex:0];
                    [[[steveContact firstName] should] equal:@"Steve"];
                    [[[steveContact lastName] should] equal:@"Jobs"];
                    [[theValue([steveContact age]) should] equal:theValue(99)];
                    [[theValue([steveContact sex]) should] equal:theValue(kMale)];
                    [[[steveContact pictureUrl] should] equal:@"http://steve.png"];
                    [[[steveContact notes] should] equal:@"Steve notes"];
                    Contact *maryContact = [parseOperation.currentContacts objectAtIndex:1];
                    [[[maryContact firstName] should] equal:@"Mary"];
                    [[[maryContact lastName] should] equal:@"Black"];
                    [[theValue([maryContact age]) should] equal:theValue(50)];
                    [[theValue([maryContact sex]) should] equal:theValue(kFemale)];
                    [[[maryContact pictureUrl] should] equal:@"http://mary.png"];
                    [[[maryContact notes] should] equal:@"Mary notes"];
                });
            });
           context(@"when parsed from not valid XML file", ^{
                NSData *contactsString = [contactsXmlNotValidString dataUsingEncoding:NSUTF8StringEncoding];
                XmlParseOperation *parseOperation = [[XmlParseOperation alloc] initWithData:contactsString];
                [parseOperation main];
                it(@"should have right number of contacts", ^{
                    [[parseOperation.currentContacts should] haveCountOf:2];
                });
                it(@"should have right values", ^{
                    Contact *steveContact = [parseOperation.currentContacts objectAtIndex:0];
                    [[[steveContact firstName] should] equal:@"Steve"];
                    [[steveContact lastName] shouldBeNil];
                    [[theValue([steveContact age]) should] equal:theValue(0)];
                    [[theValue([steveContact sex]) should] equal:theValue(kUnknown)];
                    [[[steveContact pictureUrl] should] equal:@""];
                    [[[steveContact notes] should] equal:@"Steve notes"];
                    Contact *maryContact = [parseOperation.currentContacts objectAtIndex:1];
                    [[[maryContact firstName] should] equal:@""];
                    [[[maryContact lastName] should] equal:@"Black"];
                    [[theValue([maryContact age]) should] equal:theValue(50)];
                    [[theValue([maryContact sex]) should] equal:theValue(kFemale)];
                    [[[maryContact pictureUrl] should] equal:@"http://mary.png"];
                    [[[maryContact notes] should] equal:@"Mary notes"];

                });
            });
        });

SPEC_END





