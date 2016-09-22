//
//  GoogleMapsVC.h
//  
//
//  Created by Chad Wiedemann on 9/20/16.
//
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "Restaurant.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MyCustomMarker.h"
#import "WebSiteViewController.h"
#import <GooglePlaces/GooglePlaces.h>




@interface GoogleMapsVC : UIViewController <GMSMapViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *turnToTechLogo;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (nonatomic, strong) NSMutableArray *arrayOfAllMarkers;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSData *JSONData;
@property (nonatomic, strong) NSData *JSONDataForImageString;
@property (nonatomic, strong) NSMutableDictionary *searchResultsDictionary;
@property (nonatomic, strong) NSMutableString *imageString;
@property (strong, nonatomic) IBOutlet UIImage *locationPhoto;
@property int markerCounter;
- (IBAction)segmentedControl:(id)sender;


@end
