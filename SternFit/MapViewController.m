//
//  MapViewController.m
//  SternFit
//
//  Created by Adam on 1/21/15.
//  Copyright (c) 2015 com.mobile.sternfit. All rights reserved.
//

#import "MapViewController.h"
#import "sbMapAnnotation.h"

@interface MapViewController ()

@end

@implementation MapViewController
@synthesize strLocation,map;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *items = [strLocation componentsSeparatedByString:@","];
    [map removeAnnotations:[map.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"!(self isKindOfClass:%@)",[MKUserLocation class]]]];
    map.hidden=NO;
    
    CLLocationCoordinate2D l;
    l.latitude=[[items objectAtIndex:0] doubleValue];
    l.longitude=[[items objectAtIndex:1] doubleValue];
    SBMapAnnotation *annotation= [[SBMapAnnotation alloc]initWithCoordinate:l];
    
    [map addAnnotation:annotation];
    [map setRegion:MKCoordinateRegionMake([annotation coordinate], MKCoordinateSpanMake(.005, .005)) animated:YES];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnBackClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
   /* NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%@&daddr=%@", strLocation, strLocation]];
    [[UIApplication sharedApplication] openURL:URL];*/
    
    NSArray *items = [strLocation componentsSeparatedByString:@","];

    CLLocationCoordinate2D l;
    l.latitude=[[items objectAtIndex:0] doubleValue];
    l.longitude=[[items objectAtIndex:1] doubleValue];
    
    CLLocationCoordinate2D coordinate =    CLLocationCoordinate2DMake(l.latitude, l.longitude);
    
    //create MKMapItem out of coordinates
    MKPlacemark* placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    MKMapItem* destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
    if([destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)])
    {
        [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
        
    } else{
        
        //using iOS 5 which has the Google Maps application
        NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=Location&daddr=%f,%f", l.latitude, l.longitude];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    }
}

@end
