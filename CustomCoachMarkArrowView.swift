import UIKit
import Instructions
internal class CustomCoachMarkArrowView : UIView, CoachMarkArrowView {
    var topPlateImage = UIImage(named: "tutorial_swipeleftright")
    var plate = UIImageView()
    var highlighted: Bool = false
    fileprivate var column = UIView()
    init?(orientation: CoachMarkArrowOrientation, imageName:String) {
        super.init(frame: CGRect.zero)
        self.plate.image = UIImage(named: imageName)
        self.plate.contentMode = .scaleAspectFit
        self.translatesAutoresizingMaskIntoConstraints = false
        self.column.translatesAutoresizingMaskIntoConstraints = false
        self.plate.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(plate)
        self.addSubview(column)
        plate.backgroundColor = UIColor.clear
        column.backgroundColor = UIColor.white
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[plate]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["plate" : plate]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[plate(50)]-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["plate" : plate]))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding.")
    }
}
