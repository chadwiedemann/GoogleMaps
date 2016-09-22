//
//  GoogleMapsVC.m
//  
//
//  Created by Chad Wiedemann on 9/20/16.
//
//

#import "GoogleMapsVC.h"

@interface GoogleMapsVC () <GMSMapViewDelegate>

@end

@implementation GoogleMapsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.markerCounter = 0;
    self.searchBar.delegate = self;
    self.mapView.delegate = self;
    self.mapView.myLocationEnabled = YES;
    self.locationPhoto = [[UIImage alloc]init];
    self.searchResultsDictionary = [[NSMutableDictionary alloc]init];
    self.JSONData = [[NSData alloc]init];
    self.arrayOfAllMarkers = [[NSMutableArray alloc]init];
    [self addHardCodedPins];
    [self focusMapToShowAllMarkers];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getImageFromAPI)
                                            name:@"startMakingMarkers"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createMarkersFromSearch)
                                                 name:@"makeMarker"
                                               object:nil];
}

//returns the latitude and longitude of an address passed in as a string
- (CLLocationCoordinate2D)getLocation:(NSString *)address {
    CLLocationCoordinate2D center;
    NSString *esc_addr =  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSData *responseData = [[NSData alloc] initWithContentsOfURL:
                            [NSURL URLWithString:req]];
    NSError *error;
    NSMutableDictionary *responseDictionary = [NSJSONSerialization
                                               JSONObjectWithData:responseData
                                               options:nil
                                               error:&error];
    if( error )
    {
        NSLog(@"%@", [error localizedDescription]);
        center.latitude = 0;
        center.longitude = 0;
        return center;
    }
    else {
        NSArray *results = (NSArray *) responseDictionary[@"results"];
        NSDictionary *firstItem = (NSDictionary *) [results objectAtIndex:0];
        NSDictionary *geometry = (NSDictionary *) [firstItem objectForKey:@"geometry"];
        NSDictionary *location = (NSDictionary *) [geometry objectForKey:@"location"];
        NSNumber *lat = (NSNumber *) [location objectForKey:@"lat"];
        NSNumber *lng = (NSNumber *) [location objectForKey:@"lng"];
        center.latitude = [lat doubleValue];
        center.longitude = [lng doubleValue];
        return center;
    }
}

//creates  the custom marker object with text, photo and website
-(UIView*) mapView: (GMSMapView*)mapView markerInfoWindow:(Restaurant *)marker
{
    MyCustomMarker * infoWindow = [[[NSBundle mainBundle]loadNibNamed:@"MyCustomMarker" owner:self options:nil]objectAtIndex:0];
    infoWindow.title.text = marker.title;
    infoWindow.detail.text = marker.snippet;
    if(marker.imageString){
    infoWindow.image.image = [UIImage imageNamed: marker.imageString];
    }else{
        infoWindow.image.image = marker.locationPhoto;
    }
    return infoWindow;
}

//creates the segmented controls that allows the user to have options of normal, satilite, or hybrid view of the map
- (IBAction)segmentedControl:(UISegmentedControl *)sender {
    NSUInteger selectedMapType = sender.selectedSegmentIndex;
    switch (selectedMapType) {
        case 0:
            self.mapView.mapType = kGMSTypeNormal;
            break;
        case 1:
            self.mapView.mapType = kGMSTypeHybrid;
            break;
        case 2:
            self.mapView.mapType = kGMSTypeSatellite;
            break;
        default:
            self.mapView.mapType = kGMSTypeNormal;
            break;
    }
}

//this method focuses the map so that all the markers can been seen on one screen
- (void)focusMapToShowAllMarkers
{
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];
    for (Restaurant *marker in self.arrayOfAllMarkers)
        bounds = [bounds includingCoordinate:marker.position];
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:30.0f]];
}

//the first three hard coded locations
-(void)addHardCodedPins
{
    Restaurant *turnToTech = [[Restaurant alloc]init];
    turnToTech.title = @"TurnToTech";
    turnToTech.imageString = @"logo";
    turnToTech.position = [self getLocation:@"184 5th Avenue New York"];
    turnToTech.map = self.mapView;
    turnToTech.webSite = @"http://www.turntotech.io";
    
    Restaurant *maisonKayser = [[Restaurant alloc]init];
    maisonKayser.title = @"Maison Kayser";
    maisonKayser.imageString = @"coffee";
    maisonKayser.position = [self getLocation:@"921 broadway new york"];
    maisonKayser.map = self.mapView;
    maisonKayser.webSite = @"http://www.maison-kayser.usa.com";

    Restaurant *ilBastardo = [[Restaurant alloc]init];
    ilBastardo.title = @"Il Bastardo";
    ilBastardo.imageString = @"burger";
    ilBastardo.position = [self getLocation:@"191 7th Avenue new york"];
    ilBastardo.map = self.mapView;
    ilBastardo.webSite = @"http://nycrg.com/il-bastardo/";
    
    [self.arrayOfAllMarkers addObject:turnToTech];
    [self.arrayOfAllMarkers addObject:maisonKayser];
    [self.arrayOfAllMarkers addObject:ilBastardo];
}

//this method transitions the app to the website view when the user taps on the marker
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(Restaurant *)marker {
    WebSiteViewController *viewController = [[WebSiteViewController alloc]init];
    viewController.webSite = marker.webSite;
    [self presentViewController:viewController animated:YES completion:nil];
}

