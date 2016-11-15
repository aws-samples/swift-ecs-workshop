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

    
    override func viewDidLoad() {
        super.viewDidLoad();
      
        let url = NSURL(string:"http://54.147.8.176/products")
        let data = NSData(contentsOfURL:url!)
        if data != nil {
            productJson.text = String(data:data!, encoding:NSUTF8StringEncoding);
        }

      
        var swiftService = [String]()
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            
            if let products = json[""] as? [[String: AnyObject]] {
                for product in products {
                    if let url = json["url"] as? String {
                        swiftService.append(url)
                    }
               }
            }
        } catch {
            print("error serializing JSON: \(error)")
        }
        
        print("--------------------------------------------")
        print(swiftService)
        
        
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
        
        
    			    //let fullURL = "http://54.152.155.191/products"
        http://54.147.8.176/products
        //let fullURL = "https://www.google.com"
        let fullURL = "http://media.performancebike.com/images/performance/products/product-hi/31-2802-RED-SIDE.jpg?resize=1500px:1500px&output-quality=100"

        productImageView.image = UIImage(named: "schwin")
        
        let url = NSURL(string: fullURL)
        let requestObj = NSURLRequest(URL: url!)
        //productWebView.loadData(data!, MIMEType: "application/txt", textEncodingName: "UTF-8", baseURL: nil);
        //productWebView.loadRequest(requestObj)
        productWebView.loadHTMLString(htmlString ,url)
*/
        
    }

    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
