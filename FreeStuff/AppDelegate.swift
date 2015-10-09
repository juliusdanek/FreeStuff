//
//  AppDelegate.swift
//  FreeStuff
//
//  Created by Julius Danek on 7/19/15.
//  Copyright (c) 2015 Julius Danek. All rights reserved.
//

import UIKit
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Parse.enableLocalDatastore()
        Listing.registerSubclass()
        Parse.setApplicationId("jeA3EeENcGwoG2PmGoFdhh8QRr77gsRTbJMRETkN",
            clientKey: "oKSkzRobkrSnaizae1Q9tPA6hrJylbgMggtW1o5S")
        
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        // Override point for customization after application launch.
        
        // Register for Push Notitications
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            let types: UIRemoteNotificationType = [UIRemoteNotificationType.Badge, UIRemoteNotificationType.Alert, UIRemoteNotificationType.Sound]
            application.registerForRemoteNotificationTypes(types)
        }
        
        //make sure that user is uniquely identified on Parse database by calling signup function
        signup()
        
        //when app first starts and there are no user settings as of yet, initialize with these ones
        if NSUserDefaults.standardUserDefaults().objectForKey("standardSettings") == nil {
            var settingsDict = [String: AnyObject]()
            settingsDict["searchDistance"] = Double(20.0)
            NSUserDefaults.standardUserDefaults().setObject(settingsDict, forKey: "standardSettings")
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
    //TODO: Might have to store some stuff in keychain because Vendor ID does not stay the same across device
    func signup() {
        //checking if there is a user cached
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            //simple return statements
            return
        } else {
            //if not, try to log in with the unique device ID --> All listings will always be associated with a device
            PFUser.logInWithUsernameInBackground(UIDevice.currentDevice().identifierForVendor!.UUIDString, password:"FreeStuff") {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    print("successful login")
                    // Do stuff after successful login.
                } else {
                    //if you can't log in, sign the user up using the device ID and the same password
                    let user = PFUser()
                    user.username = UIDevice.currentDevice().identifierForVendor!.UUIDString
                    user.password = "FreeStuff"
                    // other fields can be set just like with PFObject
                    user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                        if let error = error {
                            let errorString = error.userInfo["error"] as? NSString
                        } else {
                            return
                        }
                    })
                }
            }
        }
    }
}

