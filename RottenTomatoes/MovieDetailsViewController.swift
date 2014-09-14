//
//  MovieDetailsViewController.swift
//  RottenTomatoes
//
//  Created by Nag Varun Chunduru on 9/11/14.
//  Copyright (c) 2014 cnv. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController, UINavigationBarDelegate {
    
    var movieDict: NSDictionary?
    var isExpanded = false

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var synopsisArea: UITextView!
    @IBOutlet weak var synopsisView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateView()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateView() {
        self.navigationBar.title = self.movieDict?["title"] as NSString
        self.movieTitle.text = self.movieDict?["title"] as NSString
        self.synopsisArea.text = self.movieDict?["synopsis"] as NSString

        let posters = movieDict?["posters"] as NSDictionary
        var urlString: NSString =  posters["thumbnail"] as NSString
        
        urlString = urlString.stringByReplacingOccurrencesOfString("tmb", withString: "pro")
        var image = ImageCache[urlString]
        self.moviePoster.image = image

        
        urlString =  posters["detailed"] as NSString
        urlString = urlString.stringByReplacingOccurrencesOfString("tmb", withString: "ori")
        image = ImageCache[urlString]
        if image == nil {
            var imgURL: NSURL = NSURL(string: urlString)
            
            // Download an NSData representation of the image at the URL
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    image = UIImage(data: data)
                    
                    // Store the image in to our cache
                    ImageCache[urlString] = image
                    self.moviePoster.image = image
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.moviePoster.image = image
            })
        }
    }
    
    func expand() -> Void {
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
            self.synopsisView.frame.origin.y = self.view.frame.height - self.synopsisView.frame.height
            }, completion: { finished in
                println("Synopsis revealed!")
        })
    }
    
    func collapse() -> Void {
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
            self.synopsisView.frame.origin.y = self.synopsisView.frame.height
            }, completion: { finished in
                println("Synopsis collapsed!")
        })
    }

    @IBAction func onTap(sender: AnyObject) {
        if !self.isExpanded {
            self.expand()
        } else {
            self.collapse()
        }
        self.isExpanded = !self.isExpanded
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
