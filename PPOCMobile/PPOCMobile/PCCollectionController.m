//
//  PCCollectionController.m
//  PPOCMobile
//
//  Created by Omar Gómez on 5/30/14.
//  Copyright (c) 2014 Omar Gomez. All rights reserved.
//

#import "PCCollectionController.h"
#import "PCSearchModel.h"
#import "PCSearchItem.h"
#import "NSJSONSerialization+DomainUtils.h"
#import "PCItemController.h"

@interface PCCollectionController ()

@property (nonatomic, strong) PCSearchModel *model;

-(void) loadData;

@end

@implementation PCCollectionController

-(void) loadData
{
     dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error = nil;
        NSString *strUrl = [NSString stringWithFormat:@"http://www.loc.gov/pictures/search/?co=%@&fo=json&c=100", self.collection.code];
        
        NSData *collData = [NSData dataWithContentsOfURL:[NSURL URLWithString: strUrl] options:0 error:&error];
        
        if (collData == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Message"
                            message:@"Network error"
                           delegate:self
                  cancelButtonTitle:@"Cancel"
                  otherButtonTitles:@"Retry", nil];
                [alertView show];
            });
            return;
        }
        
        PCSearchModel *outSchema = [NSJSONSerialization ModelObjectWithData:collData
                                                        options:0
                                                        suffixMap:@{
                                        @"$":[PCSearchModel class],
                                        @".results[]":[PCSearchItem class],
                                        @".results[].image":[PCSearchItemImage class] }
                                                        error:&error ];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"dispatch_get_main_queue");
            self.model = outSchema;
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
    self.title = self.collection.title;
    self.model = nil;
    self.tableView.allowsSelection = NO;

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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //TODO: more validation?
    // Return the number of rows in the section.
    if (self.model) {
        return [self.model.results count];
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.model == nil) {
        return [tableView dequeueReusableCellWithIdentifier:@"collectionLoadingCell" forIndexPath:indexPath];
        
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemCell" forIndexPath:indexPath];
    
    // Configure the cell...
    PCSearchItem *item = self.model.results[ indexPath.row ];
    
    cell.textLabel.text = item.title;
    
    UIImage *img =[UIImage imageNamed:@"placeholder_item.png"];
    cell.imageView.image = img;
    
    if (cell.tag != -1) {
        //load image asynch
        cell.tag = -1;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *s =[[item image] square];
            NSLog(@"s: %@",s);
            NSURL *url = [NSURL URLWithString: s];
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.tag = 0;
                NSIndexPath *laterIndexPath = [tableView indexPathForCell:cell];
                if (data && laterIndexPath && laterIndexPath.row == indexPath.row) {
                    NSLog(@"datalen:%d", [data length]);
                    cell.imageView.image = [UIImage imageWithData:data];
                }
                else {
                    if (laterIndexPath) {
                     [tableView reloadRowsAtIndexPaths:@[laterIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }
            });
            
        });
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    
    //PCCollectionModel *coll = self.homeModel.collections[ indexPath.row ];
    PCSearchItem *item = self.model.results[ indexPath.row ];
    [self performSegueWithIdentifier:@"itemSegue" sender:item];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    PCItemController *itemCtrlr = segue.destinationViewController;
    itemCtrlr.item = sender;
    itemCtrlr.collection = self.collection;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			[self.navigationController popViewControllerAnimated:YES];
			break;
		case 1:
			[self loadData];
			break;
            
		default:
			break;
	}
}
@end
