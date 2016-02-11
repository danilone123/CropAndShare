//
//  CASGalleryViewController.h
//  CropAndShare
//
//  Created by Daniel Velasco on 2/4/16.
//  Copyright © 2016 DoWhale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface CASGalleryViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (nonatomic, strong) NSMutableDictionary *imagesDownloaded;
@property (weak, nonatomic) IBOutlet UITableView *tableContainer;
@property (nonatomic, strong) NSArray *facebookAlbums;

@end
