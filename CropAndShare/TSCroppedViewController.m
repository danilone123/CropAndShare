//
//  TSCroppedViewController.m
//  TOPsiOS
//
//  Created by Daniel Velasco on 11/25/15.
//  Copyright © 2015 Mindwards. All rights reserved.
//

#import "TSCroppedViewController.h"
#import "CASShareViewController.h"

#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define kMarginButton   30
#define  kHeightBottomView 80
#define  kSizeButtons  60
#define kSizeCroppedView (IS_IPAD ? 400 : 250)
#define kBorderWidth 5
@interface TSCroppedViewController ()

@property (strong, nonatomic)  UIScrollView *pickedImageScrollView;
@property (assign) int leftPadding;
@property (assign) int rightPadding;
@property (assign) int topPadding;
@property (assign) int bottomPadding;
@property (strong, nonatomic) IBOutlet UIView *croppedView;
@property (assign) int imgWidth;
@property (strong, nonatomic) IBOutlet UIView *bacgroundCropped;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (assign) int imgHeight;
@property (strong, nonatomic) UIImageView *imageOk;
@property (strong, nonatomic) CALayer *transParentLayer;

@end

@implementation TSCroppedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildBottomView];
   // CGRect frameDevice = [[UIScreen mainScreen] bounds];
    self.pickedImageScrollView =[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - kHeightBottomView )];
    self.bacgroundCropped = [[UIView alloc] initWithFrame:CGRectZero];
    self.croppedView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.bacgroundCropped];
    [self.view addSubview: self.croppedView];
    self.bacgroundCropped.translatesAutoresizingMaskIntoConstraints = YES;
    self.croppedView.translatesAutoresizingMaskIntoConstraints = YES;
    self.bacgroundCropped.userInteractionEnabled = NO;
    self.croppedView.userInteractionEnabled = NO;
    self.pickedImageScrollView.translatesAutoresizingMaskIntoConstraints = YES;
    // self.pickedImageScrollView =[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1000, 600 )];
    
    self.pickedImageScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.pickedImageScrollView];
    
}

