//
//  signin.swift
//  G Maps
//
//  Created by Rudra Jikadra on 26/01/18.
//  Copyright © 2018 Rudra Jikadra. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

var signincounter = 0
let defaults = UserDefaults.standard
var token = defaults.string(forKey: "SigninKey")


class signin: UIViewController, GIDSignInUIDelegate {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var timer: Timer!
   
    @IBOutlet weak var mapBut: UIButton!
    var googleButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        callAgain()
        
        googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 16, y: view.frame.height * 0.2, width: view.frame.width - 32, height: 50)
        view.addSubview(googleButton)
        
        googleButton.alpha = 0
        mapBut.isEnabled = false
        mapBut.alpha = 0
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
    }
    
    func callAgain(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.done), userInfo: nil, repeats: true)
    }
    
    @objc func done(){
        token = defaults.string(forKey: "SigninKey")
        signincounter = Int(token!)!
        
        print(signincounter)
            if signincounter == 1 {
                
                mapBut.isEnabled = true
                mapBut.alpha = 1
                googleButton.alpha = 0
                timer.invalidate()
                timer = nil
                
            } else {
                
                mapBut.isEnabled = false
                mapBut.alpha = 0
                googleButton.alpha = 1
            }
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
