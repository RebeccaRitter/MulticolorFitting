import Foundation
import UIKit
@IBDesignable
class DesignableButton: UIButton {
    @IBInspectable var fontIPhone: CGFloat = 0{
        didSet {
            if UIScreen.main.bounds.width >= 768{
                self.titleLabel?.font =  UIFont(name: "SFProText-Regular", size: fontIPad)
            }else{
                self.titleLabel?.font = UIFont(name: "SFProText-Regular", size: WIPH(w: fontIPhone))
            }
        }
    }
    @IBInspectable var fontIPad: CGFloat = 0 {
        didSet {
            if UIScreen.main.bounds.width >= 768{
                self.titleLabel?.font = UIFont(name: "SFProText-Regular", size: WIPA(w: fontIPad))
            }else{
                self.titleLabel?.font =  UIFont(name: "SFProText-Regular", size: fontIPhone)
            }
        }
    }
    @IBInspectable var positiontitleIPhone: CGFloat = 0{
        didSet {
            if UIScreen.main.bounds.width >= 768{
                self.titleEdgeInsets = edgeInsetsIphone(edge: UIEdgeInsets(top: 0, left: positiontitleIPad, bottom: 0, right: 0))
            }else{
                self.titleEdgeInsets = edgeInsetsIphone(edge: UIEdgeInsets(top: 0, left: positiontitleIPhone, bottom: 0, right: 0))
            }
        }
    }
    @IBInspectable var positiontitleIPad: CGFloat = 0 {
        didSet {
            if UIScreen.main.bounds.width >= 768{
                self.titleEdgeInsets = edgeInsetsIphone(edge: UIEdgeInsets(top: 0, left: positiontitleIPad, bottom: 0, right: 0))
            }else{
                self.titleEdgeInsets = edgeInsetsIphone(edge: UIEdgeInsets(top: 0, left: positiontitleIPhone, bottom: 0, right: 0))
            }
        }
    }
}
@objc extension UIButton {
    @objc enum Position: Int {
        case top, bottom, left, right ,T
    }
    @objc func set(image: UIImage?, title: String, titlePosition: Position, additionalSpacing: CGFloat, state: UIControl.State){
        imageView?.contentMode = .center
        setImage(image, for: state)
        setTitle(title, for: state)
        titleLabel?.contentMode = .center
        adjust(title: title as NSString, at: titlePosition, with: additionalSpacing)
    }
    @objc func set(image: UIImage?, attributedTitle title: NSAttributedString, at position: Position, width spacing: CGFloat, state: UIControl.State){
        imageView?.contentMode = .center
        setImage(image, for: state)
        adjust(attributedTitle: title, at: position, with: spacing)
        titleLabel?.contentMode = .center
        setAttributedTitle(title, for: state)
    }
    @objc private func adjust(title: NSString, at position: Position, with spacing: CGFloat) {
        let imageRect: CGRect = self.imageRect(forContentRect: frame)
        let titleFont: UIFont = titleLabel?.font ?? UIFont()
        let titleSize: CGSize = title.size(withAttributes: [NSAttributedString.Key.font: titleFont])
        arrange(titleSize: titleSize, imageRect: imageRect, atPosition: position, withSpacing: spacing)
    }
    @objc private func adjust(attributedTitle: NSAttributedString, at position: Position, with spacing: CGFloat) {
        let imageRect: CGRect = self.imageRect(forContentRect: frame)
        let titleSize = attributedTitle.size()
        arrange(titleSize: titleSize, imageRect: imageRect, atPosition: position, withSpacing: spacing)
    }
    @objc private func arrange(titleSize: CGSize, imageRect:CGRect, atPosition position: Position, withSpacing spacing: CGFloat) {
        switch (position) {
        case .top:
            titleEdgeInsets = UIEdgeInsets(top: -(imageRect.height + titleSize.height + spacing), left: -(imageRect.width), bottom: 0, right: 0)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
            contentEdgeInsets = UIEdgeInsets(top: spacing / 2 + titleSize.height, left: -imageRect.width/2, bottom: 0, right: -imageRect.width/2)
        case .bottom:
            titleEdgeInsets = UIEdgeInsets(top: (imageRect.height + titleSize.height + spacing), left: -(imageRect.width), bottom: 0, right: 0)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: -imageRect.width/2, bottom: spacing / 2 + titleSize.height, right: -imageRect.width/2)
        case .left:
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imageRect.width * 2), bottom: 0, right: 0)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -(titleSize.width * 2 + spacing))
            contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing / 2)
        case .right:
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case .T:
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 78, bottom: 0, right: 0)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 0)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
}