- (void)buildBottomView
{
    self.bottomView = [[UIView alloc] init];
    self.bottomView.translatesAutoresizingMaskIntoConstraints  =YES;
    [self.view addSubview:self.bottomView];
    self.bottomView.frame = CGRectMake(0, self.view.frame.size.height-kHeightBottomView, self.view.frame.size.width, kHeightBottomView);
    self.bottomView.backgroundColor = [UIColor colorWithRed:16.0/255.0f green:33.0f/255.0f blue:43.0/255.0f alpha:1.0f];
   
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(aceptImage:)];
    UITapGestureRecognizer *tapGestureCancel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel:)];
    
    self.imageOk = [[UIImageView alloc] init];
    self.imageOk.userInteractionEnabled = YES;
    [self.imageOk addGestureRecognizer:tapGestureRecognizer];
    self.imageOk.clipsToBounds = YES;
    self.imageOk.contentMode = UIViewContentModeScaleAspectFit;
    self.imageOk.frame =CGRectMake(self.view.frame.size.width-kMarginButton-kSizeButtons, (kHeightBottomView - kSizeButtons)/2, kSizeButtons, kSizeButtons);
    self.imageOk.image = [UIImage imageNamed:@"iphone_ok_cropped"];
    [self.bottomView addSubview:self.imageOk];
    
    UIImageView *imageCancel = [[UIImageView alloc] init];
    imageCancel.userInteractionEnabled= YES;
    [imageCancel addGestureRecognizer:tapGestureCancel];
    imageCancel.clipsToBounds = YES;
    imageCancel.contentMode = UIViewContentModeScaleAspectFit;
    imageCancel.frame =CGRectMake(kMarginButton, (kHeightBottomView - kSizeButtons)/2, kSizeButtons, kSizeButtons);
    imageCancel.image = [UIImage imageNamed:@"iphone_cancel_cropped"];
    [self.bottomView addSubview:imageCancel];
    [self.view bringSubviewToFront:self.bottomView];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    //[self centerCroppedViews];
    
    self.pickedImageViewTops = nil;
    self.pickedImageViewTops=[[UIImageView alloc]initWithImage:self.pickedImage];
    [self.pickedImageScrollView addSubview:self.pickedImageViewTops];
    
    self.pickedImageScrollView.minimumZoomScale=0.1;
    self.pickedImageScrollView.maximumZoomScale=2.0;
    self.pickedImageScrollView.delegate=self;
    self.pickedImageScrollView.userInteractionEnabled=YES;
    self.pickedImageScrollView.canCancelContentTouches = YES;
    self.pickedImageScrollView.scrollEnabled = YES;
    self.pickedImageViewTops.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
    
    [self frameCroppedViews];
    [self calculateEdges];
    
    self.imgWidth = self.pickedImage.size.width;
    self.imgHeight = self.pickedImage.size.height;
    if (self.imgWidth <kSizeCroppedView)
    {
        self.imgWidth = kSizeCroppedView;
    }
    if (self.imgHeight < kSizeCroppedView)
    {
        self.imgHeight = kSizeCroppedView;
    }
    
   // self.pickedImageViewTops.sizeToFit =CGSizeMake(self.imgWidth, self.imgHeight);
    //[self.pickedImageViewTops ]
    //self.pickedImageViewTops.size = CGSizeMake(self.imgWidth, self.imgHeight);
    
    self.pickedImageScrollView.minimumZoomScale=[self calculateSizeFactor:self.pickedImageScrollView.frame : CGSizeMake(self.imgWidth, self.imgHeight)];
    
    //[self.croppedView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [self fitToFrame];
    
    [self.pickedImageScrollView setContentSize:CGSizeMake((self.imgWidth*self.pickedImageScrollView.zoomScale)+self.leftPadding+self.rightPadding, (self.imgHeight*self.pickedImageScrollView.zoomScale)+self.topPadding+self.bottomPadding)];
    //(self.imgHeight*self.pickedImageScrollView.zoomScale)+self.topPadding+self.bottomPadding)
    
    
    //[[self.bacgroundCropped layer] setBorderWidth:kBorderWidth];
    //[[self.bacgroundCropped layer] setCornerRadius:420/2];
   	//[[self.bacgroundCropped layer] setBorderColor:[[UIColor whiteColor]CGColor]];
    
    [self.view bringSubviewToFront:self.bottomView];
    [self.view bringSubviewToFront:self.bacgroundCropped];
    [self.view bringSubviewToFront:self.croppedView];
    [self.view sendSubviewToBack:self.pickedImageScrollView];
    
    [self.pickedImageScrollView setShowsHorizontalScrollIndicator:FALSE];
    [self.pickedImageScrollView setShowsVerticalScrollIndicator:FALSE];
    
    [self.pickedImageViewTops setFrame:CGRectMake(self.leftPadding, self.topPadding, self.pickedImageViewTops.frame.size.width, self.pickedImageViewTops.frame.size.height)];
    
    self.pickedImageScrollView.backgroundColor = [UIColor colorWithRed:27.0f/255.0f green:41.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
    CGRect newFrame = self.pickedImageScrollView.frame;
    newFrame.size.width -= (self.leftPadding+self.rightPadding);
    newFrame.size.height -= (self.topPadding+self.bottomPadding);
    self.pickedImageScrollView.minimumZoomScale=[self calculateSizeFactor:newFrame : CGSizeMake(self.imgWidth, self.imgHeight)];
    
    [self addCoverLayer];
    // Do any additional setup after loading the view from its nib.
    
}
#pragma mark - Size cropped views

- (void)frameCroppedViews
{
    self.bacgroundCropped.translatesAutoresizingMaskIntoConstraints = YES;
    self.croppedView.translatesAutoresizingMaskIntoConstraints = YES;
    CGRect frame = self.bacgroundCropped.frame;
    frame.size.width = (kBorderWidth*2) + kSizeCroppedView;
    frame.size.height = frame.size.width;
    
    self.bacgroundCropped.frame = frame;
    frame = self.croppedView.frame;
    frame.size.width = kSizeCroppedView;
    frame.size.height = kSizeCroppedView;
    self.croppedView.frame = frame;
    [self centerCroppedViews];
    
    [[self.bacgroundCropped layer] setBorderWidth:kBorderWidth];
    [[self.bacgroundCropped layer] setCornerRadius:self.bacgroundCropped.frame.size.width/2];
   	[[self.bacgroundCropped layer] setBorderColor:[[UIColor whiteColor]CGColor]];
}

- (void)centerCroppedViews
{
    self.bacgroundCropped.center = self.pickedImageScrollView.center;
    self.croppedView.center = self.pickedImageScrollView.center;
}

- (void)calculateEdges
{
    self.leftPadding = kBorderWidth + self.bacgroundCropped.frame.origin.x;
    self.rightPadding = self.pickedImageScrollView.frame.size.width - (self.croppedView.frame.origin.x + self.croppedView.frame.size.width);
    self.topPadding = kBorderWidth + self.bacgroundCropped.frame.origin.y;
    self.bottomPadding = self.pickedImageScrollView.frame.size.height - (self.croppedView.frame.origin.y + self.croppedView.frame.size.height);
}

