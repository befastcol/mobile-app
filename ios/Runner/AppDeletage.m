#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSString *apiKey = [[[NSProcessInfo processInfo] environment] objectForKey:@"GOOGLE_MAPS_API_KEY"] ?: @"";
    [GMSServices provideAPIKey:apiKey]; 

    [GeneratedPluginRegistrant registerWithRegistry:self];
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
