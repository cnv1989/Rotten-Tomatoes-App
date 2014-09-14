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

    @IBOutlet weak var casts: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var mpaaRating: UILabel!
    @IBOutlet weak var runtime: UILabel!
    @IBOutlet weak var released: UILabel!
    @IBOutlet weak var audienceScore: UILabel!
    
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
        self.navigationBar.title = self.movieDict!["title"] as NSString
        self.movieTitle.text = self.movieDict!["title"] as NSString
        self.synopsisArea.text = self.movieDict!["synopsis"] as NSString

        var ratings: NSDictionary = self.movieDict!["ratings"] as NSDictionary
        
        var audienceScore = ratings["audience_score"] as Int!
        if audienceScore != nil {
            self.audienceScore!.text = "\(audienceScore)%"
        } else {
            self.audienceScore!.text = "n/a"
        }
        
        var mpaa_rating = self.movieDict!["mpaa_rating"] as NSString!
        if mpaa_rating != nil {
            self.mpaaRating.text = mpaa_rating
        }

        var year: AnyObject = self.movieDict!["year"]!
        self.released.text = "Year: \(year)"
        
        var runtime: AnyObject = self.movieDict!["runtime"]!
        
        var rt = "\(runtime)"
        
        if !rt.isEmpty {
            var time = rt.toInt()
            var hrs = time! / 60
            var mins = time! % 60
            if (hrs > 0) {
                self.runtime.text = "Runtime: \(hrs) hr. \(mins) min."
            } else {
                self.runtime.text = "Runtime: \(mins) min."
            }
        }
        
        
        var casts = self.movieDict!["abridged_cast"] as NSArray
        var castsText = ""
        for cast in casts {
            var name = cast["name"] as NSString
            castsText += "\(name), "
        }
        self.casts.text = castsText
        
        
        let posters = movieDict?["posters"] as NSDictionary
        var urlString: NSString =  posters["thumbnail"] as NSString
        
        urlString = urlString.stringByReplacingOccurrencesOfString("tmb", withString: "pro")
        var imageThumbnail = ImageCache[urlString]

        
        urlString =  posters["thumbnail"] as NSString
        urlString = urlString.stringByReplacingOccurrencesOfString("tmb", withString: "ori")
        var image = ImageCache[urlString]
        
        let imageRequestSuccess = {
            (request : NSURLRequest!, response : NSHTTPURLResponse!, image : UIImage!) -> Void in
            ImageCache[urlString] = image
            self.moviePoster.image = image;
        }

        let imageRequestFailure = {
            (request : NSURLRequest!, response : NSHTTPURLResponse!, error : NSError!) -> Void in
            NSLog("imageRequrestFailure")
        }
        
        if image == nil {
            dispatch_async(dispatch_get_main_queue(), {
                self.moviePoster.image = imageThumbnail
            })

            var imgURL: NSURL = NSURL(string: urlString)
            // Download an NSData representation of the image at the URL
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            self.moviePoster.setImageWithURLRequest(request, placeholderImage: nil, success: imageRequestSuccess, failure: imageRequestFailure)
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
