//
//  PCSearchItem.h
//  PPOCMobile
//
//  Created by Omar Gómez on 5/30/14.
//  Copyright (c) 2014 Omar Gomez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCSearchItemImage : NSObject

@property (nonatomic, strong) NSString *alt;
@property (nonatomic, strong) NSString *full;
@property (nonatomic, strong) NSString *square;
@property (nonatomic, strong) NSString *thumb;

@end

@interface PCSearchItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *pk;
@property (nonatomic, strong) PCSearchItemImage *image;

@end
