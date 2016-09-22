//
//  Restaurant.h
//  ChadsGoogleMapsProject
//
//  Created by Chad Wiedemann on 9/20/16.
//  Copyright © 2016 Chad Wiedemann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface Restaurant : GMSMarker

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) NSString *webSite;
@property (strong, nonatomic) NSString *restaurantAddress;
@property (strong, nonatomic) NSString *imageString;
@property (strong, nonatomic) UIImage *locationPhoto;



@end
