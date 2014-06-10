//
//  NSJSONSerializationPlusDomainUtilsTests.m
//  NSJSONSerializationPlusDomainUtilsTests
//
//  Created by Omar Gómez on 5/27/14.
//  Copyright (c) 2014 Omar Gomez. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSJSONSerialization+DomainUtils.h"
#import "ModelResource.h"
#import "ModelItem.h"
#import "ModelMenuRoot.h"
#import "ModelMenu.h"
#import "ModelPopup.h"
#import "ModelMenuItem.h"

@interface NSJSONSerializationPlusDomainUtilsTests : XCTestCase

@end

@implementation NSJSONSerializationPlusDomainUtilsTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    NSData *inputData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"http://loc.gov/pictures/resource/ppmsc.03034?fo=json"]];
    
    XCTAssertNotNil(inputData, @"Nil response");
    
    NSError *error = nil;
    
    NSDictionary *map = @{
                          @"$": [ModelResource class],
                          @"$.item": [ModelItem class]
                          };
    
    id outSchema = [NSJSONSerialization ModelObjectWithData:inputData options:0 suffixMap:map error:&error];
    
    XCTAssertNotNil(outSchema, @"Nil response");
    XCTAssertEqual([outSchema class], [ModelResource class], @"It's not a model class");
    
    ModelResource *resource = (ModelResource*) outSchema;
    
    XCTAssertNotNil(resource.item, @"Nil response");
    XCTAssertEqual([resource.item class], [ModelItem class], @"It's not a model class");
    
    ModelItem *item = (ModelItem*) resource.item;
}

-(void) testDoc
{
    const char *json =
    "{\"menu\": {"
    "    \"id\": \"file\","
    "    \"value\": \"File\","
    "    \"popup\": {"
    "        \"menuitem\": ["
    "                     {\"value\": \"New\", \"onclick\": \"CreateNewDoc()\"},"
    "                     {\"value\": \"Open\", \"onclick\": \"OpenDoc()\"},"
    "                     {\"value\": \"Close\", \"onclick\": \"CloseDoc()\"}"
    "                     ]"
    "    }"
    "}}" ;
    
    id data = [NSData dataWithBytes:json length:strlen(json)];
    
    NSError *error;
    NSDictionary *map =@{
                         @"$": [ModelMenuRoot class],
                         @".menu": [ModelMenu class],
                         @".popup": [ModelPopup class],
                         @".menuitem[]": [ModelMenuItem class],
                         };
    ModelMenuRoot *root =[NSJSONSerialization ModelObjectWithData: data
                                                      options:0
                                                    suffixMap:map
                                                        error:&error];
    
    XCTAssertNotNil(root, @"Nil response");
    XCTAssertEqualObjects([root.menu.popup.menuitem[1] value], @"Open", @"");
    NSLog(@"%@", [root.menu.popup.menuitem[1] value] );
    
}

@end
