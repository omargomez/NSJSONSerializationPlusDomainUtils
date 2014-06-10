//
//  ModelMenu.h
//  NSJSONSerializationPlusDomainUtils
//
//  Created by Omar Gómez on 6/10/14.
//  Copyright (c) 2014 Omar Gomez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelPopup.h"

@interface ModelMenu : NSObject

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) ModelPopup *popup;

@end
