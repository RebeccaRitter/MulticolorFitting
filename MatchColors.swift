import UIKit
enum colorMatchingAlgorithms{
    case complementaryColorRGB
    case analoguosRGB
    case splitComplementaryRGB
    case monoChromatic
    case triadic
    case skinWithClothesRGB
}
class MatchColors: NSObject {
    public var chosenAlgorithm:colorMatchingAlgorithms = colorMatchingAlgorithms.complementaryColorRGB
    func matchGlobal(topColor:UIColor, beltColor:UIColor, bottomColor:UIColor, shoesColor:UIColor, skinColor:UIColor)->String{
        switch chosenAlgorithm {
        case .complementaryColorRGB:
            let topHSBA = topColor.hsba()
            let bottomHSBA = bottomColor.hsba()
            let beltHSBA = beltColor.hsba()
            let shoesHSBA = shoesColor.hsba()
            var consideredChecks:CGFloat = 0
            var hueCheckResultClothes:CGFloat = 0
            var hueCheckResultTopBelt:CGFloat = 0
            var hueCheckResultTopShoes:CGFloat = 0
            var hueCheckResultBottomBelt:CGFloat = 0
            var hueCheckResultBottomShoes:CGFloat = 0
            if topHSBA.s > MatchingCriterias.minimumSaturation && bottomHSBA.s > MatchingCriterias.minimumSaturation {
                hueCheckResultClothes = checkHUEsComplementarityInRGB(color1: topColor, color2: bottomColor)
                consideredChecks += 1
            }
            if topHSBA.s > MatchingCriterias.minimumSaturation && beltHSBA.s > MatchingCriterias.minimumSaturation {
                hueCheckResultTopBelt = checkHUEsComplementarityInRGB(color1: topColor, color2: beltColor)
                consideredChecks += 1
            }
            if topHSBA.s > MatchingCriterias.minimumSaturation && shoesHSBA.s > MatchingCriterias.minimumSaturation {
                hueCheckResultTopShoes = checkHUEsComplementarityInRGB(color1: topColor, color2: shoesColor)
                consideredChecks += 1
            }
            if bottomHSBA.s > MatchingCriterias.minimumSaturation && beltHSBA.s > MatchingCriterias.minimumSaturation {
                hueCheckResultBottomBelt = checkHUEsComplementarityInRGB(color1: bottomColor, color2: beltColor)
                consideredChecks += 1
            }
            if bottomHSBA.s > MatchingCriterias.minimumSaturation && shoesHSBA.s > MatchingCriterias.minimumSaturation {
                hueCheckResultBottomShoes = checkHUEsComplementarityInRGB(color1: bottomColor, color2: shoesColor)
                consideredChecks += 1
            }
            if consideredChecks == 0{
                consideredChecks = 1
            }
            var hueResultComplementary:String = ""
            if (hueCheckResultClothes + hueCheckResultTopBelt + hueCheckResultTopShoes + hueCheckResultBottomBelt + hueCheckResultBottomShoes) < MatchingCriterias.complementaryColorDegrees*consideredChecks
            {
                hueResultComplementary = NSLocalizedString("MatchColors_Match", comment: "")
            }
            else{
                hueResultComplementary = NSLocalizedString("MatchColors_NoMatch", comment: "")
            }
            return hueResultComplementary
        case .monoChromatic:
            var hueCheckResultClothes:Bool = false
            var hueCheckResultTopBelt:Bool = false
            var hueCheckResultTopShoes:Bool = false
            var hueCheckResultBottomBelt:Bool = false
            var hueCheckResultBottomShoes:Bool = false
            hueCheckResultClothes = checkHUEsSimilarityInRGB(color1: topColor, color2: bottomColor)
            hueCheckResultTopBelt = checkHUEsSimilarityInRGB(color1: topColor, color2: beltColor)
            hueCheckResultTopShoes = checkHUEsSimilarityInRGB(color1: topColor, color2: shoesColor)
            hueCheckResultBottomBelt = checkHUEsSimilarityInRGB(color1: bottomColor, color2: beltColor)
            hueCheckResultBottomShoes = checkHUEsSimilarityInRGB(color1: bottomColor, color2: shoesColor)
            if (hueCheckResultClothes && hueCheckResultTopBelt && hueCheckResultTopShoes && hueCheckResultBottomBelt && hueCheckResultBottomShoes) == true {
                return NSLocalizedString("MatchColors_Match", comment: "")
            }
            else{
                return NSLocalizedString("MatchColors_NoMatch", comment: "")
            }
        case .analoguosRGB:
           var hueCheckResultClothes:Bool = false
           var hueCheckResultTopBelt:Bool = false
           var hueCheckResultTopShoes:Bool = false
           var hueCheckResultBottomBelt:Bool = false
           var hueCheckResultBottomShoes:Bool = false
           hueCheckResultClothes = checkHUEsAnalogyInRGB(color1: topColor, color2: bottomColor, angle:MatchingCriterias.analogousAngle)
           hueCheckResultTopBelt = checkHUEsAnalogyInRGB(color1: topColor, color2: beltColor,angle:MatchingCriterias.analogousAngle)
           hueCheckResultTopShoes = checkHUEsAnalogyInRGB(color1: topColor, color2: shoesColor,angle:MatchingCriterias.analogousAngle)
           hueCheckResultBottomBelt = checkHUEsAnalogyInRGB(color1: bottomColor, color2: beltColor,angle:MatchingCriterias.analogousAngle)
           hueCheckResultBottomShoes = checkHUEsAnalogyInRGB(color1: bottomColor, color2: shoesColor,angle:MatchingCriterias.analogousAngle)
           if (hueCheckResultClothes && hueCheckResultTopBelt && hueCheckResultTopShoes && hueCheckResultBottomBelt && hueCheckResultBottomShoes) == true{
            return NSLocalizedString("MatchColors_Match", comment: "")
           }
           else{
            return NSLocalizedString("MatchColors_NoMatch", comment: "")
           }
        case .triadic:
            var triadicCheckResultClothes:Bool = false
            var triadicCheckResultTopBelt:Bool = false
            var triadicCheckResultTopShoes:Bool = false
            var triadicCheckResultBottomBelt:Bool = false
            var triadicCheckResultBottomShoes:Bool = false
            triadicCheckResultClothes = checkHUEsTriadicInRGB(color1: topColor, color2: bottomColor)
            triadicCheckResultTopBelt = checkHUEsTriadicInRGB(color1: topColor, color2: beltColor)
            triadicCheckResultTopShoes = checkHUEsTriadicInRGB(color1: topColor, color2: shoesColor)
            triadicCheckResultBottomBelt = checkHUEsTriadicInRGB(color1: bottomColor, color2: beltColor)
            triadicCheckResultBottomShoes = checkHUEsTriadicInRGB(color1: bottomColor, color2: shoesColor)
            if (triadicCheckResultClothes && triadicCheckResultTopBelt && triadicCheckResultTopShoes && triadicCheckResultBottomBelt && triadicCheckResultBottomShoes) == true {
                return NSLocalizedString("MatchColors_Match", comment: "")
            }
            else{
                return NSLocalizedString("MatchColors_NoMatch", comment: "")
            }
        case .skinWithClothesRGB:
            return "lah"
        default:
            return "Don't know"
        }
    }
    func matchTopBottom(topColor:UIColor, bottomColor:UIColor)->String{
        switch chosenAlgorithm {
        case .complementaryColorRGB:
            let hueCheckResult = checkHUEsComplementarityInRGB(color1: topColor, color2: bottomColor)
            var hueResultComplementary:String = ""
            if hueCheckResult < MatchingCriterias.complementaryColorDegrees {
                hueResultComplementary = NSLocalizedString("MatchColors_Match", comment: "")
            }
            else{
                let topColorHSBA = topColor.hsba()
                let bottomColorHSBA = bottomColor.hsba()
                if topColorHSBA.b < 0.1 || bottomColorHSBA.b < 0.1 {
                    hueResultComplementary = NSLocalizedString("MatchColors_Match", comment: "")
                }
                else if topColorHSBA.s < 0.1 && topColorHSBA.b > 0.9 || bottomColorHSBA.s < 0.1 && bottomColorHSBA.b > 0.9 {
                    hueResultComplementary = NSLocalizedString("MatchColors_Match", comment: "")
                }
                else{
                    hueResultComplementary = NSLocalizedString("MatchColors_NoMatch", comment: "")
                }
            }
            return hueResultComplementary
        case .monoChromatic:
            var hueCheckResultClothes:Bool = false
            hueCheckResultClothes = checkHUEsSimilarityInRGB(color1: topColor, color2: bottomColor)
            if (hueCheckResultClothes){
                return NSLocalizedString("MatchColors_Match", comment: "")
            }
            else{
                return NSLocalizedString("MatchColors_NoMatch", comment: "")
            }
        case .analoguosRGB:
            var hueCheckResultClothes:Bool = false
            hueCheckResultClothes = checkHUEsAnalogyInRGB(color1: topColor, color2: bottomColor,angle:MatchingCriterias.analogousAngle)
            if hueCheckResultClothes == true{
                return NSLocalizedString("MatchColors_Match", comment: "")
            }
            else{
                return NSLocalizedString("MatchColors_NoMatch", comment: "")
            }
        case .triadic:
            var triadicCHeckResult:Bool = false
            triadicCHeckResult = checkHUEsTriadicInRGB(color1: topColor, color2: bottomColor)
            if triadicCHeckResult == true{
                return NSLocalizedString("MatchColors_Match", comment: "")
            }
            else{
                return NSLocalizedString("MatchColors_NoMatch", comment: "")
            }
        case .skinWithClothesRGB:
            return "lah"
        default:
            return "Don't know"
        }
    }
    func matchAccessories( beltColor:UIColor, shoesColor:UIColor)->String{
        let beltHSBA = beltColor.hsba()
        let shoesHSBA = shoesColor.hsba()
        let hueSimilarity = abs(beltHSBA.h * 360.0 - shoesHSBA.h * 360.0)
        let brightnessSimilarity = abs(beltHSBA.b - shoesHSBA.b)
        let saturationSimilarity = abs(beltHSBA.s - shoesHSBA.s)
        if hueSimilarity <= MatchingCriterias.hueSimilarityAccessories &&
            brightnessSimilarity < MatchingCriterias.brightnessSimilarityAccessories &&
            saturationSimilarity < 0.2 {
            return NSLocalizedString("MatchColors_Match", comment: "")
        }
        else{
            return NSLocalizedString("MatchColors_NoMatch", comment: "")
        }
    }
    func checkHUEsComplementarityInRGB(color1:UIColor, color2:UIColor) -> CGFloat{
        let complementaryColor = color1.complementaryColor()
        let complementaryColorHSBA = complementaryColor.hsba()
        let secondColorHSBA = color2.hsba()
        let hueSimilarity = abs(complementaryColorHSBA.h * 360.0 - secondColorHSBA.h * 360.0)  
        return hueSimilarity
    }
    func checkHUEsSimilarityInRGB(color1:UIColor, color2:UIColor) -> Bool{
        let color1HSBA = color1.hsba()
        let color2HSBA = color2.hsba()
        let hueSimilarity = abs(color1HSBA.h  - color2HSBA.h )
        if hueSimilarity <= MatchingCriterias.monoChromaticHueDifference {
            return true
        }
        if color2HSBA.s <= MatchingCriterias.minimumSaturation || color1HSBA.s <= MatchingCriterias.minimumSaturation{
            return true
        }else{
            return false
        }
    }
    func checkHUEsAnalogyInRGB(color1:UIColor, color2:UIColor, angle:CGFloat) -> Bool{
        let analogArray = color1.colorScheme(type: .Analagous)
        let colorMinus:UIColor = analogArray[3]
        let colorPlus:UIColor = analogArray[0]
        let colorMinusH = colorMinus.hsba().h
        let colorPlusH = colorPlus.hsba().h
        let color2HSBA = color2.hsba()
        let Color1HSBA = color1.hsba()
        if Color1HSBA.s <= MatchingCriterias.howAnalogousCriteria {
            return true
        }
        if colorMinusH < colorPlusH {
            if color2HSBA.h >= colorMinusH && color2HSBA.h <= colorPlusH{
                return true
            }
            else{
                if color2HSBA.s <= MatchingCriterias.howAnalogousCriteria {
                    return true
                }else{
                    return false
                }
            }
        }
        else{
            if color2HSBA.h >= (-1 + colorMinusH) && color2HSBA.h <= colorPlusH{
                return true
            }
            else{
                if color2HSBA.s <= MatchingCriterias.howAnalogousCriteria {
                    return true
                }
                else{
                    return false
                }
            }
        }
    }
    func checkHUEsTriadicInRGB(color1:UIColor, color2:UIColor) -> Bool{
        let color1HSBA = color1.hsba()
        if color1HSBA.s >= 0.01 && color1HSBA.b >= 0.01 {
            let triadicArray = color1.colorScheme(type: .Triad)
            let triadColor1 = triadicArray[1]
            let triadColor2 = triadicArray[2]
            let check21 = self.checkHUEsAnalogyInRGB(color1: color2, color2: triadColor1, angle: MatchingCriterias.triadicAngle)
            let check22 = self.checkHUEsAnalogyInRGB(color1: color2, color2: triadColor2, angle: MatchingCriterias.triadicAngle)
            if check21 || check22 {
                return true
            }
            else
            {
                return false
            }
        }
        return true
    }
    func getAnalogousColors(color1:UIColor, angle:CGFloat) -> [UIColor]{
        var colorMinusAngle:UIColor = UIColor()
        var colorPlusAngle:UIColor = UIColor()
        let color1H = color1.hsba().h
        var colorMinusH:CGFloat = 0
        if color1H - angle > 0 {
           colorMinusH = color1H - angle
        }
        else{
            colorMinusH = 1 + ( color1H - angle )
        }
        var colorPlusH:CGFloat = 0
        if color1H + angle < 1 {
            colorPlusH = color1H + angle
        }
        else{
            colorPlusH = 1 - (color1H + angle)
        }
        print(color1H,colorMinusH,colorPlusH)
        colorMinusAngle = UIColor(hsba: (h: colorMinusH, s: color1.hsba().s, b: color1.hsba().b, a: color1.hsba().a))
        colorPlusAngle = UIColor(hsba: (h: colorPlusH, s: color1.hsba().s, b: color1.hsba().b, a: color1.hsba().a))
        return [colorMinusAngle,colorPlusAngle]
    }
    func rybColor(red:CGFloat, yellow:CGFloat, blue:CGFloat, alpha: CGFloat)->UIColor{
        var r = red
        var y = yellow
        var b = blue
        let w = min(r, min(y, b))
        r -= w
        y -= w
        b -= w
        let my = max(r, max(y, b))
        var g = min(y, b)
        y -= g
        b -= g
        if (b != 0 && g != 0) {
            b *= 2.0
            g *= 2.0
        }
        r += y
        g += y
        let mg = max(r, max(g, b))
        if mg != 0 {
            let n = my / mg
            r *= n
            g *= n
            b *= n
        }
        r += w
        g += w
        b += w
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
}
