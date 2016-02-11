//
//  TSAssetsViewCell.h
//  TSImagePicker
//
//  Created by Daniel Velasco on 11/7/14.
//  Copyright (c) 2014 Mindwards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface TSAssetsViewCell : UICollectionViewCell

@property (nonatomic, assign, getter = isEnabled) BOOL enabled;

- (void)bind:(ALAsset *)asset;
- (void)bindFacebook:(UIImage *)asset;

@end
