//
//  CASListViewController.h
//  CropAndShare
//
//  Created by Daniel Velasco on 2/4/16.
//  Copyright © 2016 DoWhale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CASListViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *listIdsFacebook;
@end
