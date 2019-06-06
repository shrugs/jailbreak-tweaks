
#import "vendor/SimulateTouch/SimulateTouch.h"
#import "CoreLocation.h"

#define DEFAULT_WALKING_DISTANCE 0.00015
#define COMMAND_ENDPOINT @"http://172.16.11.109:4098/command"
#define LOCATION_PINGBACK @"http://172.16.11.109:4098/set_map?lat=%f&lng=%f&ts=%f"
// seconds
#define REFRESH_RATE 4.0

#define ORIGINAL_LAT 40.821670
#define ORIGINAL_LNG -73.956940


typedef enum {
  N = 0,
  NW = 1,
  NE = 2,
  W = 3,
  E = 4,
  SW = 5,
  SE = 6,
  S = 7
} TPPGDirection;


// Start at union square
static CLLocation *currentLocation = [[CLLocation alloc]
    initWithCoordinate:(CLLocationCoordinate2D){.latitude = ORIGINAL_LAT, .longitude = ORIGINAL_LNG}
              altitude: 5
    horizontalAccuracy: 5
      verticalAccuracy: 5
                course: 0
                 speed: 1
             timestamp: [NSDate date]
  ];


%hook CLLocationManager

%property (nonatomic, retain) NSTimer *tppgTimer;

- (void)startUpdatingLocation {
  [self.tppgTimer invalidate];

  dispatch_async(dispatch_get_main_queue(), ^{
      self.tppgTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                   target:self
                   selector:@selector(tppg_nextLocation)
                   userInfo:nil
                   repeats:YES];
  });
}

- (void)stopUpdatingLocation {
  [self.tppgTimer invalidate];
  self.tppgTimer = nil;
}

%new
- (void)tppg_nextLocation {
  CLLocation *loc = [currentLocation copy];
  [self.delegate locationManager:self didUpdateLocations:@[loc]];
}

%end







@interface TPPG : NSObject

@end

@implementation TPPG

- (CLLocation *)locationWithDirection:(TPPGDirection)direction {

  HBLogDebug(@"DIRECTION: %i", (int)direction);

  double latOffset = 0;
  double lngOffset = 0;

  switch (direction) {
    case NW:
      latOffset = DEFAULT_WALKING_DISTANCE;
      lngOffset = -1 * DEFAULT_WALKING_DISTANCE;
      break;
    case NE:
      latOffset = DEFAULT_WALKING_DISTANCE;
      lngOffset = DEFAULT_WALKING_DISTANCE;
      break;
    case W:
      lngOffset = -1 * DEFAULT_WALKING_DISTANCE;
      break;
    case E:
      lngOffset = DEFAULT_WALKING_DISTANCE;
      break;
    case SW:
      latOffset = -1 * DEFAULT_WALKING_DISTANCE;
      lngOffset = -1 * DEFAULT_WALKING_DISTANCE;
      break;
    case SE:
      latOffset = -1 * DEFAULT_WALKING_DISTANCE;
      lngOffset = DEFAULT_WALKING_DISTANCE;
      break;
    case S:
      latOffset = -1 * DEFAULT_WALKING_DISTANCE;
      break;
    default:
    case N:
      latOffset = DEFAULT_WALKING_DISTANCE;
      break;
  }

  return [self locationWithLat: [currentLocation coordinate].latitude + latOffset
                           lng: [currentLocation coordinate].longitude + lngOffset
         ];
}

- (CLLocation *)locationWithLat:(double)lat lng:(double)lng {
  return [[CLLocation alloc]
        initWithCoordinate:(CLLocationCoordinate2D){
          .latitude = lat,
          .longitude = lng
        }
                  altitude: arc4random_uniform(20)
        horizontalAccuracy: arc4random_uniform(20)
          verticalAccuracy: arc4random_uniform(20)
                    course: 0
                     speed: arc4random_uniform(3)
                 timestamp: [NSDate date]
     ];
}

- (void)requestInstruction {

  // request the instruction from the server

  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:COMMAND_ENDPOINT]];

  [NSURLConnection sendAsynchronousRequest:request
                                     queue:[NSOperationQueue mainQueue]
                         completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                          if (connectionError) {
                            HBLogDebug(@"No Server, retrying....");
                            HBLogDebug(@"%@", connectionError);
                            return;
                          }
                            NSError *err = nil;
                            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:0
                                                                      error:&err];

                             if (err) {
                                HBLogDebug(@"Bad Json... %@", err);
                                HBLogDebug(@"%@", data);
                             } else {
                                [self handleCommandData:json];
                             }
                         }];
}

