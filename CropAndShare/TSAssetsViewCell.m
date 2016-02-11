//
//  TSAssetsViewCell.m
//  TSImagePicker
//
//  Created by Daniel Velasco on 11/7/14.
//  Copyright (c) 2014 Mindwards. All rights reserved.
//

#import "TSAssetsViewCell.h"


@interface TSAssetsViewCell ()

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *videoImage;

@end


@implementation TSAssetsViewCell

static UIFont *titleFont;
static CGFloat titleHeight;
//static UIImage *videoIcon;
static UIColor *titleColor;
static UIImage *checkedIcon;
static UIColor *selectedColor;
static UIColor *disabledColor;

+ (void)initialize
{
    titleFont       = [UIFont systemFontOfSize:12];
    titleHeight     = 20.0f;
    titleColor      = [UIColor whiteColor];
    checkedIcon     = [UIImage imageNamed:@"CTAssetsPickerChecked"];
    selectedColor   = [UIColor colorWithWhite:1 alpha:0.3];
    disabledColor   = [UIColor colorWithWhite:1 alpha:0.9];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.opaque                 = YES;
        self.isAccessibilityElement = YES;
        self.accessibilityTraits    = UIAccessibilityTraitImage;
        self.enabled                = YES;
    }
    
    return self;
}

- (void)bind:(ALAsset *)asset
{
    self.asset  = asset;
    self.image  = (asset.thumbnail == NULL) ? [UIImage imageNamed:@"CTAssetsPickerEmptyCell"] : [UIImage imageWithCGImage:asset.thumbnail];
}

- (void)bindFacebook:(UIImage *)asset
{
    self.image = asset;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setNeedsDisplay];
}


#pragma mark - Draw Rect

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self drawThumbnailInRect:rect];
    
}

- (void)drawThumbnailInRect:(CGRect)rect
{
    [self.image drawInRect:rect];
}




#pragma mark - Accessibility Label

- (NSString *)accessibilityLabel
{
    return self.asset.accessibilityLabel;
}


@end
