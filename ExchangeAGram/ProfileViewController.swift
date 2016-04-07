//
//  ProfileViewController.swift
//  ExchangeAGram
//
//  Created by Trevor Griffin on 2/16/16.
//  Copyright © 2016 TREVOR E GRIFFIN. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["public_profile"]
        fbLoginButton.publishPermissions = ["publish_actions"]
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(ProfileViewController.fbProfileChanged(_:)),
            name: FBSDKProfileDidChangeNotification,
            object: nil)
        
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        
        // If we have a current Facebook access token, force the profile change handler
        if ((FBSDKAccessToken.currentAccessToken()) != nil)
        {
            fbProfileChanged(self)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
    
        if (error != nil)
        {
            print( "\(error.localizedDescription)" )
        }
        else if (result.isCancelled)
        {
            // Logged out?
            print( "Login Cancelled")
        }
        else
        {
            // Logged in?
            print("Logged in")
        }
    }

    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    @IBAction func mapViewButtonTapped(sender: UIButton) {
        performSegueWithIdentifier("mapSegue", sender: nil)
    }
    
    // Helper Functions
    
    func fbProfileChanged(sender: AnyObject!) {
        
        
        let fbProfile = FBSDKProfile.currentProfile()
        
        if (fbProfile != nil)
        {
            let userImageURL = "https://graph.facebook.com/\(fbProfile.userID)/picture?type=large"
            let url = NSURL(string: userImageURL)
            let imageData = NSData(contentsOfURL: url!)
            let image = UIImage(data: imageData!)
            
            nameLabel.text = fbProfile.name
            profileImageView.image = image
            
            nameLabel.hidden = false
            profileImageView.hidden = false
        }
        else
        {
            nameLabel.text = ""
            profileImageView.image = UIImage(named: "")
            
            nameLabel.hidden = true
            profileImageView.hidden = true
        }
    }
    

}
