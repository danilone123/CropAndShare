//
//  TSGalleryCell.m
//  TOPsiOS
//
//  Created by Daniel Velasco on 12/4/15.
//  Copyright © 2015 Mindwards. All rights reserved.
//

#import "TSGalleryCell.h"

@implementation TSGalleryCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+ (NSString*)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (UINib*)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (void)updateWithModel:(UIImage *)row  textDescription:(NSString*)text
{
    self.imageAsset.image = row;
    self.descriptionLbl.text = text;
}

//will create rows based on assets from library
- (void)bind:(ALAssetsGroup *)assetsGroup showNumberOfAssets:(BOOL)showNumberOfAssets
{
    CGImageRef posterImage      = assetsGroup.posterImage;
    size_t height               = CGImageGetHeight(posterImage);
    float scale                 = height / (103 );
    
    self.imageAsset.image        = [UIImage imageWithCGImage:posterImage scale:scale orientation:UIImageOrientationUp];
    self.descriptionLbl.text     = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
    
    if (showNumberOfAssets)
        self.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)assetsGroup.numberOfAssets];
}

@end
