import UIKit
public protocol SwiftHUEColorPickerDelegate : class {
	func valuePicked(_ color: UIColor, type: SwiftHUEColorPicker.PickerType)
}
open class SwiftHUEColorPicker: UIView {
	public enum PickerType: Int {
		case color
		case saturation
		case brightness
		case alpha
	}
	public enum PickerDirection: Int {
		case horizontal
		case vertical
	}
	let HUEMaxValue: CGFloat = 360
	let PercentMaxValue: CGFloat = 100
	open weak var delegate: SwiftHUEColorPickerDelegate!
	open var type: PickerType = .color
	open var direction: PickerDirection = .horizontal
	open var currentColor: UIColor {
		get {
			return color
		}
		set(newCurrentColor) {
			color = newCurrentColor
            print(color.hsba())
			var hue: CGFloat = 0
			var s: CGFloat = 0
			var b: CGFloat = 0
			var a: CGFloat = 0
			if color.getHue(&hue, saturation: &s, brightness: &b, alpha: &a) {
				var needUpdate = false
				if hueValue != hue {
					needUpdate = true
				}
				hueValue = hue
				saturationValue = s
				brightnessValue = b
				alphaValue = a
				if needUpdate && hueValue >= 0 && hueValue <= 1 {
					update()
					setNeedsDisplay()
				}
			}
		}
	}
	open var labelFontColor: UIColor = UIColor.white
	open var labelBackgroundColor: UIColor = UIColor(hex: "D6B59A")
	open var labelFont = UIFont(name: "Helvetica Neue", size: 10)
	open var cornerRadius: CGFloat = 0.0
	fileprivate var color: UIColor = UIColor.clear
	fileprivate var currentSelectionY: CGFloat = 0.0
	fileprivate var currentSelectionX: CGFloat = 0.0
	fileprivate var hueImage: UIImage!
	fileprivate var hueValue: CGFloat = 0.0
	fileprivate var saturationValue: CGFloat = 1.0
	fileprivate var brightnessValue: CGFloat = 1.0
	fileprivate var alphaValue: CGFloat = 1.0
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.backgroundColor = UIColor.clear
	}
	override public init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = UIColor.clear
	}
	override open func layoutSubviews() {
		super.layoutSubviews()
		update()
	}
	func update() {
		let offset = (direction == .horizontal ? self.frame.size.height : self.frame.size.width)
		let halfOffset = offset * 0.5
		var size = self.frame.size
		if direction == .horizontal {
			size.width -= offset
		}
		else {
			size.height -= offset
		}
		var value: CGFloat = 0
		switch type {
		case .color:
			value = hueValue
			break
		case .saturation:
			value = saturationValue
			break
		case .brightness:
			value = brightnessValue
			break
		case .alpha:
			value = alphaValue
			break
		}
		currentSelectionX = (value * size.width) + halfOffset
		currentSelectionY = (value * size.height) + halfOffset
	}
	override open func draw(_ rect: CGRect) {
		super.draw(rect)
		let radius = (direction == .horizontal ? self.frame.size.height : self.frame.size.width)
		let halfRadius = radius * 0.5
		var circleX = currentSelectionX - halfRadius
		var circleY = currentSelectionY - halfRadius
		if circleX >= rect.size.width - radius {
			circleX = rect.size.width - radius
		}
		else if circleX < 0 {
			circleX = 0
		}
		if circleY >= rect.size.height - radius {
			circleY = rect.size.height - radius
		}
		else if circleY < 0 {
			circleY = 0
		}
		let circleRect = (direction == .horizontal ? CGRect(x: circleX, y: 0, width: radius, height: radius) : CGRect(x: 0, y: circleY, width: radius, height: radius))
		let circleColor = labelBackgroundColor
		var hueRect = rect
		if hueImage != nil {
			if direction == .horizontal {
				hueRect.size.width -= radius
				hueRect.origin.x += halfRadius
			}
			else {
				hueRect.size.height -= radius
				hueRect.origin.y += halfRadius
			}
			hueImage.draw(in: hueRect)
		}
		let context = UIGraphicsGetCurrentContext()
		circleColor.set()
		context!.addEllipse(in: circleRect)
		context!.setFillColor(circleColor.cgColor)
		context!.fillPath()
		context!.strokePath()
		let textParagraphStyle = NSMutableParagraphStyle()
		textParagraphStyle.alignment = .center
		let attributes: NSDictionary = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): labelFontColor,
										convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): textParagraphStyle,
										convertFromNSAttributedStringKey(NSAttributedString.Key.font): labelFont!]
		var value: CGFloat = 0
		switch type {
		case .color:
			value = hueValue
			break
		case .saturation:
			value = saturationValue
			break
		case .brightness:
			value = brightnessValue
			break
		case .alpha:
			value = alphaValue
			break
		}
		let textValue = Int(value * (type == .color ? HUEMaxValue : PercentMaxValue))
		let text = String(textValue) as NSString
		var textRect = circleRect
		textRect.origin.y += (textRect.size.height - (labelFont?.lineHeight)!) * 0.5
		text.draw(in: textRect, withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attributes as? [String : AnyObject]))
	}
	open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch: AnyObject? = touches.first
		if let point = touch?.location(in: self) {
			handleTouch(point)
		}
	}
	open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch: AnyObject? = touches.first
		if let point = touch?.location(in: self) {
			handleTouch(point)
		}
	}
	open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch: AnyObject? = touches.first
		if let point = touch?.location(in: self) {
			handleTouch(point)
		}
	}
	open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
	}
	func handleTouch(_ touchPoint: CGPoint) {
		currentSelectionX = touchPoint.x
		currentSelectionY = touchPoint.y
		let offset = (direction == .horizontal ? self.frame.size.height : self.frame.size.width)
		let halfOffset = offset * 0.5
		if currentSelectionX < halfOffset {
			currentSelectionX = halfOffset
		}
		else if currentSelectionX >= self.frame.size.width - halfOffset {
			currentSelectionX = self.frame.size.width - halfOffset
		}
		if currentSelectionY < halfOffset {
			currentSelectionY = halfOffset
		}
		else if currentSelectionY >= self.frame.size.height - halfOffset {
			currentSelectionY = self.frame.size.height - halfOffset
		}
		let value = (direction == .horizontal ? CGFloat((currentSelectionX - halfOffset) / (self.frame.size.width - offset))
											  : CGFloat((currentSelectionY - halfOffset) / (self.frame.size.height - offset)))
		switch type {
		case .color:
			hueValue = value
			break
		case .saturation:
			saturationValue = value
			break
		case .brightness:
			brightnessValue = value
			break
		case .alpha:
			alphaValue = value
			break
		}
		color = UIColor(hue: hueValue, saturation: saturationValue, brightness: brightnessValue, alpha: alphaValue)
		if delegate != nil {
			delegate.valuePicked(color, type: type)
		}
		setNeedsDisplay()
	}
}
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
