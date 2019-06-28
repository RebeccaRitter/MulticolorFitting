import UIKit
import Instructions
internal class CustomCoachMarkBodyView : UIView, CoachMarkBodyView {
    var nextControl: UIControl? {
        get {
            return self.nextButton
        }
    }
    var highlighted: Bool = false
    var nextButton = UIButton()
    var hintLabel = UITextView()
    weak var highlightArrowDelegate: CoachMarkBodyHighlightArrowDelegate? = nil
    override init (frame: CGRect) {
        super.init(frame: frame)
        self.setupInnerViewHierarchy()
    }
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding.")
    }
    fileprivate func setupInnerViewHierarchy() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.white
        self.clipsToBounds = true
        self.layer.cornerRadius = 4
        self.hintLabel.backgroundColor = UIColor.clear
        self.hintLabel.textColor = UIColor.darkGray
        self.hintLabel.font = UIFont.systemFont(ofSize: 20.0)
        self.hintLabel.isScrollEnabled = false
        self.hintLabel.textAlignment = .left
        self.hintLabel.layoutManager.hyphenationFactor = 1.0
        self.hintLabel.isEditable = false
        self.nextButton.translatesAutoresizingMaskIntoConstraints = false
        self.hintLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nextButton.isUserInteractionEnabled = true
        self.hintLabel.isUserInteractionEnabled = false
        self.nextButton.setTitleColor(UIColor.white, for: UIControl.State())
        self.nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        self .nextButton.backgroundColor = UIColor(red: 214/255.0, green: 181/255.0, blue: 154/255.0, alpha: 1.0)
        self.addSubview(nextButton)
        self.addSubview(hintLabel)
        self.addConstraint(NSLayoutConstraint(item: nextButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[nextButton(==44)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil, views: ["nextButton": nextButton]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(5)-[hintLabel]-(5)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil, views: ["hintLabel": hintLabel]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(10)-[hintLabel]-(10)-[nextButton(==80)]-(10)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil, views: ["hintLabel": hintLabel, "nextButton": nextButton]))
    }
}
