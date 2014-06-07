//
//  PCItemController.h
//  PPOCMobile
//
//  Created by Omar Gómez on 6/2/14.
//  Copyright (c) 2014 Omar Gomez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCSearchItem.h"
#import "PCCollectionModel.h"

@interface PCItemController : UITableViewController <UIAlertViewDelegate>

@property(nonatomic, strong) PCSearchItem *item;
@property (nonatomic, strong) PCCollectionModel *collection;

@end
