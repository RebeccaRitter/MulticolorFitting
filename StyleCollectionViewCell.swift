import UIKit
class StyleCollectionViewCell: UICollectionViewCell {
    public var topColorValue:UIColor = UIColor()
    public var beltColorValue:UIColor = UIColor()
    public var bottomColorValue:UIColor = UIColor()
    public var shoesColorValue:UIColor = UIColor()
    @IBOutlet var topColor: UIView!
    @IBOutlet var beltColor: UIView!
    @IBOutlet var bottomColor: UIView!
    @IBOutlet var shoesColor: UIView!
    @IBOutlet var maskImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    public func updateCellColors(){
        topColor.backgroundColor = topColorValue
        beltColor.backgroundColor = beltColorValue
        bottomColor.backgroundColor = bottomColorValue
        shoesColor.backgroundColor = shoesColorValue
    }
    @IBAction func styleSelectedAction(_ sender: UIButton) {
        print(sender.tag)
    }
}
