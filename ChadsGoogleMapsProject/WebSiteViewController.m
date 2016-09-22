//
//  WebSiteViewController.m
//  ChadsGoogleMapsProject
//
//  Created by Chad Wiedemann on 9/21/16.
//  Copyright © 2016 Chad Wiedemann. All rights reserved.
//

#import "WebSiteViewController.h"

@interface WebSiteViewController ()

@end

@implementation WebSiteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebViewConfiguration *theConfig = [[WKWebViewConfiguration alloc]init];
    self.view.frame = [[UIScreen mainScreen] bounds];
    
    self.webViewForWebSite = [[WKWebView alloc]init];
    
    self.webViewForWebSite.navigationDelegate = self;
    
    
    [self.subViewForWebSite addSubview:self.webViewForWebSite];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
 
    
    NSURL *url  = [NSURL URLWithString:self.webSite];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.webViewForWebSite loadRequest:request];
    
    //self.webViewForWebSite.frame = self.subViewForWebSite.frame;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   
    self.webViewForWebSite.frame = self.subViewForWebSite.bounds;
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)backButton:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
