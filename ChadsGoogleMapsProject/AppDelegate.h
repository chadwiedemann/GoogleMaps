//
//  AppDelegate.h
//  ChadsGoogleMapsProject
//
//  Created by Chad Wiedemann on 9/20/16.
//  Copyright © 2016 Chad Wiedemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleMapsVC.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GoogleMapsVC *googleMapsVC;

@end

