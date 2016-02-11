//
//  TSGalleryCell.h
//  TOPsiOS
//
//  Created by Daniel Velasco on 12/4/15.
//  Copyright © 2015 Mindwards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface TSGalleryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageAsset;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLbl;

- (void)updateWithModel:(UIImage *)row  textDescription:(NSString*)text;
- (void)bind:(ALAssetsGroup *)assetsGroup showNumberOfAssets:(BOOL)showNumberOfAssets;
+ (NSString*)reuseIdentifier;
+ (UINib*)nib;
@end
