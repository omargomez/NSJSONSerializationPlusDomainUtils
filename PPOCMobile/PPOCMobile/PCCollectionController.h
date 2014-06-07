//
//  PCCollectionController.h
//  PPOCMobile
//
//  Created by Omar Gómez on 5/30/14.
//  Copyright (c) 2014 Omar Gomez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCCollectionModel.h"

@interface PCCollectionController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic, strong) PCCollectionModel *collection;

@end
