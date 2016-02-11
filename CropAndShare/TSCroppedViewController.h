//
//  TSCroppedViewController.h
//  TOPsiOS
//
//  Created by Daniel Velasco on 11/25/15.
//  Copyright © 2015 Mindwards. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSCroppedViewController : UIViewController<UIScrollViewDelegate>

@property (strong, nonatomic) UIImage *pickedImage;
@property (strong, nonatomic)  UIImageView *pickedImageViewTops;

@end