//this is just for programing convenience it returns the total number of results in a api query
-(int)numberOfRestaurants
{
    return [[self.searchResultsDictionary objectForKey:@"results"] count];
}

//this method queries goolge and performs a google Nearby Search.  It returns nearby locations that match the users input into the search bar.  it then loads the raw JSON data into a dictionary
-(void)searchForRestaurants: (NSString*) restaurants
{
    NSString *APIKey = @"AIzaSyAhBAkEPqpdLOyioHkW8ybpCaX9sOM_jOU";
    NSString *baseString = [NSString stringWithFormat: @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=40.74143697008403,-73.99011969566345&radius=500&keyword=%@&key=%@",restaurants,APIKey];
    NSURL *url = [NSURL URLWithString:baseString];
    NSURLSessionDataTask *searchResults = [[NSURLSession sharedSession]dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(!error) {
            NSString *dataInString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            self.JSONData = [dataInString dataUsingEncoding:NSUTF8StringEncoding];
            self.searchResultsDictionary = [NSJSONSerialization JSONObjectWithData:self.JSONData options:NSJSONReadingMutableContainers error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if([[self.searchResultsDictionary objectForKey:@"results"] count]>0){
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"startMakingMarkers"
                 object:nil];
                }else{NSLog(@"no data returned");};
            });
        }else{
            NSLog(@"%@",error.localizedDescription);
        }
    }];
    [searchResults resume];
}

//returns the location of a marker from the downloaded data.  The method accepts the dictionary containing the raw data from Google and an integer which acts as a counter when loading the queried results
-(CLLocationCoordinate2D)getPosition: (NSMutableDictionary*) dictionary index:(int) index
{
    CLLocationCoordinate2D center;
    NSArray *results = (NSArray *) dictionary[@"results"];
    NSDictionary *firstItem = (NSDictionary *) [results objectAtIndex:index];
    NSDictionary *geometry = (NSDictionary *) [firstItem objectForKey:@"geometry"];
    NSDictionary *location = (NSDictionary *) [geometry objectForKey:@"location"];
    NSNumber *lat = (NSNumber *) [location objectForKey:@"lat"];
    NSNumber *lng = (NSNumber *) [location objectForKey:@"lng"];
    center.latitude = [lat doubleValue];
    center.longitude = [lng doubleValue];
    return center;
}

//this method gets the url of a photo that represents the marker
-(NSString*)getPhotoReference: (NSMutableDictionary*) dictionary index:(int) index
{
    
    NSArray *results = (NSArray *) dictionary[@"results"];
    NSDictionary *firstItem = (NSDictionary *) [results objectAtIndex:index];
    NSArray *photos = (NSArray*) [firstItem objectForKey:@"photos"];
    if(photos.count>0){
    NSDictionary *photoReferenceDictionary = (NSDictionary *)[photos objectAtIndex:0];
    NSString *photoReference = (NSString *)[photoReferenceDictionary objectForKey:@"photo_reference"];
        return photoReference;
    }else{

        return @"noDataInArray";
    }
}

//this is a second API request sent to google to retrieve the image of the location
-(void)getImageFromAPI
{
    NSString *photoReference = [self getPhotoReference:self.searchResultsDictionary index:self.markerCounter];
    NSString *APIKey = @"AIzaSyAhBAkEPqpdLOyioHkW8ybpCaX9sOM_jOU";
    NSString *baseString = [NSString stringWithFormat: @"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=%@&key=%@",photoReference,APIKey];
    NSURL *url = [NSURL URLWithString:baseString];
    NSURLSessionDownloadTask *downLoadPhotoTask = [[NSURLSession sharedSession]downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(!error){
        UIImage *downLoadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
        UIImageWriteToSavedPhotosAlbum(downLoadedImage, nil, nil, nil);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.locationPhoto = downLoadedImage;
            self.markerCounter++;
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"makeMarker"
             object:nil];
        });}else{
            NSLog(@"%@",error.localizedDescription);
        }
    }];
    [downLoadPhotoTask resume];
}

//parses the data to return the title of the marker
-(NSString*)getTitle: (NSMutableDictionary*) dictionary index:(int) index
{
    NSArray *results = (NSArray *) dictionary[@"results"];
    NSDictionary *firstItem = (NSDictionary *) [results objectAtIndex:index];
    NSString *name = (NSString*)[firstItem objectForKey:@"name"];
    return name;
}

//this is the method that is run when the user clicks the searchbar
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchForRestaurants:searchBar.text];
}

//this method creates the new markers from all the data collected from both data requests for the places and then for the images
-(void)createMarkersFromSearch
{
        Restaurant *tempRest = [[Restaurant alloc]init];
        tempRest.position = [self getPosition:self.searchResultsDictionary index:self.markerCounter-1];
        tempRest.title = [self getTitle:self.searchResultsDictionary index:self.markerCounter-1];
        tempRest.locationPhoto = self.locationPhoto;
        tempRest.map = self.mapView;
        [self.arrayOfAllMarkers addObject:tempRest];
    if([self numberOfRestaurants] == self.markerCounter){
    [self focusMapToShowAllMarkers];
        self.markerCounter = 0;
    }else{[self getImageFromAPI];
    }
}

//memory warning method
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
