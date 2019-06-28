import Foundation
public struct MC {
    public static let MulticolorFittingRedColor =  #colorLiteral(red: 0.8509803922, green: 0.5647058824, blue: 0.5254901961, alpha: 1)
    public static let MulticolorFittingGreenColor = #colorLiteral(red: 0.5215686275, green: 0.8392156863, blue: 0.6588235294, alpha: 1)
}
public struct MatchingCriterias {
    public static let complementaryColorDegrees:CGFloat = 20.0
    public static let minimumSaturation:CGFloat = 0.02
    public static let monoChromaticHueDifference:CGFloat = 0.035
    public static let analogousAngle:CGFloat = 30.0
    public static let triadicAngle:CGFloat = 5.0
    public static let hueSimilarityAccessories:CGFloat = 2.0
    public static let brightnessSimilarityAccessories:CGFloat = 0.2
    public static let howAnalogousCriteria:CGFloat = 0.10
}
