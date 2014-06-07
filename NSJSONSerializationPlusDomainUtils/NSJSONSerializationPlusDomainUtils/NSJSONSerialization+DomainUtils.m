//
//  NSJSONSerialization+DomainUtils.m
//  JSONSchemaGenerator
//
//  Created by Omar Gómez on 4/29/14.
//  Copyright (c) 2014 Omar Gomez. All rights reserved.
//

#import <objc/runtime.h>

#import "NSJSONSerialization+DomainUtils.h"

static NSArray *methodsForClass(Class class) {
    unsigned int outCount;
    Method *methods = class_copyMethodList(class, &outCount);
    NSMutableArray *newResult = [NSMutableArray array];
    for (int i = 0; i < outCount; i++) {
        if (method_getNumberOfArguments(methods[i]) == 3) {
            char *returnType = method_copyReturnType(methods[i]);
            char *setParam = method_copyArgumentType(methods[i], 2);
            if (!strcmp(returnType, @encode(void)) && !strcmp(setParam, @encode(id)) ) {
                NSString *strMethodName = NSStringFromSelector(method_getName(methods[i]));
                if ([strMethodName length] > 3) {
                    NSString *prefix = [strMethodName substringToIndex:3];
                    if ([prefix isEqualToString:@"set" ]) {
                        NSString *attrName = [[strMethodName substringFromIndex:3] lowercaseString];
                        [newResult addObject: [attrName substringToIndex:[attrName length]-1]];
                    }
                }
            }
        }
        else {
            continue;
        }
        
    }
    free(methods);
    return newResult;
}


@implementation NSJSONSerialization (DomainUtils)

+(id)ModelObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt suffixMap:(NSDictionary*) map error:(NSError **)error
{

    id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    
    if (error != nil && *error) {
        return jsonObj;
    }
    
    __block __weak id (^dictWalker)(NSDictionary  *, NSString *) = nil;
    __block __weak id (^arrayWalker)(NSArray *, NSString *) = nil;
    
    arrayWalker = ^id(NSArray *anArray, NSString *path) {
        NSMutableArray *result = [NSMutableArray array];
        for (int i = 0; i < [anArray count]; i++) {
            id entry = anArray[i];
            NSString *newPath = [NSString stringWithFormat:@"%@[]", path];
            
            if ([entry isKindOfClass:[NSDictionary class]]) {
                entry = dictWalker(entry , newPath );
            }
            else if([entry isKindOfClass:[NSArray class]]){
                entry = arrayWalker( entry, newPath );
            }
            else {
                ; //skip
            }
            [result addObject: entry];
        }
        return result;
    };
    
    dictWalker = ^id(NSDictionary *aDictionary, NSString *path) {
        
        Class modelClazz = nil;
        for ( NSString *key in map ) {
            if ([path hasSuffix:key]) {
                modelClazz = map[key];
                break;
            }
        }
        
        if (modelClazz == nil) {
            return aDictionary;
        }
        
        id modelObj = [[modelClazz alloc] init];
        
        for (NSString *key in aDictionary) {
            NSString *newPath = [NSString stringWithFormat:@"%@.%@", path, key];
            id entry = aDictionary[key];
            
            if (!entry) {
                continue;
            }
            
            if ([entry isKindOfClass:[NSDictionary class]]) {
                entry = dictWalker( entry, newPath );
            }
            else if([entry isKindOfClass:[NSArray class]]){
                entry = arrayWalker( entry, newPath );
            }
            else {
                ; //skip
            }
            
            // selector name
            NSString *selName = [NSString stringWithFormat:@"set%@%@:",
                [[key substringToIndex:1] uppercaseString],
                [key substringFromIndex:1]
            ];
            SEL selector = NSSelectorFromString(selName);
            if ([modelObj respondsToSelector:selector]) {
                [modelObj performSelector:selector withObject:entry];
            }
        }
        
        return modelObj;
    };
    
    id result = nil;
    if ([jsonObj isKindOfClass:[NSDictionary class]]) {
        result = dictWalker( jsonObj, @"$" );
    }
    else if([jsonObj isKindOfClass:[NSArray class]]){
        result = arrayWalker( jsonObj, @"$" );
    }
    else {
        ;
    }
    
    return result;
}

@end
