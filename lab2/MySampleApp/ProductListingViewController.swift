//
//  ProductListingViewController.swift
//  MySampleApp
//
//  Created by Dabhade, Nikhil on 10/18/16.
//
//

import UIKit
import Foundation

class ProductListingViewController: UIViewController, NSURLConnectionDelegate {

    @IBOutlet weak var productImageView: UIImageView!

    @IBOutlet weak var productWebView: UIWebView!
    @IBOutlet weak var productJson: UITextView!
    @IBOutlet weak var productCode: UILabel!
    @IBOutlet weak var code: UILabel!
    @IBOutlet weak var productDescription: UITextView!
    @IBOutlet weak var productName: UITextView!
    @IBOutlet weak var productPrice: UITextView!
    
    override func viewDidLoad() {

        super.viewDidLoad();
      
        let url = NSURL(string:"http://<your container ip>/products")
        let data = NSData(contentsOfURL:url!)
        if data != nil {
            print("-------------------")
            print(String(data:data!, encoding:NSUTF8StringEncoding))
            print("-------------------")
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSArray
                
                if let first = json.firstObject {
                    
                    if let jsonName = first["name"] as? String {
                        print(jsonName)
                        productName.text = jsonName;
                    }
                    
                    if let jsonURL = first["image_url_1"] as? String {
                        print(jsonURL)
                        //var jsoURL = "http://media.performancebike.com/images/performance/products/product-hi/31-5335-BLK-EXTRA.JPG?resize=1500px:1500px&output-quality=100"
                        loadImageFromUrl(jsonURL, view: productImageView)
                    }
                    
                    if let jsonDescription = first["description"] as? String {
                        print(jsonDescription)
                        productDescription.text = jsonDescription;
                    }
                    
                    if let jsonPrice = first["price"] as? Double {
                        print(jsonPrice)
                        productPrice.text = "Price: " + String(jsonPrice)
                    }
                    
                }
                
            } catch let specialErr as NSError {
                print("error serializing JSON: \(specialErr)")
            }
            
            productJson.text = String(data:data!, encoding:NSUTF8StringEncoding);
        }

        
        
   /*
        
        sample json 
        
        [
            {
                "count":5,
                "description":"This is a testproduct",
                "id":1,
                "image_url_1":"http:\/\/amazon.com",
                "image_url_2":"http:\/\/amazon.com",
                "name":"testproduct",
                "price":20.5,
                "url":"http:\/\/54.147.8.176\/products\/1"
            }
        ]
 
*/
        
    }
    
    func loadImageFromUrl(url: String, view: UIImageView){
        
        // Create Url from string
        let url = NSURL(string: url)!
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (responseData, responseUrl, error) -> Void in
            if let data = responseData{
                // execute in UI thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    view.image = UIImage(data: data)
                })
            }
        }
        
        // Run task
        task.resume()
    }
    

}
