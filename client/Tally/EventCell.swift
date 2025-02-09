import UIKit

class EventCell : UITableViewCell {
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var pictureIndicator: UIActivityIndicatorView!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var pictureHeight: NSLayoutConstraint!
    @IBOutlet weak var pictureTopSpace: NSLayoutConstraint!
    @IBOutlet weak var pictureBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var graph: SupportOpposeView!
    @IBOutlet weak var buttonsHolder: UIStackView!
    @IBOutlet weak var oppose: UIButton!
    @IBOutlet weak var support: UIButton!
}
