//
//  PCMainController.m
//  PPOCMobile
//
//  Created by Omar Gómez on 5/29/14.
//  Copyright (c) 2014 Omar Gomez. All rights reserved.
//

#import "PCMainController.h"
#import "NSJSONSerialization+DomainUtils.h"
#import "PCHomeModel.h"
#import "PCCollectionModel.h"
#import "PCCollectionController.h"

@interface PCMainController ()

@property (nonatomic, strong) PCHomeModel *homeModel;

-(void) loadData;

@end

@implementation PCMainController

-(void) loadData
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error = nil;
        NSData *homeData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://loc.gov/pictures/?fo=json"] options:0 error:&error];
        
        if (homeData == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Message"
                            message:@"Network error"
                           delegate:self
                  cancelButtonTitle:@"Cancel"
                  otherButtonTitles:@"Retry", nil];
                [alertView show];
            });
            return ;
        }
        
        PCHomeModel *outSchema = [NSJSONSerialization ModelObjectWithData:homeData
                                                        options:0
                                                        suffixMap:@{
                                        @"$":[PCHomeModel class],
                                        @".collections[]":[PCCollectionModel  class] }
                                                        error:&error ];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.homeModel = outSchema;
            self.tableView.allowsSelection = YES;
            [self.tableView reloadData];
        });
        
    });
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Prints & Photographs Online Catalog";
    self.tableView.allowsSelection = NO;
    
    // Load home data
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.homeModel != nil) {
        return [self.homeModel.collections count];
    }
    else {
        return 1;
    }
        
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.homeModel == nil) {
        return [tableView dequeueReusableCellWithIdentifier:@"homeLoadingCell" forIndexPath:indexPath];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homeCell" forIndexPath:indexPath];
    
    // Configure the cell...
    PCCollectionModel *coll = self.homeModel.collections[ indexPath.row ];
    
    cell.textLabel.text = coll.title;
    
    cell.imageView.image = [UIImage imageNamed:@"placeholder_home_large.png"];
    
    if (cell.tag != -1) {
        cell.tag = -1;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSURL *url = [NSURL URLWithString:coll.thumb_large];
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.tag = 0;
                NSIndexPath *laterIndex = [tableView indexPathForCell:cell];
                if ( data && laterIndex && laterIndex.row == indexPath.row ) {
                    cell.imageView.image = [UIImage imageWithData:data];
                }
                else {
                    if (laterIndex) {
                     [tableView reloadRowsAtIndexPaths:@[laterIndex] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }
            });
        });
        
    }
    else {
        NSLog(@"Didnt load: cell:%d, index:%d", cell.tag , indexPath.row+1);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    PCCollectionModel *coll = self.homeModel.collections[ indexPath.row ];
    [self performSegueWithIdentifier:@"collectionSegue" sender:coll];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PCCollectionController *ctllr = (PCCollectionController*) segue.destinationViewController;
    
    ctllr.collection = sender;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			exit(0);
			break;
		case 1:
			[self loadData];
			break;
            
		default:
			break;
	}
}

@end
