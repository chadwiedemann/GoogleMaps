//
//  MyCustomMarker.h
//  ChadsGoogleMapsProject
//
//  Created by Chad Wiedemann on 9/21/16.
//  Copyright © 2016 Chad Wiedemann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCustomMarker : UIView

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *detail;

@end
