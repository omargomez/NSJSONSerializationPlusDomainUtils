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
    id outSchema = [NSJSONSerialization ModelObjectWithData:inputData
                                                    options:0 error:&error
                                                  buildStep:
    ^Class ( NSString *path, NSDictionary *dict ) {
        
        if ([path isEqualToString:@"$"]) {
            return [ModelResource class];
        }
        else if ([path isEqualToString:@"$.item"]) {
            return [ModelItem class];
        }
        
        return nil;
        
    }];
    
    XCTAssertNotNil(outSchema, @"Nil response");
    XCTAssertEqual([outSchema class], [ModelResource class], @"It's not a model class");
    
    ModelResource *resource = (ModelResource*) outSchema;
    
    XCTAssertNotNil(resource.item, @"Nil response");
    XCTAssertEqual([resource.item class], [ModelItem class], @"It's not a model class");
    
    ModelItem *item = (ModelItem*) resource.item;
}

@end
