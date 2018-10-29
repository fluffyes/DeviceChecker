//
//  ViewController.swift
//  DeviceChecker
//
//  Created by Soulchild on 29/10/2018.
//  Copyright © 2018 fluffy. All rights reserved.
//

import UIKit
import DeviceCheck

class ViewController: UIViewController {

    @IBOutlet weak var claimRewardButton: UIButton!
    @IBOutlet weak var resetRewardButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // replace this with your own server url
    let redeem_url = "https://devicecheckserver.herokuapp.com/redeem"
    let reset_url = "https://devicecheckserver.herokuapp.com/reset"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        activityIndicator.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func claimRewardTapped(_ sender: UIButton) {
        let device = DCDevice.current
        
        guard device.isSupported else {
            let alert = UIAlertController(title: "Unsupported device", message: "Please try in a real device instead of simulator", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        device.generateToken(completionHandler: { data, error in
            guard error == nil,
            let data = data else {
                let alert = UIAlertController(title: "Unable to generate token", message: "Please sign the app using a valid Apple Developer Account", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            // send the base64 encoded device token to server
            let token = data.base64EncodedString()
            
            self.redeemReward(with: token)
            
        })
    }
    
    @IBAction func resetRewardTapped(_ sender: UIButton) {
        let device = DCDevice.current
        
        guard device.isSupported else {
            let alert = UIAlertController(title: "Unsupported device", message: "Please try in a real device instead of simulator", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        device.generateToken(completionHandler: { data, error in
            guard error == nil,
                let data = data else {
                    let alert = UIAlertController(title: "Unable to generate token", message: "Please sign the app using a valid Apple Developer Account", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    
                    self.present(alert, animated: true, completion: nil)
                    return
            }
            
            // send the base64 encoded device token to server
            let token = data.base64EncodedString()
            
            self.resetReward(with: token)
        })
    }
    
    
    private func redeemReward(with token:String){
        let config = URLSessionConfiguration.default
        
        let session = URLSession(configuration: config)
        var urlRequest = URLRequest(url: URL(string: redeem_url)!)
        urlRequest.httpMethod = "POST"
        
        // your post request data
        let postDict : [String: Any] = ["token": token]
        
        guard let postData = try? JSONSerialization.data(withJSONObject: postDict, options: []) else {
            return
        }
        
        urlRequest.httpBody = postData
        let task = session.dataTask(with: urlRequest) { data, response, error in
            
            // ensure there is no error for this HTTP response
            guard error == nil else {
                print ("error: \(error!)")
                return
            }
            
            // ensure there is data returned from this HTTP response
            guard let content = data else {
                print("No data")
                return
            }
            
            // serialise the data / NSData object into Dictionary [String : Any]
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
                print("Not containing JSON")
                return
            }
            
            print("gotten json response dictionary is \n \(json)")
            
            // update UI using the response here
            DispatchQueue.main.async {
                self.claimRewardButton.isEnabled = true
                self.resetRewardButton.isEnabled = true
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                
                if let message = json["message"] as? String {
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
        }
        
        DispatchQueue.main.async {
            self.claimRewardButton.isEnabled = false
            self.resetRewardButton.isEnabled = false
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        
        // execute the HTTP request
        task.resume()
    }
    
    private func resetReward(with token:String){
        let config = URLSessionConfiguration.default
        
        let session = URLSession(configuration: config)
        var urlRequest = URLRequest(url: URL(string: reset_url)!)
        urlRequest.httpMethod = "POST"
        
        // your post request data
        let postDict : [String: Any] = ["token": token]
        
        guard let postData = try? JSONSerialization.data(withJSONObject: postDict, options: []) else {
            return
        }
        
        urlRequest.httpBody = postData
        let task = session.dataTask(with: urlRequest) { data, response, error in
            
            // ensure there is no error for this HTTP response
            guard error == nil else {
                print ("error: \(error!)")
                return
            }
            
            // ensure there is data returned from this HTTP response
            guard let content = data else {
                print("No data")
                return
            }
            
            // serialise the data / NSData object into Dictionary [String : Any]
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
                print("Not containing JSON")
                return
            }
            
            print("gotten json response dictionary is \n \(json)")
            
            // update UI using the response here
            DispatchQueue.main.async {
                self.claimRewardButton.isEnabled = true
                self.resetRewardButton.isEnabled = true
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                
                if let message = json["message"] as? String {
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
        }
        
        DispatchQueue.main.async {
            self.claimRewardButton.isEnabled = false
            self.resetRewardButton.isEnabled = false
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        
        // execute the HTTP request
        task.resume()
    }
}
