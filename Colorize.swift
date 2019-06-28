import UIKit
class Colorize: NSObject {
    public func processPixels(in image: UIImage, color:UIColor) -> UIImage? {
        guard let inputCGImage = image.cgImage else {
            print("unable to get cgImage")
            return nil
        }
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage.width
        let height           = inputCGImage.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            print("unable to create context")
            return nil
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let buffer = context.data else {
            print("unable to get context data")
            return nil
        }
        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
        var colors:[Int] = color.rgb()!
        let white = RGBA32(red: 255, green: 255, blue: 255, alpha: 255)
        for color in 0...colors.count-1{
            if colors[color] < 0 {
                colors[color] = 0
            }
            else if colors[color] > 255{
                colors[color] = 255
            }
        }
        let newColor = RGBA32(red: UInt8(colors[0]), green: UInt8(colors[1]), blue: UInt8(colors[2]), alpha: UInt8(colors[3]))
        for row in 0 ..< Int(height) {
            for column in 0 ..< Int(width) {
                let offset = row * width + column
                if pixelBuffer[offset] == white {
                    pixelBuffer[offset] = newColor
                }
            }
        }
        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
        return outputImage
    }
    struct RGBA32: Equatable {
        var color: UInt32
        var red: UInt8 {
            return UInt8((color >> 24) & 255)
        }
        var green: UInt8 {
            return UInt8((color >> 16) & 255)
        }
        var blue: UInt8 {
            return UInt8((color >> 8) & 255)
        }
        var alpha: UInt8 {
            return UInt8((color >> 0) & 255)
        }
        init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
            color = (UInt32(red) << 24) | (UInt32(green) << 16) | (UInt32(blue) << 8) | (UInt32(alpha) << 0)
        }
        static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
            return lhs.color == rhs.color
        }
    }
}
