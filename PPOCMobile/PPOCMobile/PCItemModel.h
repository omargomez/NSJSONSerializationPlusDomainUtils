//
//  PCItemModel.h
//  PPOCMobile
//
//  Created by Omar Gómez on 6/2/14.
//  Copyright (c) 2014 Omar Gomez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCRelatedName : NSObject

@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSString *title;

@end

@interface PCMedium : NSObject

@property (nonatomic, strong) NSString *medium;
@property (nonatomic, strong) NSString *label;

@end

@interface PCNote : NSObject

@property (nonatomic, strong) NSString *note;
@property (nonatomic, strong) NSString *label;

@end

@interface PCSubject : NSObject

@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *title;

@end

@interface PCFormat : NSObject

@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *title;

@end


@interface PCCollectionItem : NSObject

@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *title;

@end


@interface PCItemSummaryModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *other_titles;
@property (nonatomic, strong) NSString *service_medium;

@property (nonatomic, strong) NSArray *related_names; // Related Names
@property (nonatomic, strong) NSArray *mediums; // Medium
@property (nonatomic, strong) NSString *reproduction_number; // Reproduction number
@property (nonatomic, strong) NSString *created_published_date; // Date Created/Published
@property (nonatomic, strong) NSString *rights_information; // Rights Advisory
@property (nonatomic, strong) NSString *restriction; // Access Advisory
@property (nonatomic, strong) NSString *call_number; // Call Number
@property (nonatomic, strong) NSString *repository; //Repository
@property (nonatomic, strong) NSString *part_of; // Part of

@property (nonatomic, strong) NSArray *notes; // Notes / Type
@property (nonatomic, strong) NSArray *subjects;// Subjects //type
@property (nonatomic, strong) NSArray *formats;// Format //type
@property (nonatomic, strong) NSArray *collections;// Collections



@end

@interface PCItemModel : NSObject

@property (nonatomic, strong) PCItemSummaryModel *item;

@end
