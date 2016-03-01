import UIKit
import SDWebImage

class EventsViewController : UITableViewController {
    private let segmentedControl = UISegmentedControl(items: ["Recent", "Top"])
    private let  activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    private var events = [Sort : [Event]]()
    var politician: Politician?
    
    private var activeSort: Sort {
        return segmentedControl.selectedSegmentIndex == 0 ? .Recent : .Top
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = simpleBackButton()
        
        segmentedControl.frame = CGRect(x: 0, y: 0, width: 180, height: segmentedControl.frame.height)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: "segmentIndexSelected:", forControlEvents: .ValueChanged)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 110
        tableView.registerNib(UINib(nibName: "EventCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "EventCell")
        
        activityIndicator.center = tableView.center
        activityIndicator.startAnimating()
        tableView.backgroundView = activityIndicator
        
        refreshControl = UIRefreshControl()
        refreshControl!.tintColor = Colors.purple
        refreshControl!.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if politician == nil {
            navigationItem.titleView = segmentedControl
        } else {
            navigationItem.title = politician!.name
        }
        
        refresh(self)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events[activeSort]?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let event = events[activeSort]![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath) as! EventCell
        
        if (CGFloat(Float(arc4random()) /  Float(UInt32.max)) > 0.75) {
            if (CGFloat(Float(arc4random()) /  Float(UInt32.max)) > 0.5) {
                cell.contribution.textColor = Colors.green
                cell.contribution.text = "Supported ($5)"
            } else {
                cell.contribution.textColor = Colors.orange
                cell.contribution.text = "Opposed ($5)"
            }
        } else {
            cell.contribution.text = nil
        }
        
        event.politician?.setThumbnail(cell.thumbnail)
        cell.headline.presentMarkdown(event.headline)
        cell.time.text = event.created.humanReadableTimeSinceNow
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        performSegueWithIdentifier("EventSegue", sender: events[activeSort]![indexPath.row])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EventSegue" {
            let eventViewController = segue.destinationViewController as! EventViewController
            eventViewController.event = sender as! Event
            eventViewController.hidePolitician = politician != nil
        }
    }
    
    func segmentIndexSelected(sender: UISegmentedControl) {
        tableView.reloadData()
        refresh(self)
    }
    
    func refresh(sender: AnyObject) {
        if sender is EventsViewController && events[activeSort] != nil {
            return
        }
        
        tableView.backgroundView = activityIndicator
        
        let sort = activeSort
        let url = sort == .Top ? Endpoints.topEvents : Endpoints.recentEvents
        Requests.get(url, completionHandler: { response, error in
            self.refreshControl!.endRefreshing()
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.events[sort]?.removeAll()
                
                if response?.statusCode == 200 {
                    self.events[sort] = [Event]()
                    if let stories = response!.body!["events"] as? [[String : AnyObject]] {
                        for story in stories {
                            do {
                                self.events[sort]!.append(try Event(data: story))
                            } catch _ {
                                p("Skipping invalid event")
                            }
                        }
                    }
                    
                    self.tableView.backgroundView = nil
                } else {
                    // Something bad happened
                }
                
                self.tableView.reloadData()
            }
        })
    }
    
    enum Sort : String {
        case Recent = "recent", Top = "top"
    }
}
