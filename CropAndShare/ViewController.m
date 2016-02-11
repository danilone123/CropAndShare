//
//  ViewController.m
//  CropAndShare
//
//  Created by Daniel Velasco on 2/3/16.
//  Copyright © 2016 DoWhale. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
//#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "CASGalleryViewController.h"

@interface ViewController ()
typedef void (^TSFBSDKSucceded)(BOOL succeded);
@property (nonatomic, strong) FBSDKAccessToken * currentChildAccessToken;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithRed:27.0f/255.0f green:41.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
}

- (IBAction)goButton:(id)sender
{
    [self getFacebookImages];
}

- (void)getFacebookImages
{
    [self signInAsAChildIfNeededOnCompletion:^(BOOL succeded) {
        if (succeded) {
            [self showFacebookPhotos];
        }
    } onVC:self];
}

- (void)showFacebookPhotos
{
    __weak ViewController *weakSelf = self;
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/albums" parameters:@{@"fields":@"id,name,location,cover_photo,link"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSArray *list = [result objectForKey:@"data"];
                 
                 //weakSelf.containerView.hidden = NO;
                 //weakSelf.coverView.hidden = NO;
                 
                 CASGalleryViewController *menuVC  = [self.storyboard instantiateViewControllerWithIdentifier:@"album"];
                 menuVC.facebookAlbums = list;
                 UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:menuVC];
           
                 menuVC.title = @"Welcome!";
                
                // uinavigationi
                 UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
                
                  menuVC.navigationItem.leftBarButtonItem = done;

                 
                 [self presentViewController:nav animated:NO completion:nil];
                // nav.navigationBar.hidden = YES;
                 //    [[nav navigationBar] setTranslucent:NO];
                 //nav.view.translatesAutoresizingMaskIntoConstraints = NO;
                 //[nav willMoveToParentViewController:self];
              
                // [nav.view setFrame:frameT];
                 //[self.view addSubview:nav.view];
                 //[weakSelf.navigationController pushViewController:menuVC animated:NO];
             }
         }];
    }
}

- (void)doneButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:NO
                             completion:nil];
    //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];
    
}
-(void)signInAsAChildIfNeededOnCompletion:(TSFBSDKSucceded)onCompletion onVC:(UIViewController*)onVC
{
    
    [self signInIfNeededOnCompletion:^(BOOL succeded) {
        FBSDKAccessToken * accessToken = [FBSDKAccessToken currentAccessToken];
        if (![accessToken isEqualToAccessToken:self.currentChildAccessToken]) {
            self.currentChildAccessToken = accessToken;
            NSLog(@"currentChildAccessToken:%@", self.currentChildAccessToken);
        }
        onCompletion(succeded);
    }];
   
}

-(void)signInIfNeededOnCompletion:(TSFBSDKSucceded)onCompletion
{
    FBSDKAccessToken * accessToken = [FBSDKAccessToken currentAccessToken];
    if (!accessToken) {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        login.loginBehavior = FBSDKLoginBehaviorWeb;
        login.defaultAudience = FBSDKDefaultAudienceFriends;
        [login logInWithReadPermissions:@[@"public_profile", @"email",@"user_photos"]
                     fromViewController:self
                                handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
         {
             BOOL succeded = (!(error || result.isCancelled));
             if (succeded) {
                 NSLog(@"SIGN IN OK accessToken: %@", [[result token] tokenString]);
             } else {
                 NSLog(@"SIGN IN ERROR");
             }
             onCompletion(succeded);
         }];
    } else {
        onCompletion(YES);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
