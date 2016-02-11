//
//  CASListViewController.m
//  CropAndShare
//
//  Created by Daniel Velasco on 2/4/16.
//  Copyright © 2016 DoWhale. All rights reserved.
//

#import "CASListViewController.h"
//#import "FBSDKCoreKit/FBSDKCoreKit.h"
//#import "FBSDKCoreKit.h"
//#import "FBSDKCoreKit.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "TSAssetsViewCell.h"
#import "TSCroppedViewController.h"

#define CTScreenSize [[UIScreen mainScreen] bounds].size
#define CTScreenHeight MAX(CTScreenSize.width, CTScreenSize.height)
#define CTIPhone6 (CTScreenHeight == 667)
#define CTIPhone6Plus (CTScreenHeight == 736)

@interface CASListViewController ()
@property (nonatomic, strong) NSMutableDictionary *imagesDownloaded;
@end

@implementation CASListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imagesDownloaded = [NSMutableDictionary dictionary];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.allowsMultipleSelection = NO;//27 41   50
    self.collectionView.backgroundColor = [UIColor colorWithRed:27.0f/255.0f green:41.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(doneButtonTapped:)];
    self.navigationItem.leftBarButtonItem = done;
    self.title = @"Select your image!";
    

    [self.collectionView registerClass:TSAssetsViewCell.class
            forCellWithReuseIdentifier:@"TSAssetsViewCellIdentifier"];
}

- (void)doneButtonTapped:(id)sender {
    
    //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
     [self.navigationController popViewControllerAnimated:YES];
    
}

- (UICollectionViewFlowLayout *)collectionViewFlowLayoutOfOrientation:(UIInterfaceOrientation)orientation
{
    //self.collectionView.frame = CGRectMake(0, 50, 300, 250);
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat space = 10;
    CGFloat  widthCel= 80;//(self.collectionView.frame.size.width/3) - (10*2) - (10*2);
    layout.itemSize             = CGSizeMake(widthCel, 70);
    // layout.footerReferenceSize  = CGSizeMake(0, 40.0);
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            layout.sectionInset            = UIEdgeInsetsMake(9.0, 2.0, 10, 2.0);
            layout.minimumInteritemSpacing = (CTIPhone6Plus) ? 1.0 : ( (CTIPhone6) ? 2.0 : 3.0 );
            layout.minimumLineSpacing      = (CTIPhone6Plus) ? 1.0 : ( (CTIPhone6) ? 2.0 : 3.0 );
        }
        else
        {
            layout.sectionInset            = UIEdgeInsetsMake(15.0f,30, 10, 30);
            layout.minimumInteritemSpacing = space;//(CTIPhone6Plus) ? 0.5 : ( (CTIPhone6) ? 1.0 : 2.0 );
            layout.minimumLineSpacing      = space;//(CTIPhone6Plus) ? 0.5 : ( (CTIPhone6) ? 1.0 : 2.0 );
        }
    }
    else
    {
        layout.sectionInset            = UIEdgeInsetsMake(9.0, 5.0, 10, 5.0);
        layout.minimumInteritemSpacing = (CTIPhone6Plus) ? 0.5 : ( (CTIPhone6) ? 1.0 : 2.0 );
        layout.minimumLineSpacing      = 10.0;
        
    }
    
    return layout;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TSAssetsViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"TSAssetsViewCellIdentifier"
                                              forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
   
        
    NSString *idImage = [self.listIdsFacebook objectAtIndex:indexPath.row];
    UIImage *im = [self.imagesDownloaded objectForKey:idImage];
    [cell bindFacebook:im?im:[UIImage imageNamed:@"iphone_launcher_photo_tooltip_icon_album"]];
    if (!im)
    {//fields=picture.height(500),picture.width(500)
            __weak CASListViewController *weakSelf = self;
            NSString *strAlbumid = [NSString stringWithFormat:@"/%@/?fields=images.height(426)",idImage];
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                          initWithGraphPath:strAlbumid
                                          parameters:nil
                                          HTTPMethod:@"GET"];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                  id result,
                                                  NSError *error)
             {
                 
                 
                 NSArray * picture_images = [result valueForKey:@"images"];
                 
                 
                 NSMutableArray *picCount = [picture_images objectAtIndex:picture_images.count - 1];
                 __block NSString *source =[picCount valueForKey:@"source"] ;
                 [picture_images enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     NSDictionary *dict =(NSDictionary *)obj;
                     CGFloat width = [[dict objectForKey:@"width"] floatValue];
                     if (width< 600 &&  width > 400)// range of px images app needs
                     {
                         source = [dict objectForKey:@"source"];
                         *stop = YES;
                     }
                 }];
                 
                 
                 
                 
                 NSURL *strUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@",source]];
                 
                 
                 dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                 dispatch_async(q, ^{
                     /* Fetch the image from the server... */
                     NSData *data = [NSData dataWithContentsOfURL:strUrl];
                     UIImage *img = [[UIImage alloc] initWithData:data];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (img)
                         {
                             [cell bindFacebook:img];
                             [cell setNeedsDisplay];
                             [weakSelf.imagesDownloaded setObject:img forKey:idImage];
                         }
                     });
                 });
             }];
        }
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.listIdsFacebook?self.listIdsFacebook.count : 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.listIdsFacebook)
    {
        NSString *idImage = @"";
        idImage = [self.listIdsFacebook objectAtIndex:indexPath.row];
        UIImage *image = [self.imagesDownloaded objectForKey:idImage];
        if (image)
        {
            
            [self goToCropped:image];
        }
   
    }
}

- (void)goToCropped :(UIImage *)image
{
    TSCroppedViewController *croppedVC = [[TSCroppedViewController alloc] init];
    
    //[croppedVC willMoveToParentViewController:self.navigationController.parentViewController];
    
    croppedVC.pickedImage = image;
    UIView *parentView= [[self.navigationController parentViewController] view];
    croppedVC.view.translatesAutoresizingMaskIntoConstraints =YES;
   // parentView.translatesAutoresizingMaskIntoConstraints = YES;
    //croppedVC.view.frame = CGRectMake(0, 0, parentView.frame.size.width, parentView.frame.size.height);
    
    [self.navigationController pushViewController:croppedVC animated:NO];
    // croppedVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    //[parentView addSubview:croppedVC.view];
    //[self.navigationController.parentViewController addChildViewController:croppedVC];
    //[croppedVC didMoveToParentViewController:self.navigationController.parentViewController];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
