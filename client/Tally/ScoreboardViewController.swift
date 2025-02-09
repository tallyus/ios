class ScoreboardViewController : UITableViewController {
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    private var politicians = [Politician]()
    private var lastAppeared: NSDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "All Time"
        navigationItem.backBarButtonItem = simpleBackButton()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 86
        
        refreshControl = UIRefreshControl()
        refreshControl!.tintColor = Colors.primary
        refreshControl!.addTarget(self, action: #selector(refresh(_:)), forControlEvents: .ValueChanged)
        
        activityIndicator.center = tableView.center
        activityIndicator.startAnimating()
        tableView.backgroundView = activityIndicator
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let lastAppeared = lastAppeared {
            if abs(Int(lastAppeared.timeIntervalSinceNow)) > 120 {
                refresh(refreshControl!)
            }
        } else {
            refresh(self)
        }
        
        lastAppeared = NSDate()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return politicians.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let politician = politicians[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("ScoreboardCell", forIndexPath: indexPath) as! ScoreboardCell
        
        politician.setThumbnail(cell.thumbnail, thumbnailIndex: politician.thumbnails.count - 1)
        cell.name.text = politician.name
        cell.jobTitle.text = politician.jobTitle
        
        cell.position.text = "\(indexPath.row + 1)"
        
        cell.graph.politician = politician
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        performSegueWithIdentifier("PoliticianSegue", sender: politicians[indexPath.row])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PoliticianSegue" {
            let eventsViewController = segue.destinationViewController as! EventsViewController
            eventsViewController.politician = (sender as! Politician)
        }
    }
    
    func refresh(sender: AnyObject) {
        if sender is EventsViewController && politicians.count > 0 {
            tableView.reloadData()
            return
        }
        
        tableView.backgroundView = activityIndicator
        
        Requests.get(Endpoints.allTimeScoreboard, completionHandler: { response, error in
            let delay = self.refreshControl!.refreshing ? 0.5 : 0
            
            self.refreshControl!.endRefreshing()
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.tableView.backgroundView = nil
                
                self.politicians.removeAll()
                
                if response?.statusCode == 200 {
                    if let politicians = response!.body!["politicians"] as? [[String : AnyObject]] {
                        for politician in politicians {
                            do {
                                self.politicians.append(try Politician(data: politician))
                            } catch _ {
                                p("Skipping invalid politician")
                            }
                        }
                    }
                    
                    if self.politicians.count == 0 {
                        self.tableView.backgroundView = NSBundle.mainBundle().loadNibNamed("EmptyStateView", owner: self, options: nil)[0] as! EmptyStateView
                    }
                } else {
                    let emptyStateView = NSBundle.mainBundle().loadNibNamed("EmptyStateView", owner: self, options: nil)[0] as! EmptyStateView
                    emptyStateView.label.text = "Something bad happened"
                    self.tableView.backgroundView = emptyStateView
                }
                
                self.tableView.reloadData()
            }
        })
    }
}
