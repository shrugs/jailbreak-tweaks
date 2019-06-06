/*
  reason, my headers are causing me more headache than anything,
  so I'm just putting the stuff I need here

  Apologies to the iOS gods
*/

@class CLLocationManager;

@protocol CLLocationManagerDelegate

@optional
-(void)locationManager:(CLLocationManager *)locationManager didUpdateLocations:(NSArray *)locations;

@end


typedef double CLLocationDegrees;
typedef double CLLocationAccuracy;
typedef double CLLocationDistance;
typedef double CLLocationDirection;
typedef double CLLocationSpeed;

typedef struct { CLLocationDegrees latitude; CLLocationDegrees longitude; } CLLocationCoordinate2D;
CLLocationCoordinate2D CLLocationCoordinate2DMake ( CLLocationDegrees latitude, CLLocationDegrees longitude );

@interface CLLocation : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (CLLocation *)initWithCoordinate:(CLLocationCoordinate2D)coordinate altitude:(CLLocationDistance)altitude horizontalAccuracy:(CLLocationAccuracy)hAccuracy verticalAccuracy:(CLLocationAccuracy)vAccuracy course:(CLLocationDirection)course speed:(CLLocationSpeed)speed timestamp:(NSDate *)timestamp;
- (void)startMonitoringSignificantLocationChanges;

@end

@interface CLLocationManager

@property (nonatomic, weak) id <CLLocationManagerDelegate> delegate;
@property (nonatomic, retain) NSTimer *tppgTimer;

- (void)tppg_nextLocation;

@end
