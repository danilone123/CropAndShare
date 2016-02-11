//
//  CASShareViewController.m
//  CropAndShare
//
//  Created by Daniel Velasco on 2/10/16.
//  Copyright © 2016 DoWhale. All rights reserved.
//

#import "CASShareViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface CASShareViewController ()<FBSDKSharingDelegate>


@end

@implementation CASShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pickedImageViewTops.image = self.imageShare;
    self.view.backgroundColor = [UIColor colorWithRed:27.0f/255.0f green:41.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
}
- (IBAction)shareBtn:(id)sender
{
    //FBSDKShareLinkContent * content = [[FBSDKShareLinkContent alloc] init];
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc]init];
    photo.image = self.imageShare;
    photo.userGenerated = YES;
    FBSDKSharePhotoContent *photoShare = [[FBSDKSharePhotoContent alloc] init];
    [photoShare setPhotos:[NSArray arrayWithObjects:photo, nil]];
//    photoShare.photos = {self.imageShare};
//    if (urlString) {
//        content.contentURL = [NSURL URLWithString:urlString];
//    }
    
//    if (message) {
//        content.contentDescription = message;
//    }
    
    FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc] init];
    shareDialog.mode = FBSDKShareDialogModeBrowser;
    shareDialog.fromViewController = self;
    shareDialog.shareContent = photoShare;
    shareDialog.delegate = self;
    
    if ([shareDialog canShow]) {
        [shareDialog show];
    }

}

#pragma mark - FBSDKSharingDelegate

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    //TRACE(@"FB didCompleteWithResults:%@", results);
    
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    //TRACE(@"FB didFailWithError:%@", error);
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    //TRACE(@"FB sharerDidCancel by user");
}


@end
