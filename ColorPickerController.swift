import UIKit
open class ColorPickerController: NSObject {
    open var onColorChange:((_ color:UIColor, _ finished:Bool)->Void)? = nil
    open var huePicker:HuePicker
    open var colorWell:ColorWell {
        didSet {
            huePicker.setHueFromColor(colorWell.color)
            colorPicker.color =  colorWell.color
        }
    }
    open var colorPicker:ColorPicker
    open var color:UIColor? {
        set(value) {
            colorPicker.color = value!
            colorWell.color = value!
            huePicker.setHueFromColor(value!)
        }
        get {
            return colorPicker.color
        }
    }
    public init(svPickerView:ColorPicker, huePickerView:HuePicker, colorWell:ColorWell) {
        self.huePicker = huePickerView
        self.colorPicker = svPickerView
        self.colorWell = colorWell
        self.colorWell.color = colorPicker.color
        self.huePicker.setHueFromColor(colorPicker.color)
        super.init()
        self.colorPicker.onColorChange = {(color, finished) -> Void in
            self.huePicker.setHueFromColor(color)
            self.colorWell.previewColor = (finished) ? nil : color
            if(finished) {self.colorWell.color = color}
            self.onColorChange?(color, finished)
        }
        self.huePicker.onHueChange = {(hue, finished) -> Void in
            self.colorPicker.h = CGFloat(hue)
            let color = self.colorPicker.color
            self.colorWell.previewColor = (finished) ? nil : color
            if(finished) {self.colorWell.color = color}
            self.onColorChange?(color, finished)
        }
    }
}
