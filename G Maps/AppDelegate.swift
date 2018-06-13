//
//  AppDelegate.swift
//  G Maps
//
//  Created by Rudra Jikadra on 25/01/18.
//  Copyright © 2018 Rudra Jikadra. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

public var userId: String?                // For client-side use only!
public var idToken: String?
public var fullName: String?
public var givenName: String?
public var familyName: String?
public var email: String?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    
    //saving the default values
    let defaults = UserDefaults.standard
    let defaultValue = ["SigninKey" : 0] //for sign in check
    
    let default_userId = ["userId" : ""]
    let default_idToken = ["idToken" : ""]
    let default_fullName = ["fullName" : ""]
    let default_givenName = ["givenName" : ""]
    let default_familyName = ["familyName" : ""]
    let default_email = ["email" : ""]
    
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        defaults.register(defaults: defaultValue)
        
        defaults.register(defaults: default_userId)
        defaults.register(defaults: default_idToken)
        defaults.register(defaults: default_fullName)
        defaults.register(defaults: default_givenName)
        defaults.register(defaults: default_familyName)
        defaults.register(defaults: default_email)
        
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let err = error {
            print("Failed to login: ", err)
            return
        }
        
        activityIndicator.center = (self.window?.rootViewController?.view.center)!
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.window?.rootViewController?.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        
        userId = user.userID                  // For client-side use only!
        idToken = user.authentication.idToken // Safe to send to the server
        fullName = user.profile.name
        givenName = user.profile.givenName
        familyName = user.profile.familyName
        email = user.profile.email
        
        //saving the data of user in app which wont be reset or cleared
        self.defaults.set(userId, forKey: "userId")
        self.defaults.set(idToken, forKey: "idToken")
        self.defaults.set(fullName, forKey: "fullName")
        self.defaults.set(givenName, forKey: "givenName")
        self.defaults.set(familyName, forKey: "familyName")
        self.defaults.set(email, forKey: "email")
        
        
        print("Sucessfully Logged into Google ", user)
        print("\n\nIn App Delegate:\n with uid: \(userId!)\n with fullname: \(fullName!)\n with given Name : \(givenName!) \n with family Name: \(familyName!)\n with email: \(email!)")
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let err = error {
                print("Failed to create a Firebase User with Google Account: ", err)
                return
            }
            
            guard let uid = user?.uid else { return }
            print("Sucessfully Logged into Firebase with Google Account ", uid)
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            //saving signinkey to 1 #note that it will send as string check signin.swift
            self.defaults.set(1, forKey: "SigninKey")
            
        }
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

