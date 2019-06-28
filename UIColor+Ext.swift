import Foundation
extension UIColor
{
    var hexString:String {
        let colorRef = self.cgColor.components
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        if let red = colorRef?[0]{
            r = red
        }
        else{
            r = 0
        }
        if let green = colorRef?[1]{
            g = green
        }
        else{
            g = 0
        }
        if (colorRef?.count)! > 2{
            if let blue = colorRef?[2]{
                b = blue
            }
            else{
                b = 0
            }
        }
        return String(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    }
    func rgb() -> [Int]? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            return [iRed,iGreen,iBlue,iAlpha]
        } else {
            return nil
        }
    }
}
