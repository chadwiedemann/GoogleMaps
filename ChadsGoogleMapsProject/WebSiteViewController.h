//
//  WebSiteViewController.h
//  ChadsGoogleMapsProject
//
//  Created by Chad Wiedemann on 9/21/16.
//  Copyright © 2016 Chad Wiedemann. All rights reserved.
//


#import <WebKit/Webkit.h>
#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "Restaurant.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MyCustomMarker.h"

@interface WebSiteViewController : UIViewController <WKNavigationDelegate>

@property (nonatomic,strong) NSString *webSite;
@property (nonatomic, strong) WKWebView *webViewForWebSite;
@property (weak, nonatomic) IBOutlet UIView *subViewForWebSite;

- (IBAction)backButton:(id)sender;

@end
