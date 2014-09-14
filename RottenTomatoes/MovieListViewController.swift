//
//  MovieListViewController.swift
//  RottenTomatoes
//
//  Created by Nag Varun Chunduru on 9/11/14.
//  Copyright (c) 2014 cnv. All rights reserved.
//

import UIKit


let BOXOFFICE = 1
let INTHEATER = 2
let OPENING = 3
let UPCOMING = 4
let ONDVD = 5

var ImageCache =  [String : UIImage]()

class MovieListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UINavigationBarDelegate, UITabBarDelegate, UIScrollViewDelegate {
    
    var type: Int = BOXOFFICE
    
    
    var refreshControl: UIRefreshControl!
    
    let ApiKey = "ntnknx9rzn8e7azsdzuphec5" // Fill with the key you registered at http://developer.rottentomatoes.com
    
    @IBOutlet var panRecognizer: UIPanGestureRecognizer!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var movieListView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    @IBOutlet weak var tabBar: UITabBar!
    
    @IBOutlet weak var boxOffice: UITabBarItem!
    @IBOutlet weak var inTheaters: UITabBarItem!
    @IBOutlet weak var opening: UITabBarItem!
    @IBOutlet weak var upcoming: UITabBarItem!
    @IBOutlet weak var onDvd: UITabBarItem!
    
    var RottenTomatoesURLString: NSString?

    var moviesArray: NSArray?
    
    var limit: Int = 10
    var pageNumber: Int = 1
    var resultsPerPage: Int = 10
    var searching = false
    
    var boxOfficeListCount: Int = 10
    var inTheatersListCount: Int = 10
    var openingListCount: Int = 10
    var upcomingListCount: Int = 10
    var onDvdListCount: Int = 10

    @IBOutlet weak var navigationBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Loading Movies")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.movieListView.addSubview(refreshControl)

        self.activityIndicator.startAnimating()
        self.activityIndicator.center = self.movieListView.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.tintColor = UIColor.blackColor()
        self.tabBar.selectedItem = self.boxOffice
        
        self.type = BOXOFFICE
        self.update()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if moviesArray != nil {
            return moviesArray!.count
        } else {
            return 0;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let movieDict = self.moviesArray![indexPath.row] as NSDictionary
        let cell = movieListView.dequeueReusableCellWithIdentifier("com.cnv.rottentomatoes.moviecell") as MovieTableViewCell;
        cell.titleLabel?.text = movieDict["title"] as NSString
        cell.synopsisLabel?.text = movieDict["synopsis"] as NSString
        let posters = movieDict["posters"] as NSDictionary
        var urlString: NSString =  posters["thumbnail"] as NSString
        urlString = urlString.stringByReplacingOccurrencesOfString("tmb", withString: "pro")
        
        var image = ImageCache[urlString]
        
        
        if( image == nil ) {
            // If the image does not exist, we need to download it
            var imgURL: NSURL = NSURL(string: urlString)
            
            // Download an NSData representation of the image at the URL
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    image = UIImage(data: data)
                    
                    // Store the image in to our cache
                    ImageCache[urlString] = image
                    cell.thumbnail.image = image
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
            
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                cell.thumbnail.image = image
            })
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func searchMovies(searchTerm: String = "") -> Void {
        self.activityIndicator.startAnimating()
        let moviesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        if let escapedSearchTerm = moviesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            self.RottenTomatoesURLString = "http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=\(ApiKey)&q=\(escapedSearchTerm)&page_limit=\(self.resultsPerPage)&page\(self.pageNumber)"
            updateMoviesList()
        }
        self.resultsPerPage += 10
    }
    
    func updateMoviesList() -> Void {

        let request = NSMutableURLRequest(URL: NSURL.URLWithString(self.RottenTomatoesURLString!))
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:{ (response, data, error) in
            var errorValue: NSError? = nil
            if data == nil {
                if self.hasConnectivity() == false {
                    self.navigationBar.title = "⚠️ Network Error!"
                } else {
                    self.navigationBar.title = "⚠️ Something is wrong!"
                }
                self.activityIndicator.stopAnimating()
                return
            }
            let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &errorValue)
            if error != nil {
                println("\(error.description)")
            }
            
            if parsedResult != nil {
                let dictionary = parsedResult! as NSDictionary
                var movies = dictionary["movies"] as? NSArray
                if movies?.count > 0 {
                    self.moviesArray = movies?.reverseObjectEnumerator().allObjects
                    self.movieListView.reloadData()
                }
                self.refreshControl.endRefreshing()
                self.activityIndicator.stopAnimating()
            }
        })
    }
    
    func boxOfficeMovies(Void) -> Void {
        self.navigationBar.title = "Box Office"
        self.RottenTomatoesURLString = "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=\(ApiKey)&limit=\(self.boxOfficeListCount)"
        updateMoviesList()
    }
    
    func inTheaterMovies(Void) -> Void {
        self.navigationBar.title = "In Theaters"
        self.RottenTomatoesURLString = "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?apikey=\(ApiKey)&limit=\(self.inTheatersListCount)"
        updateMoviesList()
    }
    
    func openingMovies(Void) -> Void {
        self.navigationBar.title = "Opening This Week"
        self.RottenTomatoesURLString = "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/opening.json?apikey=\(ApiKey)&limit=\(self.openingListCount)"
        updateMoviesList()
    }
    
    func upcomingMovies(Void) -> Void {
        self.navigationBar.title = "Upcoming Movies"
        self.RottenTomatoesURLString = "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/upcoming.json?apikey=\(ApiKey)&limit=\(self.upcomingListCount)"
        updateMoviesList()
    }
    
    func onDvdMovies(Void) -> Void {
        self.navigationBar.title = "Top Rentals"
        self.RottenTomatoesURLString = "http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=\(ApiKey)&limit=\(self.onDvdListCount)"
        updateMoviesList()
    }
    
    func update() -> Void {
        switch (self.type) {
        case BOXOFFICE:
            self.boxOfficeMovies()
        case INTHEATER:
            self.inTheaterMovies()
        case OPENING:
            self.openingMovies()
        case UPCOMING:
            self.upcomingMovies()
        case ONDVD:
            self.onDvdMovies()
        default:
            self.boxOfficeMovies()
        }
    }

    func updateCount() -> Void {
        switch (self.type) {
        case BOXOFFICE:
            self.boxOfficeListCount += 10
        case INTHEATER:
            self.inTheatersListCount += 10
        case OPENING:
            self.openingListCount += 10
        case UPCOMING:
            self.upcomingListCount += 10
        case ONDVD:
            self.onDvdListCount += 10
        default:
            self.boxOfficeListCount += 10
        }
    }
    
    
    @IBAction func refresh(sender: AnyObject) {
        if self.searching == true {
            self.searchMovies(searchTerm: self.searchBar.text)
        } else {
            self.updateCount()
            self.update()
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchMovies(searchTerm: searchBar.text)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        println("start searching")
        self.searching = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        self.update()
        self.searching = false
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        self.activityIndicator.startAnimating()
        self.type = item.tag
        self.update()
    }

    func hasConnectivity() -> Bool {
        let reachability: Reachability = Reachability.reachabilityForInternetConnection()
        let networkStatus: Int = reachability.currentReachabilityStatus().value
        return networkStatus != 0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var detailsViewController: MovieDetailsViewController = segue.destinationViewController as MovieDetailsViewController
        var index = self.movieListView.indexPathForSelectedRow()?.row
        var movieDict = self.moviesArray![index!] as NSDictionary
        detailsViewController.movieDict = movieDict
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
    