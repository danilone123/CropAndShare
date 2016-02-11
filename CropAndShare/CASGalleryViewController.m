//
//  CASGalleryViewController.m
//  CropAndShare
//
//  Created by Daniel Velasco on 2/4/16.
//  Copyright © 2016 DoWhale. All rights reserved.
//

#import "CASGalleryViewController.h"
#import "TSGalleryCell.h"
#import "CASListViewController.h"

@interface CASGalleryViewController ()

@end

@implementation CASGalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableContainer.delegate = self;
    self.tableContainer.dataSource = self;
    self.tableContainer.backgroundColor = [UIColor colorWithRed:27.0f/255.0f green:41.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
    [self setupViews];
    [self.tableContainer registerNib:[TSGalleryCell nib]
              forCellReuseIdentifier:[TSGalleryCell reuseIdentifier]];
    [self setupViews];
    self.imagesDownloaded = [NSMutableDictionary dictionary];
    [self.tableContainer reloadData];
}

#pragma mark - Reload Data

- (void)setupViews
{
    self.tableContainer.rowHeight = 65.0f;//IS_IPAD? 85.0f : 50.0f;
    self.tableContainer.separatorStyle = UITableViewCellSeparatorStyleNone;
}


#pragma mark - table delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.facebookAlbums?self.facebookAlbums.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TSGalleryCell *cell = [tableView dequeueReusableCellWithIdentifier:[TSGalleryCell reuseIdentifier]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor clearColor];

    NSDictionary *dict = [self.facebookAlbums objectAtIndex:indexPath.row];
    UIImage *im = [self.imagesDownloaded objectForKey:[dict objectForKey:@"id"]];
    [cell updateWithModel:im?im:[UIImage imageNamed:@"iphone_launcher_photo_tooltip_icon_album"] textDescription:[dict objectForKey:@"name"]];
    if (!im)
    {
        __weak CASGalleryViewController *weakSelf = self;
        [[[FBSDKGraphRequest alloc] initWithGraphPath:[NSString stringWithFormat:@"/%@?fields=picture", [dict objectForKey:@"id"]] parameters:nil]
             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (!error)
                 {
                     dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                     dispatch_async(q, ^{
                         /* Fetch the image from the server... */
                         NSDictionary *pictureData  = [result valueForKey:@"picture"];
                         
                         NSDictionary *redata = [pictureData valueForKey:@"data"];
                         
                         NSString *urlCover = [redata valueForKey:@"url"];
                         NSURL *strUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@",urlCover]];
                         
                         NSData *data = [NSData dataWithContentsOfURL:strUrl];
                         UIImage *img = [[UIImage alloc] initWithData:data];
                         [weakSelf.imagesDownloaded setObject:img forKey:[dict objectForKey:@"id"]];
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             
                             cell.imageAsset.image = img;
                             
                         });
                     });
                 }
             }];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.facebookAlbums)
    {
        NSDictionary *dict = [self.facebookAlbums objectAtIndex:indexPath.row];
        NSString *strAlbumid = [NSString stringWithFormat:@"%@/photos",[dict objectForKey:@"id"]];
        __weak CASGalleryViewController *weakSelf = self;
        
        tableView.userInteractionEnabled = NO;
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                      initWithGraphPath:strAlbumid
                                      parameters:@{@"fields":@"id,created_time"}
                                      HTTPMethod:@"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                              id result,
                                              NSError *error) {
            tableView.userInteractionEnabled = YES;
            NSDictionary *data = [result valueForKey:@"data"];
            
            NSArray *arrayId = [data valueForKey:@"id"];
            
            
            CASListViewController *vc  = [self.storyboard instantiateViewControllerWithIdentifier:@"list"];
            //weakSelf.navigationController.navigationBar.hidden = YES;
           // vc.titleHeader = [dict objectForKey:@"name"];
            vc.listIdsFacebook = arrayId;
            
            //[weakSelf presentViewController:vc animated:NO completion:nil];
            [weakSelf.navigationController pushViewController:vc animated:YES];
            
        }];
    }
}

@end
