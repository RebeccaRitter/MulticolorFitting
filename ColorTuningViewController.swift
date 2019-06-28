import UIKit
class ColorTuningViewController: UIViewController, SwiftHUEColorPickerDelegate {
    public var imageFromPicker = UIImage()
    private var colorize:Colorize = Colorize()
    private var selectedColor = UIColor()
    @IBOutlet var HUEPicker: SwiftHUEColorPicker!
    @IBOutlet var brightnessPicker: SwiftHUEColorPicker!
    @IBOutlet var saturationPicker: SwiftHUEColorPicker!
    @IBOutlet var colorTuningFillOutlet: UIImageView!
    @IBOutlet var pickedImageOutlet: UIImageView!
    @IBOutlet var hexValue: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        setupPickers()
    }
    @IBAction func closeAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func doneAction(_ sender: UIButton) {
        let dataDict:[String: UIColor] = ["selectedColor": selectedColor]
        NotificationCenter.default.post(Notification(name: NSNotification.Name(rawValue: "Notification.changeClothColorFromDetection"), object: nil, userInfo: dataDict))
        self.dismiss(animated: true, completion: nil)
    }
    fileprivate func setupPickers() {
        let averageColor = imageFromPicker.averageColor()
        HUEPicker.delegate = self
        HUEPicker.direction = SwiftHUEColorPicker.PickerDirection.horizontal
        HUEPicker.type = SwiftHUEColorPicker.PickerType.color
        HUEPicker.currentColor = averageColor!
        saturationPicker.delegate = self
        saturationPicker.direction = SwiftHUEColorPicker.PickerDirection.horizontal
        saturationPicker.type = SwiftHUEColorPicker.PickerType.saturation
        saturationPicker.currentColor = averageColor!
        brightnessPicker.delegate = self
        brightnessPicker.direction = SwiftHUEColorPicker.PickerDirection.horizontal
        brightnessPicker.type = SwiftHUEColorPicker.PickerType.brightness
        brightnessPicker.currentColor = averageColor!
        pickedImageOutlet.image = imageFromPicker
        selectedColor = averageColor!
        let colorString = averageColor?.hexString
        hexValue.text = colorString
        colorTuningFillOutlet.image = UIImage(named: "colorDetectionFill")
        colorTuningFillOutlet.image = colorTuningFillOutlet.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        colorTuningFillOutlet.image = colorize.processPixels(in: colorTuningFillOutlet.image!, color: averageColor!)
    }
    func valuePicked(_ color: UIColor, type: SwiftHUEColorPicker.PickerType) {
        switch type {
            case SwiftHUEColorPicker.PickerType.color:
                HUEPicker.currentColor = color
                saturationPicker.currentColor = color
                brightnessPicker.currentColor = color
                break
            case SwiftHUEColorPicker.PickerType.saturation:
                HUEPicker.currentColor = color
                saturationPicker.currentColor = color
                brightnessPicker.currentColor = color
                break
            case SwiftHUEColorPicker.PickerType.brightness:
                HUEPicker.currentColor = color
                saturationPicker.currentColor = color
                brightnessPicker.currentColor = color
                break
            default:
                break
        }
        selectedColor = color
        let colorString:String = color.hexString
        hexValue.text = colorString
        colorTuningFillOutlet.image = UIImage(named: "colorDetectionFill")
        colorTuningFillOutlet.image = colorTuningFillOutlet.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        colorTuningFillOutlet.image = colorize.processPixels(in: colorTuningFillOutlet.image!, color: color)
    }
}
