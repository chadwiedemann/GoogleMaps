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
    self.locationPhoto = [[UIImageView alloc]init];
    self.searchResultsDictionary = [[NSMutableDictionary alloc]init];
    self.JSONData = [[NSData alloc]init];
    self.arrayOfAllMarkers = [[NSMutableArray alloc]init];
    [self addHardCodedPins];
    [self focusMapToShowAllMarkers];
//    [self searchForRestaurants:@"restaurant"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getImageFromAPI)
                                            name:@"startMakingMarkers"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createMarkersFromSearch)
                                                 name:@"makeMarker"
                                               object:nil];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

- (void)focusMapToShowAllMarkers
{
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];
    
    for (Restaurant *marker in self.arrayOfAllMarkers)
        bounds = [bounds includingCoordinate:marker.position];
    
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:30.0f]];
}

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

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(Restaurant *)marker {
    WebSiteViewController *viewController = [[WebSiteViewController alloc]init];
    viewController.webSite = marker.webSite;
    [self presentViewController:viewController animated:YES completion:nil];
}

-(int)numberOfRestaurants
{
    return [[self.searchResultsDictionary objectForKey:@"results"] count];
}
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

-(void)getImageFromAPI
{
    NSString *photoReference = [self getPhotoReference:self.searchResultsDictionary index:self.markerCounter];
    NSString *APIKey = @"AIzaSyAhBAkEPqpdLOyioHkW8ybpCaX9sOM_jOU";
    NSString *baseString = [NSString stringWithFormat: @"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=%@&key=%@",photoReference,APIKey];
    NSURL *url = [NSURL URLWithString:baseString];
    NSURLSessionDownloadTask *downLoadPhotoTask = [[NSURLSession sharedSession]downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(!error){
        UIImage *downLoadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
        
        // Save the image to your Photo Album
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

-(NSString*)getTitle: (NSMutableDictionary*) dictionary index:(int) index
{
    NSArray *results = (NSArray *) dictionary[@"results"];
    NSDictionary *firstItem = (NSDictionary *) [results objectAtIndex:index];
    NSString *name = (NSString*)[firstItem objectForKey:@"name"];
    return name;
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchForRestaurants:searchBar.text];
}

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


@end
