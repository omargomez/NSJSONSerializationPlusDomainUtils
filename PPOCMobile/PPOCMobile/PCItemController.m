//
//  PCItemController.m
//  PPOCMobile
//
//  Created by Omar Gómez on 6/2/14.
//  Copyright (c) 2014 Omar Gomez. All rights reserved.
//

#import "PCItemController.h"
#import "NSJSONSerialization+DomainUtils.h"
#import "PCItemModel.h"

@interface PCItemController ()

@property (nonatomic, strong) PCItemModel *model;
@property (nonatomic, strong) UIImage *headImage;
@property (nonatomic, strong) NSMutableArray* titleArr;
@property (nonatomic, strong) NSMutableArray* descArr;

-(void) loadData;

@end

@implementation PCItemController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) loadData
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error = nil;
        NSString *strUrl = [NSString stringWithFormat:@"http://www.loc.gov/pictures/collection/%@/item/%@/?fo=json", self.collection.code, self.item.pk];
        
        NSData *itemData = [NSData dataWithContentsOfURL:[NSURL URLWithString: strUrl] options:0 error:&error];
        
        void (^retry)() = ^void() {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Message"
                        message:@"Network error"
                       delegate:self
              cancelButtonTitle:@"Cancel"
              otherButtonTitles:@"Retry", nil];
            [alertView show];
        };
        
        
        if (itemData == nil) {
            retry();
            return;
        }
        
        PCItemModel *outSchema = [NSJSONSerialization ModelObjectWithData:itemData
                                                        options:0
                                                        suffixMap:@{
                                        @"$":[PCItemModel class],
                                        @".item":[PCItemSummaryModel class],
                                        @".item.related_names[]":[PCRelatedName class],
                                        @".item.mediums[]":[PCMedium class],
                                        @".item.notes[]":[PCNote class],
                                        @".item.subjects[]":[PCSubject class],
                                        @".item.formats[]":[PCFormat class],
                                        @".item.collections[]":[PCCollectionItem class]}
                                                        error:&error ];
        
        if (outSchema == nil) {
            retry();
            return;
        }
        
        NSURL *url = [NSURL URLWithString:outSchema.item.service_medium];
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (data != nil) {
            UIImage *original =[UIImage imageWithData:data];
            self.headImage = [UIImage imageWithData:data scale: original.size.width / 320 ];
        }
        else {
            self.headImage = [UIImage imageNamed:@"placeholder_item.png"];
        }
        
        void (^add)(NSString*,NSString*) = ^void(NSString* tit,NSString*val) {
            if (val != nil && [val length]>0) {
                [_titleArr addObject:tit ];
                [_descArr addObject:val ];
            }
        };
        
        void (^addFirst)(NSString*,NSArray*, SEL) = ^void(NSString* tit,NSArray* val, SEL sel) {
            if (val != nil && [val count]>0) {
                id first = [val objectAtIndex:0];
                
                if (first) {
                    NSString *str = [first performSelector:sel withObject:nil];
                    if ([str length] > 0) {
                        [_titleArr addObject:tit ];
                        [_descArr addObject:str ];
                    }
                }
                
            }
        };
        
        add( @"Title", outSchema.item.title );
        add( @"Other Title", outSchema.item.other_titles );
        addFirst( @"Related Names", outSchema.item.related_names, @selector(title));
        add( @"Date Created/Published", outSchema.item.created_published_date );
        addFirst( @"Medium", outSchema.item.mediums, @selector(medium));
        add( @"Reproduction number", outSchema.item.reproduction_number );
        add( @"Rights Advisory", outSchema.item.rights_information );
        add( @"Access Advisory", outSchema.item.restriction );
        add( @"Call Number", outSchema.item.call_number );
        add( @"Repository", outSchema.item.repository );
        addFirst( @"Notes", outSchema.item.notes, @selector(note));
        addFirst( @"Subjects", outSchema.item.subjects, @selector(title));
        addFirst( @"Formats", outSchema.item.formats, @selector(title));
        addFirst( @"Collections", outSchema.item.collections, @selector(title));
        add( @"Part of", outSchema.item.part_of );
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //TODO: fail vaidation
            self.model = outSchema;
            [self.tableView reloadData];
        });
        
    });
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.model = nil;
    self.titleArr = [NSMutableArray array];
    self.descArr = [NSMutableArray array];
    
    self.title = self.item.title;
    
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
    if (self.model == nil) {
        return 1;
    }
    else {
        return [self.titleArr count] + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.model == nil) {
        return [tableView dequeueReusableCellWithIdentifier:@"itemLoadingCell" forIndexPath:indexPath];
    }
    
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        // Head
        cell = [tableView dequeueReusableCellWithIdentifier:@"headImageCell" forIndexPath:indexPath];
        UIImageView *view = (UIImageView *)[cell viewWithTag:101];
        view.image = self.headImage;
        view.frame = CGRectMake(0, 0, self.headImage.size.width, self.headImage.size.height);
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"detailItemCell" forIndexPath:indexPath];
        cell.textLabel.text = [self.titleArr objectAtIndex:indexPath.row-1];
        cell.detailTextLabel.text =[self.descArr objectAtIndex:indexPath.row-1]; 
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat result = 44;
    if (self.model == nil) {
        result = 44;
    }
    else {
        
        if (indexPath.row == 0) {
            result = self.headImage.size.height;
        }
        else {
            result = 66;
        }
        
    }

    return result;
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