-(void)handleCommandData:(NSDictionary *)data {

  NSString *method = [data objectForKey:@"method"];
  HBLogDebug(@"%@", method);

  // throw (1, 2, 3)
  // rotate ( left | right)

  if ([method isEqualToString:@"move"]) {
    int direction = [[data objectForKey:@"direction"] intValue];

    currentLocation = [self locationWithDirection:(TPPGDirection)direction];
    HBLogDebug(@"#define ORIGINAL_LAT %f", [currentLocation coordinate].latitude);
    HBLogDebug(@"#define ORIGINAL_LNG %f", [currentLocation coordinate].longitude);
    [self locationPingBack:currentLocation];
  } else if ([method isEqualToString:@"location"]) {

    double lat = [[data objectForKey:@"lat"] doubleValue];
    double lng = [[data objectForKey:@"lng"] doubleValue];

    currentLocation = [self locationWithLat:lat lng:lng];

  } else if ([method isEqualToString:@"tap"]) {

    double xLoc = [[data objectForKey:@"x"] doubleValue];
    double yLoc = [[data objectForKey:@"y"] doubleValue];

    CGPoint pt = CGPointMake(xLoc, yLoc);
    int r = [SimulateTouch simulateTouch:0 atPoint:pt withType:STTouchDown];
    [SimulateTouch simulateTouch:r atPoint:pt withType:STTouchUp];

  } else if ([method isEqualToString:@"throw"]) {

    int level = [[data objectForKey:@"level"] intValue];

    double height = 300 - (100 * (level - 1));
    // 1 -> 300
    // 2 -> 200
    // 3 -> 100

    double duration = 0.2 - (0.05 * (level - 1));
    // 1 -> 0.2
    // 2 -> 0.15
    // 3 -> 0.10

    // simulate a stright up swipe with different speeds
    [SimulateTouch simulateSwipeFromPoint:CGPointMake(187, 620)
                                  toPoint:CGPointMake(187, height)
                                 duration:duration];

  } else if ([method isEqualToString:@"rotate"]) {

    NSString *direction = [data objectForKey:@"direction"];

    CGPoint fromPoint = CGPointMake(30, 300);
    CGPoint toPoint = CGPointMake(300, 300);

    if ([direction isEqualToString:@"right"]) {
      CGPoint tmpPoint = fromPoint;
      fromPoint = toPoint;
      toPoint = tmpPoint;
    }

    [SimulateTouch simulateSwipeFromPoint:fromPoint
                                  toPoint:toPoint
                                 duration:0.3];

  } else if ([method isEqualToString:@"scroll"]) {

    NSString *direction = [data objectForKey:@"direction"];

    CGPoint fromPoint = CGPointMake(187, 500);
    CGPoint toPoint = CGPointMake(187, 450);

    if ([direction isEqualToString:@"up"]) {
      CGPoint tmpPoint = fromPoint;
      fromPoint = toPoint;
      toPoint = tmpPoint;
    }

    [SimulateTouch simulateSwipeFromPoint:fromPoint
                                  toPoint:toPoint
                                 duration:0.5];
  } else if ([method isEqualToString:@"reset"]) {
    // crash the app lol
    abort(); // abandon thread
  } else {
    // unknown method
    HBLogDebug(@"noop");
  }
}

-(void)locationPingBack:(CLLocation *)loc {

  NSString *location = [NSString stringWithFormat:
    LOCATION_PINGBACK,
    [loc coordinate].latitude,
    [loc coordinate].longitude,
    1.0
  ];

  NSMutableURLRequest *request =
          [NSMutableURLRequest requestWithURL:[NSURL
              URLWithString:location]
              cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                     timeoutInterval:2
   ];

  [request setHTTPMethod: @"GET"];

  [NSURLConnection sendAsynchronousRequest:request
                                     queue:[NSOperationQueue mainQueue]
                        completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

                          if (connectionError) {
                            HBLogDebug(@"%@", connectionError);
                          }

                        }];
}

@end

%ctor {
  TPPG *tppg = [[TPPG alloc] init];

  [NSTimer scheduledTimerWithTimeInterval: REFRESH_RATE
               target: tppg
               selector: @selector(requestInstruction)
               userInfo: nil
               repeats: YES];
}

