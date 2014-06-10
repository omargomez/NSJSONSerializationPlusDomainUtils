//
//  NSJSONSerialization+DomainUtils.h
//  JSONSchemaGenerator
//
//  Created by Omar Gómez on 4/29/14.
//  Copyright (c) 2014 Omar Gomez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (DomainUtils)

+(id)ModelObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt suffixMap:(NSDictionary*) pathClassMap error:(NSError **)error;

@end
