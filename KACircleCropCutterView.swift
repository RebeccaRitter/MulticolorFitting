import UIKit
class KACircleCropCutterView: UIView {
    override var frame: CGRect {
        didSet {
            setNeedsDisplay()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isOpaque = false
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isOpaque = false
    }
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7).setFill()
        UIRectFill(rect)
        let circle = UIBezierPath(ovalIn: CGRect(x: rect.size.width/2 - 240/2, y: rect.size.height/2 - 240/2, width: 240, height: 240))
        context?.setBlendMode(.clear)
        UIColor.clear.setFill()
        circle.fill()
        let square = UIBezierPath(rect: CGRect(x: rect.size.width/2 - 240/2, y: rect.size.height/2 - 240/2, width: 240, height: 240))
        UIColor.lightGray.setStroke()
        square.lineWidth = 1.0
        context?.setBlendMode(.normal)
        square.stroke()
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews as [UIView] {
            if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
}
