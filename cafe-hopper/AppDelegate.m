//
//  AppDelegate.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/12/21.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
@import GoogleMaps;
@import GooglePlaces;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {

            configuration.applicationId = [dict objectForKey:@"parseAppID"];
            configuration.clientKey = [dict objectForKey:@"parseClientKey"];
            configuration.server = @"https://parseapi.back4app.com";
        }];
    [Parse initializeWithConfiguration:config];
    
    NSString *googleAPIKey = [dict objectForKey:@"googleMapsAPIKey"];
    [GMSServices provideAPIKey:googleAPIKey];
    [GMSPlacesClient provideAPIKey:googleAPIKey];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
