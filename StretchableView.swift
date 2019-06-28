import UIKit
final class CurrentStretchViewClothes {
    private init() {}
    static let sharedInstance: CurrentStretchViewClothes = CurrentStretchViewClothes()
    var top:NSArray = NSArray()
    var belt:NSArray = NSArray()
    var bottom:NSArray = NSArray()
    var shoes:NSArray = NSArray()
}
class StretchableView: UIImageView {
    struct Constants {
        static let boundaryHeightMax = 350
        static let boundaryWidthMax = 350
        static let boundaryHeightMin = 15
        static let boundaryWidthMin = 150
    }
    private struct stretchImagesProportionsWomen {
        let topProportion:CGFloat = 0.390
        let beltProportion:CGFloat = 0.03
        let bottomProportion:CGFloat = 0.600
        let bottomShiftUp:CGFloat = 0.06
        let shoesProportion:CGFloat = 0.070
    }
    private struct stretchImagesProportionsMen {
        let topProportion:CGFloat = 0.430
        let beltProportion:CGFloat = 0.030
        let bottomProportion:CGFloat = 0.560
        let bottomShiftUp:CGFloat = 0.0
        let shoesProportion:CGFloat = 0.070
    }
    enum Axis {
        case X
        case Y
    }
    private var didSetupConstraints = false
    private var lastTouchedPositionPinchOut = CGPoint(x: 0, y: 0)
    private var colorize:Colorize = Colorize()
    public var centerPoint:CGPoint = CGPoint.zero
    public var siblingView:UIImageView? = UIImageView()
    public var backgroundView:UIImageView = UIImageView()
    public var boundariesMax:CGRect = CGRect(origin: CGPoint.zero, size: CGSize(width: Constants.boundaryWidthMax, height: Constants.boundaryHeightMax))
    public var boundariesMin:CGRect = CGRect(origin: CGPoint.zero, size: CGSize(width: Constants.boundaryWidthMin, height: Constants.boundaryHeightMin))
    public var clothes:[Cloth] = [Cloth]()
    public var skinColor:UIColor = UIColor(red: 229/255.0, green: 194/255.0, blue: 152/255.0, alpha: 1.0)
    public func initWithClothes(clothes:[Cloth]) {
        self.clothes = clothes
        initBackgroundView()
        initSiblingView()
    }
    public func setImageViewColor(cloth:Cloth, color:UIColor){
        cloth.color = color
        cloth.imageView.image = cloth.image
        cloth.imageView.image = cloth.imageView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        cloth.imageView.image = colorize.processPixels(in: cloth.imageView.image!, color: color)
    }
    public func setStoredSetColorsToCurrentClothes(storedColors:[UIColor]){
        clothes[0].color = storedColors[0]
        clothes[1].color = storedColors[1]
        clothes[2].color = storedColors[2]
        clothes[3].color = storedColors[3]
        initSiblingView()
    }
    public func changeGenderClothes(clothes:[Cloth]) {
        self.clothes = clothes
        initSiblingView()
    }
    override func updateConstraints() {
        super.updateConstraints()
    }
    func saveCurrentUsedClothes(){
        let storageManager = StorageManager()
        storageManager.storeCurrentClothesSet(clothesArray: clothes)
    }
    func restoreCurrentUsedClothes() -> Bool{
        let storageManager = StorageManager()
        let clothesSet = storageManager.getCurrentClothingSet()
        if clothesSet.count > 0 {
            self.clothes = clothesSet
            self.initSiblingView()
            return true
        }
        else{
            return false
        }
    }
    func initSiblingView(){
        for subview in self.subviews {
            if subview.tag != -1{
                subview.removeFromSuperview()
            }
        }
        var tag = 0
        var oldCloth = Cloth()
        for cloth in clothes {    
            let currentGender = UserDefaults.standard.string(forKey: "MulticolorFitting.currentGender")
            if currentGender == "M" {
                let menClass = ClothesMen()
                let menArray:[clothPiece] = menClass.getMenClothesFromStruct()
                for menCloth in menArray{
                    if menCloth.cloth == cloth.name{
                        switch tag {
                        case 0://top
                            CurrentStretchViewClothes.sharedInstance.top = menCloth.designer
                            break
                        case 1://shoes
                            CurrentStretchViewClothes.sharedInstance.shoes = menCloth.designer
                            break
                        case 2://pants
                            CurrentStretchViewClothes.sharedInstance.bottom = menCloth.designer
                            break
                        case 3://belt
                            CurrentStretchViewClothes.sharedInstance.belt = menCloth.designer
                            break
                        default:
                            break
                        }
                    }
                }
            }else{
                let womenClass = ClothesWomen()
                let womenArray:[clothPiece] = womenClass.getWomenClothesFromStruct()
                for womenCloth in womenArray{
                    if womenCloth.cloth == cloth.name{
                        switch tag {
                        case 0://top
                            CurrentStretchViewClothes.sharedInstance.top = womenCloth.designer
                            break
                        case 1://shoes
                            CurrentStretchViewClothes.sharedInstance.shoes = womenCloth.designer
                            break
                        case 2://pants
                            CurrentStretchViewClothes.sharedInstance.bottom = womenCloth.designer
                            break
                        case 3://belt
                            CurrentStretchViewClothes.sharedInstance.belt = womenCloth.designer
                            break
                        default:
                            break
                        }
                    }
                }
            }
            cloth.imageView.tag = tag
            cloth.imageView.isUserInteractionEnabled = true
            let pinchOutGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchedOut(gestureRecognizer:)))
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapped(gestureRecognizer:)))
            tapGesture.numberOfTapsRequired = 1
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(gesture:)))
            swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
            cloth.imageView.addGestureRecognizer(swipeLeft)
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(gesture:)))
            swipeRight.direction = UISwipeGestureRecognizer.Direction.right
            cloth.imageView.addGestureRecognizer(swipeRight)
            let longTap = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(gestureRecognizer:)))
            longTap.minimumPressDuration = 1.0
            cloth.imageView.addGestureRecognizer(longTap)
            cloth.imageView.addGestureRecognizer(pinchOutGesture)
            cloth.imageView.addGestureRecognizer(tapGesture)
            cloth.imageView.clipsToBounds = true
            cloth.imageView.backgroundColor = UIColor.clear
            cloth.imageView.isMultipleTouchEnabled = true
            cloth.imageView.contentMode = UIView.ContentMode.scaleAspectFit
            cloth.imageView.image = cloth.image.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cloth.imageView.image = colorize.processPixels(in: (cloth.imageView.image)!,color:cloth.color)
            self.addSubview(cloth.imageView)
            self.bringSubviewToFront(cloth.imageView)
            self.translatesAutoresizingMaskIntoConstraints = false
            cloth.imageView.translatesAutoresizingMaskIntoConstraints = false
            oldCloth.imageView.translatesAutoresizingMaskIntoConstraints = false
            let proportionsMen = stretchImagesProportionsMen()
            let proportionsWomen = stretchImagesProportionsWomen()
            switch tag {
                case 0: 
                    if currentGender == "M"{
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: proportionsMen.topProportion, constant: 0))
                        oldCloth = cloth
                    }else{
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: proportionsWomen.topProportion, constant: 0))
                        oldCloth = cloth
                    }
                    break
                case 1: 
                    if currentGender == "M"{
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant:0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: proportionsMen.shoesProportion, constant: 0))
                    }else{
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant:0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: proportionsWomen.shoesProportion, constant: 0))
                    }
                    break
                case 2: 
                    if currentGender == "M"{
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .top, relatedBy: .equal, toItem: oldCloth.imageView, attribute: .bottom, multiplier: 1.0, constant: -(self.frame.height*0.061)))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: proportionsMen.bottomProportion, constant: 0))
                        oldCloth = cloth
                    }else{
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .top, relatedBy: .equal, toItem: oldCloth.imageView, attribute: .bottom, multiplier: 1.0, constant: -(self.frame.height*0.061)))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: proportionsWomen.bottomProportion, constant: 0))
                        oldCloth = cloth
                    }
                    break
                case 3: 
                    if currentGender == "M"{
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .top, relatedBy: .equal, toItem: oldCloth.imageView, attribute: .top, multiplier: 1.0, constant: 0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: proportionsMen.beltProportion, constant: 0))
                    }
                    else{
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .top, relatedBy: .equal, toItem: oldCloth.imageView, attribute: .top, multiplier: 1.0, constant: 0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
                        self.addConstraint(NSLayoutConstraint(item: cloth.imageView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: proportionsWomen.beltProportion, constant: 0))
                    }
                    break
                default:
                    break
            }
            tag = tag + 1
        }
    }
    func initBackgroundView(){
        self.isUserInteractionEnabled = true
        if self.backgroundView.tag != -1 {
            self.backgroundView.tag = -1
            self.backgroundView.isUserInteractionEnabled = true
            self.backgroundView.contentMode = .scaleAspectFit
            self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    public func initBackgroundView(imageName:String){
        self.isUserInteractionEnabled = true
        self.backgroundView.frame = self.frame
        self.backgroundView.transform = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: 1.0, tx: 0.0, ty: 0.0)
        self.backgroundView.image = UIImage(named:imageName)?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.backgroundView.image = colorize.processPixels(in: (self.backgroundView.image)!,color:self.skinColor)
        self.addSubview(self.backgroundView)
        self.sendSubviewToBack(self.backgroundView)
        self.addConstraint(NSLayoutConstraint(item: self.backgroundView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.backgroundView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.backgroundView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.backgroundView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.backgroundView.layoutIfNeeded()
    }
    public func changeBackgroundViewColor(color:UIColor, image:String){
        self.skinColor = color
        self.backgroundView.image = UIImage(named:image)?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.backgroundView.image = colorize.processPixels(in: (self.backgroundView.image)!,color:self.skinColor)
    }
    @objc func swiped(gesture:UISwipeGestureRecognizer){
        let clothesMen:ClothesMen = ClothesMen()
        let clothesWomen:ClothesWomen = ClothesWomen()
            switch gesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                    print("swiped right on view with tag \(gesture.view!.tag)")
                    let cloth = clothes[gesture.view!.tag]
                    let currentGender:String = UserDefaults.standard.string(forKey: "MulticolorFitting.currentGender")!
                    var list:[clothPiece] = [clothPiece]()
                    if currentGender == "M" {
                        list = clothesMen.getMenClothesFromStruct()
                    }
                    else{
                        list = clothesWomen.getWomenClothesFromStruct()
                    }
                    switch gesture.view!.tag {
                    case 0:
                        let filteredList = list.filter() {
                            let isTop = $0.drawingOrder == ClothDrawingOrder.top
                            return isTop
                        }
                        for index in 0...filteredList.count-1 {
                            if filteredList[index].drawingOrder == ClothDrawingOrder.top {
                                if cloth.name == filteredList[index].cloth {
                                    if (index + 1) <= (filteredList.count - 1) {
                                        cloth.name = filteredList[index+1].cloth
                                        cloth.image = UIImage(named: filteredList[index+1].cloth)!
                                        CurrentStretchViewClothes.sharedInstance.top = filteredList[index+1].designer
                                        self.setImageViewColor(cloth: cloth, color: cloth.color)
                                        break
                                    }
                                    else{
                                        cloth.name = filteredList[0].cloth
                                        cloth.image = UIImage(named: filteredList[0].cloth)!
                                        CurrentStretchViewClothes.sharedInstance.top = filteredList[0].designer
                                        self.setImageViewColor(cloth: cloth, color: cloth.color)
                                        break
                                    }
                                }
                            }
                        }
                        break
                    case 1:
                        let filteredList = list.filter() {
                            let isPants = $0.drawingOrder == ClothDrawingOrder.shoes
                            return isPants
                        }
                        for index in 0...filteredList.count-1 {
                            if filteredList[index].drawingOrder == ClothDrawingOrder.shoes {
                                if cloth.name == filteredList[index].cloth {
                                    if (index + 1) <= (filteredList.count - 1) {
                                        cloth.name = filteredList[index+1].cloth
                                        cloth.image = UIImage(named: filteredList[index+1].cloth)!
                                        CurrentStretchViewClothes.sharedInstance.shoes = filteredList[index+1].designer
                                        self.setImageViewColor(cloth: cloth, color: cloth.color)
                                        break
                                    }
                                    else{
                                        cloth.name = filteredList[0].cloth
                                        cloth.image = UIImage(named: filteredList[0].cloth)!
                                        CurrentStretchViewClothes.sharedInstance.shoes = filteredList[0].designer
                                        self.setImageViewColor(cloth: cloth, color: cloth.color)
                                        break
                                    }
                                }
                            }
                        }
                        break
                    case 2:
                        let filteredList = list.filter() {
                            let isPants = $0.drawingOrder == ClothDrawingOrder.pants
                            return isPants
                        }
                        for index in 0...filteredList.count-1 {
                            if filteredList[index].drawingOrder == ClothDrawingOrder.pants {
                                if cloth.name == filteredList[index].cloth {
                                    if (index + 1) <= (filteredList.count - 1) {
                                        cloth.name = filteredList[index+1].cloth
                                        cloth.image = UIImage(named: filteredList[index+1].cloth)!
                                        CurrentStretchViewClothes.sharedInstance.bottom = filteredList[index+1].designer
                                        self.setImageViewColor(cloth: cloth, color: cloth.color)
                                        break
                                    }
                                    else{
                                        cloth.name = filteredList[0].cloth
                                        cloth.image = UIImage(named: filteredList[0].cloth)!
                                        CurrentStretchViewClothes.sharedInstance.bottom = filteredList[0].designer
                                        self.setImageViewColor(cloth: cloth, color: cloth.color)
                                        break
                                    }
                                }
                            }
                        }
                        break
                    case 3:
                        let filteredList = list.filter() {
                            let isBelt = $0.drawingOrder == ClothDrawingOrder.belt
                            return isBelt
                        }
                        for index in 0...filteredList.count-1 {
                            if filteredList[index].drawingOrder == ClothDrawingOrder.belt {
                                if cloth.name == filteredList[index].cloth {
                                    if (index + 1) <= (filteredList.count - 1) {
                                        cloth.name = filteredList[index+1].cloth
                                        cloth.image = UIImage(named: filteredList[index+1].cloth)!
                                        CurrentStretchViewClothes.sharedInstance.belt = filteredList[index+1].designer
                                        self.setImageViewColor(cloth: cloth, color: cloth.color)
                                        break
                                    }
                                    else{
                                        cloth.name = filteredList[0].cloth
                                        cloth.image = UIImage(named: filteredList[0].cloth)!
                                        CurrentStretchViewClothes.sharedInstance.belt = filteredList[0].designer
                                        self.setImageViewColor(cloth: cloth, color: cloth.color)
                                        break
                                    }
                                }
                            }
                        }
                        break
                    default:
                        break
                    }
                break
            case UISwipeGestureRecognizer.Direction.down:
                break
            case UISwipeGestureRecognizer.Direction.left:
                    print("swiped left on view with tag \(gesture.view!.tag)")
                    let cloth = clothes[gesture.view!.tag]
                    let currentGender:String = UserDefaults.standard.string(forKey: "MulticolorFitting.currentGender")!
                    var list:[clothPiece] = [clothPiece]()
                    if currentGender == "M" {
                        list = clothesMen.getMenClothesFromStruct()
                    }
                    else{
                        list = clothesWomen.getWomenClothesFromStruct()
                    }
                    switch gesture.view!.tag {
                    case 0:
                        let filteredList = list.filter() {
                            let isTop = $0.drawingOrder == ClothDrawingOrder.top
                            return isTop
                        }
                        for index in 0...filteredList.count-1 {
                            if filteredList[index].drawingOrder == ClothDrawingOrder.top {
                                if cloth.name == filteredList[index].cloth {
                                    if (index - 1) >= 0 {
                                        cloth.name = filteredList[index-1].cloth
                                        cloth.image = UIImage(named: filteredList[index-1].cloth)!
                                        CurrentStretchViewClothes.sharedInstance.top = filteredList[index-1].designer
                                        self.setImageViewColor(cloth: cloth, color: cloth.color)
                                        break
                                    }
                                    else{
                                        cloth.name = filteredList[0].cloth
                                        cloth.image = UIImage(named: filteredList[0].cloth)!
                                        CurrentStretchViewClothes.sharedInstance.top = filteredList[0].designer
                                        self.setImageViewColor(cloth: cloth, color: cloth.color)
                                        break
                                    }
                                }
                            }
                        }
                        break
                    case 1:
                        let filteredList = list.filter() {
                            let isPants = $0.drawingOrder == ClothDrawingOrder.shoes
                            return isPants
                        }
                        for index in 0...filteredList.count-1 {
                            if filteredList[index].drawingOrder == ClothDrawingOrder.shoes {
                                if cloth.name == filteredList[index].cloth {
                                    if (index - 1) >= 0 {
                                        cloth.name = filteredList[index-1].cloth
                                        cloth.image = UIImage(named: filteredList[index-1].cloth)!
                                        CurrentStretchViewClothes.sharedInstance.shoes = filteredList[index-1].designer
                                        self.setImageViewColor(cloth: cloth, color: cloth.color)
                                        break
                                    }                                else{
                                        cloth.name = filteredList[0].cloth
                                        cloth.image = UIImage(named: filteredList[0].cloth)!
                                        CurrentStretchViewClothes.sharedInstance.shoes = filteredList[0].designer
                                        self.setImageViewColor(cloth: cloth, color: cloth.color)
                                        break
                                    }
                                }
                            }
                        }
                        break
                    case 2:
                        let filteredList = list.filter() {
                            let isPants = $0.drawingOrder == ClothDrawingOrder.pants
                            return isPants
                        }
                        for index in 0...filteredList.count-1 {
                            if filteredList[index].drawingOrder == ClothDrawingOrder.pants {
                                if cloth.name == filteredList[index].cloth {
                                    if (index - 1) >= 0 {
                                        cloth.name = filteredList[index-1].cloth
                                        cloth.image = UIImage(named: filteredList[index-1].cloth)!
                                        CurrentStretchViewClothes.sharedInstance.bottom = filteredList[index-1].designer
                                        self.setImageViewColor(cloth: cloth, color: cloth.color)
                                        break
                                    }
                                    else{
                                        cloth.name = filteredList[0].cloth
                                        cloth.image = UIImage(named: filteredList[0].cloth)!
                                        CurrentStretchViewClothes.sharedInstance.bottom = filteredList[0].designer
                                        self.setImageViewColor(cloth: cloth, color: cloth.color)
                                        break
                                    }
                                }
                            }
                        }
                        break
                    case 3:
                        let filteredList = list.filter() {
                            let isBelt = $0.drawingOrder == ClothDrawingOrder.belt
                            return isBelt
                        }
                        for index in 0...filteredList.count-1 {
                            if filteredList[index].drawingOrder == ClothDrawingOrder.pants {
                                if cloth.name == filteredList[index].cloth {
                                    if (index - 1) >= 0 {
                                        cloth.name = filteredList[index-1].cloth
                                        cloth.image = UIImage(named: filteredList[index-1].cloth)!
                                        CurrentStretchViewClothes.sharedInstance.belt = filteredList[index-1].designer
                                        self.setImageViewColor(cloth: cloth, color: cloth.color)
                                        break
                                    }
                                    else{
                                        cloth.name = filteredList[0].cloth
                                        cloth.image = UIImage(named: filteredList[0].cloth)!
                                        CurrentStretchViewClothes.sharedInstance.belt = filteredList[0].designer
                                        self.setImageViewColor(cloth: cloth, color: cloth.color)
                                        break
                                    }
                                }
                            }
                        }
                        break
                    default:
                        break
                    }
                break
            case UISwipeGestureRecognizer.Direction.up:
                break
            default:
                break
            }
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "Notification.updateDesignerView")))
    }
    @objc func longTap(gestureRecognizer:UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            var selectedCloth:Cloth = Cloth()
            for clothLocal in clothes{
                if clothLocal.imageView.tag == gestureRecognizer.view!.tag{
                    selectedCloth = clothLocal
                    let dataDict:[String: Cloth] = ["clothingElement": selectedCloth ]
                    NotificationCenter.default.post(Notification(name: NSNotification.Name(rawValue: "Notification.presentPicker"), object: nil, userInfo: dataDict))
                }
            }
       }
    }
    @objc func pinchedOut(gestureRecognizer:UIPinchGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizer.State.changed || gestureRecognizer.state == UIGestureRecognizer.State.began{
            if gestureRecognizer.numberOfTouches > 1 {
                let axis = axisFromPoints(p1: gestureRecognizer.location(ofTouch: 0, in: self), gestureRecognizer.location(ofTouch: 1, in: self))
                let checkBounds = checkBoundaries(frame1: (gestureRecognizer.view?.frame)!, boundariesMaxLocal: self.boundariesMax, boundariesMinLocal:self.boundariesMin, direction:gestureRecognizer.scale, axis:axis)
                if checkBounds {
                    if axis == Axis.X {
                        self.backgroundView.transform = (gestureRecognizer.view?.transform)!.scaledBy(x: gestureRecognizer.scale, y: 1)
                        print(self.backgroundView.transform)
                        self.clothes[0].imageView.transform = (gestureRecognizer.view?.transform)!.scaledBy(x: gestureRecognizer.scale, y: 1)
                        self.clothes[1].imageView.transform = (gestureRecognizer.view?.transform)!.scaledBy(x: gestureRecognizer.scale, y: 1)
                        self.clothes[2].imageView.transform = (gestureRecognizer.view?.transform)!.scaledBy(x: gestureRecognizer.scale, y: 1)
                        self.clothes[3].imageView.transform = (gestureRecognizer.view?.transform)!.scaledBy(x: gestureRecognizer.scale, y: 1)
                        gestureRecognizer.scale = 1;
                    }
                    else{
                        gestureRecognizer.scale = 1;
                    }
                }
                else{
                }
            }
        }
        else if gestureRecognizer.state == UIGestureRecognizer.State.ended{
            lastTouchedPositionPinchOut = CGPoint.zero
        }
    }
    @objc func doubleTapped(gestureRecognizer:UITapGestureRecognizer){
        var selectedCloth:Cloth = Cloth()
        for clothLocal in clothes{
            if clothLocal.imageView.tag == gestureRecognizer.view!.tag{
                let delta:CGFloat = 8.0
                UIView.animate(withDuration: 0.1, animations: {
                    gestureRecognizer.view!.frame = CGRect(x: gestureRecognizer.view!.frame.origin.x-delta/2, y: gestureRecognizer.view!.frame.origin.y-delta/2, width: gestureRecognizer.view!.frame.size.width+delta, height: gestureRecognizer.view!.frame.size.height+delta)
                }, completion: {
                    (value: Bool) in
                    UIView.animate(withDuration: 0.1, animations: {
                        gestureRecognizer.view!.frame = CGRect(x: gestureRecognizer.view!.frame.origin.x+delta/2, y: gestureRecognizer.view!.frame.origin.y+delta/2, width: gestureRecognizer.view!.frame.size.width-delta, height: gestureRecognizer.view!.frame.size.height-delta)
                    }, completion: {
                        (value: Bool) in
                        selectedCloth = clothLocal
                        let dataDict:[String: Cloth] = ["clothingElement": selectedCloth ]
                        NotificationCenter.default.post(Notification(name: NSNotification.Name(rawValue: "Notification.showBottomMenu"), object: nil, userInfo: dataDict))
                    })
                })
            }
        }
    }
    private func checkBoundaries(frame1:CGRect, boundariesMaxLocal:CGRect, boundariesMinLocal:CGRect, direction:CGFloat, axis:Axis) -> Bool{
        var heightCheck = false
        var widthCheck = false
        if direction < 1.0 && direction > 0 {
            if axis == Axis.X {
                if (boundariesMaxLocal.width - frame1.width) <= 0 {
                    widthCheck = true
                }
                else if(frame1.width - boundariesMinLocal.width) > 0 {
                    widthCheck = true
                }
                return widthCheck
            }
            if axis == Axis.Y {
                if (boundariesMaxLocal.height - frame1.height) <= 0 {
                    heightCheck = true
                }
                else if(frame1.height - boundariesMinLocal.height) > 0 {
                    heightCheck = true
                }
                return heightCheck
            }
        }
        if direction > 1.0 {
            if axis == Axis.X {
                if (frame1.width - boundariesMinLocal.width) <= 0 {
                    widthCheck = true
                }
                if(boundariesMaxLocal.width - frame1.width) >= 0 {
                    widthCheck = true
                }
                return widthCheck
            }
            if axis == Axis.Y {
                if (frame1.height - boundariesMinLocal.height) <= 0 {
                    heightCheck = true
                }
                if(boundariesMaxLocal.height - frame1.height) >= 0 {
                    heightCheck = true
                }
                return heightCheck
            }
        }
        return false
    }
    private func axisFromPoints(p1: CGPoint, _ p2: CGPoint) -> Axis {
        let absolutePoint = CGPoint(x: p2.x - p1.x, y: p2.y - p1.y)
        let radians = atan2(Double(absolutePoint.x), Double(absolutePoint.y))
        let absRad = fabs(radians)
        if absRad > M_PI_4 && absRad < 3*M_PI_4 {
            return .X
        } else {
            return .Y
        }
    }
}
extension UIImage {
    func tint(tintColor: UIColor) -> UIImage {
        return modifiedImage { context, rect in
            context.setBlendMode(.normal)
            UIColor.black.setFill()
            context.fill(rect)
            context.setBlendMode(.normal)
            context.draw(self.cgImage!, in: rect)
            context.setBlendMode(.color)
            tintColor.setFill()
            context.fill(rect)
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }
    func fillAlpha(fillColor: UIColor) -> UIImage {
        return modifiedImage { context, rect in
            context.setBlendMode(.normal)
            fillColor.setFill()
            context.fill(rect)
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }
    private func modifiedImage( draw: (CGContext, CGRect) -> ()) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        draw(context, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