-(void)fitToFrame
{
    
    //[scroller setZoomScale:[self calculateSizeFactor:scroller.frame : CGSizeMake(imgWidth, imgHeight)]];
    
    if(self.pickedImageScrollView.zoomScale > self.pickedImageScrollView.minimumZoomScale)
        [self.pickedImageScrollView setZoomScale:self.pickedImageScrollView.minimumZoomScale animated:NO];
    else
        [self.pickedImageScrollView setZoomScale:self.pickedImageScrollView.maximumZoomScale animated:NO];
    
    //will put y position in the middle of the view
    double yOffset = (self.pickedImageScrollView.frame.size.height - (self.imgHeight*self.pickedImageScrollView.zoomScale))/2;
    
    //will put x position in the middle if it is smaller than current scroll size
    double xOffset = (self.pickedImageScrollView.frame.size.width - (self.imgWidth * self.pickedImageScrollView.zoomScale))/2;
    
    
    [self.pickedImageScrollView setContentOffset:CGPointMake(self.leftPadding-xOffset, self.topPadding-yOffset)];
    
    [self resetPositions];
}

-(void)resetPositions
{
    CGRect frame = self.pickedImageViewTops.frame;
    frame.origin.x = self.leftPadding;
    frame.origin.y = self.topPadding;
    
    [self.pickedImageScrollView setContentSize:CGSizeMake((self.imgWidth*self.pickedImageScrollView.zoomScale)+self.leftPadding+self.rightPadding, (self.imgHeight*self.pickedImageScrollView.zoomScale)+self.topPadding+self.bottomPadding)];
    
    [self.pickedImageViewTops setFrame:frame];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.pickedImageScrollView.bounds.size;
    CGRect contentsFrame = self.pickedImageViewTops.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
        
    }
    
    self.pickedImageViewTops.frame = contentsFrame;
}

-(double)calculateSizeFactor:(CGRect)mFrame :(CGSize)imageSize
{
    double lScaleFactor = MAX((mFrame.size.width)/imageSize.width, (mFrame.size.height)/imageSize.height);
    if(lScaleFactor>1) {
        lScaleFactor = 1;
    }
    return lScaleFactor;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.pickedImageViewTops;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self resetPositions];
     // [self centerScrollViewContents];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self resetPositions];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         self.pickedImageScrollView.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - kHeightBottomView );
         self.bottomView.frame = CGRectMake(0, self.view.frame.size.height-kHeightBottomView, self.view.frame.size.width, kHeightBottomView);
         self.imageOk.frame = CGRectMake(self.view.frame.size.width-kMarginButton-kSizeButtons, (kHeightBottomView - kSizeButtons)/2, kSizeButtons, kSizeButtons);
         [self centerCroppedViews];
         [self calculateEdges];
         [self resetPositions];
         
         [self addCoverLayer];
         
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         if (orientation == UIInterfaceOrientationLandscapeLeft) {
             //NSLog(@"Landscape left");
             
             
         } else if (orientation == UIInterfaceOrientationLandscapeRight) {
             //NSLog(@"Landscape right");
             
             
         } else {
             //NSLog(@"Portrait");
             
         }
         
         
         
         
     }
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


- (void)cancel:(UITapGestureRecognizer *)sender
{
    self.parentViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    /*[self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    */
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)aceptImage:(UITapGestureRecognizer *)sender
{
    self.navigationController.navigationBar.hidden = NO;
    self.parentViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.bacgroundCropped.hidden=YES;
    CGRect frame = self.croppedView.frame;
    
    CGContextRef c;
    
    frame.size.width = kSizeCroppedView;
    frame.size.height = kSizeCroppedView;
    UIGraphicsBeginImageContext(frame.size);
    c = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(c,- self.croppedView.frame.origin.x,-self.croppedView.frame.origin.y);
    
   
    [self.view.layer renderInContext:c];
    
    UIImage *saveImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CASShareViewController *vc  = [sb instantiateViewControllerWithIdentifier:@"share"];
    vc.imageShare = saveImage;
    [self.navigationController pushViewController:vc animated:NO];

    /*
    TSPhotoManagerViewController *photoVC = (TSPhotoManagerViewController*)self.parentViewController;
    photoVC.containerView.hidden = YES;
    [photoVC setImageForCurrentView:saveImage];
 
    [photoVC removeChildVC];
    self.bacgroundCropped.hidden=NO;
     */
    
}

#pragma  mark - CALayer

- (void)addCoverLayer
{
    int radius = ((kBorderWidth*2) + kSizeCroppedView)/2;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.pickedImageScrollView.bounds.size.width, self.pickedImageScrollView.bounds.size.height) cornerRadius:0];
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.bacgroundCropped.frame.origin.x, self.bacgroundCropped.frame.origin.y, 2.0*radius, 2.0*radius) cornerRadius:radius];
    [path appendPath:circlePath];
    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor blackColor].CGColor;
    fillLayer.opacity = 0.5;
    [self.transParentLayer removeFromSuperlayer];
    self.transParentLayer = fillLayer;
    [self.view.layer addSublayer:fillLayer];
}

@end
