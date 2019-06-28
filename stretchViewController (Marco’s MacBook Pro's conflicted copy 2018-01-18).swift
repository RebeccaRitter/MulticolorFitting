import UIKit
import CoreData
import GoogleMobileAds
import Mixpanel
import Instructions
import NKOColorPickerView
class stretchViewController: UIViewController, SwiftHUEColorPickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, CoachMarksControllerDataSource, CoachMarksControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, KACircleCropViewControllerDelegate, DTColorPickerImageViewDelegate, UITextFieldDelegate {
    private var modelHeight = 600
    private var modelWidth = 300
    private var colorPickerViewHeight:CGFloat = 134.0
    private var modelShiftAfterActionViewBecomesVisible:CGFloat = 45.0
    private var numberOfActiveAlgorithms:Int = 0
    private var selectedClothingElement:Cloth = Cloth()
    private var timer:Timer = Timer()
    private var match:MatchColors = MatchColors()
    private var storedSetsColors:[[UIColor]] = [[UIColor]]()
    private var cameraDetectionClothTag = -1
    @IBOutlet var stretchView: stretchableView!
    @IBOutlet weak var horizontalColorPicker: SwiftHUEColorPicker!
    @IBOutlet weak var horizontalSaturationPicker: SwiftHUEColorPicker!
    @IBOutlet weak var horizontalBrightnessPicker: SwiftHUEColorPicker!
    @IBOutlet var changeColorView: UIView!
    @IBOutlet var modelBottomConstraint: NSLayoutConstraint!
    @IBOutlet var sideMenuHeightConstraint: NSLayoutConstraint!
    @IBOutlet var colorPickerFineTuneConstraint: NSLayoutConstraint!
    @IBOutlet var clothColorLabel: UILabel!
    @IBOutlet var clothHueLabel: UILabel!
    @IBOutlet var colorPickerImageView: DTColorPickerImageView!
    @IBOutlet var colorPickerFineTuningOutlet: UIView!
    @IBOutlet var colorPickerFineTuningImageView: NKOColorPickerView!
    @IBOutlet var fineTunedColorView: UIView!
    @IBOutlet var ColorHEXTextField: UITextField!
    @IBOutlet var pencilImageView: UIImageView!
    @IBOutlet var designerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var leftMenuHeightConstraint: NSLayoutConstraint!
    @IBOutlet var mainSideMenu: UIStackView!
    @IBOutlet var loveButtonOutlet: UIButton!
    @IBOutlet var shareButtonOutlet: UIButton!
    @IBOutlet var matcheeButtonOutlet: UIButton!
    @IBOutlet var colorPickerOutlet: UIButton!
    @IBOutlet var actionView: UIView!
    @IBOutlet var changeToManButton: UIButton!
    @IBOutlet var changeToWomanButton: UIButton!
    @IBOutlet var changeSkinColorButton: UIButton!
    @IBOutlet var globalMatchLabel: UILabel!
    @IBOutlet var tobBottomMatchLabel: UILabel!
    @IBOutlet var accessoriesMatchLabel: UILabel!
    @IBOutlet var changeSkinColorStackView: UIStackView!
    @IBOutlet var stylesCollectionView: UICollectionView!
    @IBOutlet var changeAlgorithmHint: UIView!
    @IBOutlet var changeAlgorithmArrow: UIImageView!
    @IBOutlet var topMatchIcons: UIImageView!
    @IBOutlet var accMatchIcons: UIImageView!
    @IBOutlet var allMatchIcons: UIImageView!
    @IBOutlet var leftSideMenuStackView: UIStackView!
    @IBOutlet var designerView: UIView!
    @IBOutlet var topDesignerLabel: UILabel!
    @IBOutlet var topVisitLabel: UILabel!
    @IBOutlet var topClothDescriptionLabel: UILabel!
    @IBOutlet var beltDesignerLabel: UILabel!
    @IBOutlet var beltVisitLabel: UILabel!
    @IBOutlet var beltClothDescriptionLabel: UILabel!
    @IBOutlet var bottomDesignerLabel: UILabel!
    @IBOutlet var bottomVisitLabel: UILabel!
    @IBOutlet var bottomClothDescriptionLabel: UILabel!
    @IBOutlet var shoesDesignerLabel: UILabel!
    @IBOutlet var shoesVisitLabel: UILabel!
    @IBOutlet var shoesClothDescriptionLabel: UILabel!
    @IBOutlet var bannerView: GADBannerView!
    @IBOutlet var scoresAndStylesView: UIView!
    let coachMarksController = CoachMarksController()
    var picker = UIImagePickerController()
    override var prefersStatusBarHidden: Bool {
        return true
    }
    var menClothesArray = [clothPiece]()
    var womenClothesArray = [clothPiece]()
    override func viewDidLoad() {
        super.viewDidLoad()
        addGestureRecognizers()
        addNotifications()
        let storageManager = Storage()
        storageManager.initClothesStorage()
        horizontalColorPicker.delegate = self
        horizontalColorPicker.direction = SwiftHUEColorPicker.PickerDirection.horizontal
        horizontalColorPicker.type = SwiftHUEColorPicker.PickerType.color
        horizontalColorPicker.currentColor = UIColor(hsba: (h: 180.0, s: 0.3, b: 0.3, a: 1.0))
        horizontalSaturationPicker.delegate = self
        horizontalSaturationPicker.direction = SwiftHUEColorPicker.PickerDirection.horizontal
        horizontalSaturationPicker.type = SwiftHUEColorPicker.PickerType.saturation
        horizontalSaturationPicker.currentColor = UIColor(hsba: (h: 180.0, s: 0.3, b: 0.3, a: 1.0))
        horizontalBrightnessPicker.delegate = self
        horizontalBrightnessPicker.direction = SwiftHUEColorPicker.PickerDirection.horizontal
        horizontalBrightnessPicker.type = SwiftHUEColorPicker.PickerType.brightness
        horizontalBrightnessPicker.currentColor = UIColor(hsba: (h: 180.0, s: 0.3, b: 0.3, a: 1.0))
        changeColorView.isHidden = true
        stylesCollectionView.delegate = self
        stylesCollectionView.dataSource = self
        stylesCollectionView.register(UINib(nibName:"StyleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StyleCell")
        let currentGender:String = UserDefaults.standard.string(forKey: "Matchee.currentGender")!
        if currentGender == "M"{
            self.changeToManButtonAction(UIButton())
        }
        else{
            self.changeToWomanButtonAction(UIButton())
        }
        self.colorPickerOutlet.layer.cornerRadius = 27.0
        self.colorPickerOutlet.clipsToBounds = true
        self.changeSkinColorStackView.layer.cornerRadius = 15.0
        self.changeSkinColorStackView.clipsToBounds = true
        self.changeSkinColorButton.layer.cornerRadius = 15.0
        self.changeSkinColorButton.clipsToBounds = true
        shareButtonOutlet.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        matcheeButtonOutlet.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        self.match.chosenAlgorithm = .complementaryColorRGB
        self.bannerView.adUnitID = "ca-app-pub-5472617503248286/1125241657"
        self.bannerView.rootViewController = self
        self.bannerView.load(GADRequest())
        self.ColorHEXTextField.delegate = self
        self.coachMarksController.dataSource = self
        self.coachMarksController.overlay.color = UIColor(red: 80/255.0, green: 80/255.0, blue: 80/255.0, alpha: 0.85)
        self.coachMarksController.overlay.allowTap = true
        self.picker.delegate = self
        self.colorPickerImageView.delegate = self
        self.colorPickerFineTuningOutlet.isHidden = true
        self.colorPickerFineTuneConstraint.constant = self.colorPickerFineTuneConstraint.constant + self.view.frame.height
        self.designerLeadingConstraint.constant = self.designerLeadingConstraint.constant - self.designerView.frame.size.width
        let colorDidChangeBlock: NKOColorPickerDidChangeColorBlock = { (color) in
            self.fineTunedColorView.backgroundColor = color!
            self.ColorHEXTextField.text = color!.hexString
            let b = color!.hsba().b
            if b < 0.6{
                self.ColorHEXTextField.textColor = UIColor.white
                self.pencilImageView.image = UIImage(named: "pencil_white")
            }
            else{
                self.ColorHEXTextField.textColor = UIColor.darkGray
                self.pencilImageView.image = UIImage(named: "pencil_black")
            }
        }
        self.colorPickerFineTuningImageView.didChangeColorBlock = colorDidChangeBlock
        var clothStructMen = ClothesMen()
        var clothStructWomen = ClothesWomen()
        self.menClothesArray = clothStructMen.getMenClothesFromStruct()
        self.womenClothesArray = clothStructWomen.getWomenClothesFromStruct()
        Judex.shared.daysUntilPrompt = 10
        Judex.shared.remindPeriod = -1
        Judex.shared.promptIfRequired()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UserDefaults.standard.bool(forKey: "Matchee.isFirstLaunch"){
            UserDefaults.standard.set(1, forKey: "Matchee.complementaryCheck")
            UserDefaults.standard.synchronize()
            UserDefaults.standard.set(1, forKey: "Matchee.monochromaticCheck")
            UserDefaults.standard.synchronize()
            UserDefaults.standard.set(true, forKey: "Matchee.isFirstLaunch")
            UserDefaults.standard.synchronize()
            self.coachMarksController.startOn(self) 
        }
    }
    func imageView(_ imageView: DTColorPickerImageView, didPickColorWith color: UIColor) {
        let colorString:String = color.hexString
        self.clothColorLabel.text = self.selectedClothingElement.name + " HUE "
        self.clothHueLabel.text = "Hex color code = " + colorString
        self.stretchView.setImageViewColor(cloth: self.selectedClothingElement, color: color)
        self.colorMatching()
    }
    func valuePicked(_ color: UIColor, type: SwiftHUEColorPicker.PickerType) {
        switch type {
        case SwiftHUEColorPicker.PickerType.color:
            horizontalColorPicker.currentColor = color
            horizontalSaturationPicker.currentColor = color
            horizontalBrightnessPicker.currentColor = color
            break
        case SwiftHUEColorPicker.PickerType.saturation:
            horizontalColorPicker.currentColor = color
            horizontalSaturationPicker.currentColor = color
            horizontalBrightnessPicker.currentColor = color
            break
        case SwiftHUEColorPicker.PickerType.brightness:
            horizontalColorPicker.currentColor = color
            horizontalSaturationPicker.currentColor = color
            horizontalBrightnessPicker.currentColor = color
            break
        default:
            break
        }
        let colorString:String = color.hexString
        self.clothColorLabel.text = self.selectedClothingElement.name + " HUE "
        self.clothHueLabel.text = "Hex color code = " + colorString
        self.stretchView.setImageViewColor(cloth: self.selectedClothingElement, color: color)
        self.colorMatching()
    }
    func saveCurrentUsedClothes(){
        stretchView.saveCurrentUsedClothes()
    }
    func addNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(showHideBottomMenuFromTap(_:)), name: NSNotification.Name(rawValue: "Notification.showBottomMenu"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveCurrentUsedClothes), name: NSNotification.Name(rawValue: "Notification.saveCurrentUsedClothes"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(colorMatching), name: NSNotification.Name(rawValue: "Notification.colorMatching"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentCameraPicker(_:)), name: NSNotification.Name(rawValue: "Notification.presentPicker"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeClothColorFromDetection(_:)), name: NSNotification.Name(rawValue: "Notification.changeClothColorFromDetection"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDesignerView), name: NSNotification.Name(rawValue: "Notification.updateDesignerView"), object: nil)
    }
    func addGestureRecognizers(){
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.actionView.addGestureRecognizer(swipeRight)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.designerView.addGestureRecognizer(swipeLeft)
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)
    }
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
              self.showHideActionView()
                break
            case UISwipeGestureRecognizerDirection.down:
                break
            case UISwipeGestureRecognizerDirection.left:
                self.hideDesignerView()
                break
            case UISwipeGestureRecognizerDirection.up:
                break
            default:
                break
            }
        }
    }
    @IBAction func matcheeButtonAction(_ sender: UIButton) {
        var constraintToChange:NSLayoutConstraint? = nil
        var constraintCenterToChange:NSLayoutConstraint? = nil
        var constraintTopToChange:NSLayoutConstraint? = nil
        if self.designerLeadingConstraint.constant == 0 {
            self.designerView.isHidden = true
            self.designerLeadingConstraint.constant = self.designerLeadingConstraint.constant - self.designerView.frame.size.width
        }
        for constraint in self.view.constraints{
            if let id = constraint.identifier {
                if id == "menuHeightConstraint" {
                    constraintToChange = constraint
                }
                else if id  == "stretchViewCenterX" {
                    constraintCenterToChange = constraint
                }
                else if id == "fromTopToStretchVIewConstraint" {
                    constraintTopToChange =  constraint
                }
            }
        }
        if let constChange = constraintToChange {
            self.view.removeConstraint(constChange)
            UIView.animate(withDuration: 0.3, animations: {
                let newConstraint:NSLayoutConstraint = NSLayoutConstraint(item: self.mainSideMenu, attribute: .height, relatedBy: .equal, toItem: self.stretchView, attribute: .height, multiplier: 0.08, constant: 0)
                newConstraint.identifier = "newMenuHeightConstraint"
                self.view.addConstraint(newConstraint)
                self.mainSideMenu.axis = UILayoutConstraintAxis.horizontal
                self.mainSideMenu.spacing = 0.0
                self.mainSideMenu.layoutIfNeeded()
                self.stretchView.center = CGPoint(x: self.stretchView.center.x - self.modelShiftAfterActionViewBecomesVisible, y: self.stretchView.center.y)
                self.view.removeConstraint(constraintCenterToChange!)
                if self.modelBottomConstraint.constant < 9.0 {
                    self.modelBottomConstraint.constant = self.modelBottomConstraint.constant + self.colorPickerViewHeight + 8
                }
                let newConstraint1:NSLayoutConstraint = NSLayoutConstraint(item: self.stretchView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0)
                newConstraint1.identifier = "stretchToViewLeadingConstraint"
                self.view.addConstraint(newConstraint1)
                let newConstraint2:NSLayoutConstraint = NSLayoutConstraint(item: self.stretchView, attribute: .trailing, relatedBy: .equal, toItem: self.actionView, attribute: .leading, multiplier: 1.0, constant: 0)
                newConstraint2.identifier = "stretchToViewTrailingConstraint"
                self.view.addConstraint(newConstraint2)
                let newConstraint3:NSLayoutConstraint = NSLayoutConstraint(item: self.stretchView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.view.frame.size.width-self.actionView.frame.size.width)
                newConstraint3.identifier = "stretchViewWidthConstraint"
                self.view.addConstraint(newConstraint3)
                self.stretchView.layoutIfNeeded()
            }, completion: { (true) in
                self.showHideActionView()
                self.stretchView.initSiblingView()
            })
        }
        else {
            self.showHideActionView()
        }
    }
    @IBAction func shareButtonAction(_ sender: UIButton) {
        let mixpanel = Mixpanel.sharedInstance()
        var properties = [String: String]()
        properties = ["Share": ""]
        mixpanel!.track("Button_Share", properties: properties)
        let myWebsite = NSURL(string:"https://itunes.apple.com/app/matchee-clothes-matching/id1203742334?mt=8")
        let img: UIImage = UIImage(named: "logo")!
        guard let url = myWebsite else {
            print("nothing found")
            return
        }
        let shareItems:Array = [(img),url]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
        self.present(activityViewController, animated: true, completion: nil)
    }
    @IBAction func changeAlgorithmButtonAction(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "Matchee.HasChangedAlgorithm")
        UserDefaults.standard.synchronize()
        let mixpanel = Mixpanel.sharedInstance()
        var properties = [String: String]()
        properties = ["Algorithm": ""]
        mixpanel!.track("Main_ClickOnChangeAlgorithm", properties: properties)
    }
    let settingsView:UIView = UIView()
    func showHideActionView(){
        if self.actionView.isHidden {
            self.leftSideMenuStackView.isHidden = false
            var constraintToChange:NSLayoutConstraint? = nil
            var constraintToChangeWidth:NSLayoutConstraint? = nil
            for constraint in self.view.constraints{ 
                if let id = constraint.identifier {
                    if id == "leftMenuHeightConstraint" {
                        constraintToChange = constraint
                    }
                }
            }
            self.view.removeConstraint(constraintToChange!)
            UIView.animate(withDuration: 0.3, animations: {
                let newConstraint:NSLayoutConstraint = NSLayoutConstraint(item: self.leftSideMenuStackView, attribute: .height, relatedBy: .equal, toItem: self.stretchView, attribute: .height, multiplier: 0.08, constant: 0 )
                newConstraint.identifier = "newleftMenuHeightConstraint"
                self.view.addConstraint(newConstraint)
                self.leftSideMenuStackView.axis = UILayoutConstraintAxis.horizontal
                let firstView = self.leftSideMenuStackView.arrangedSubviews[0]
                firstView.isHidden = true
                self.leftSideMenuStackView.layoutIfNeeded()
            })
            self.actionView.frame = CGRect(x: self.actionView.frame.origin.x + self.actionView.frame.size.width, y: self.actionView.frame.origin.y, width: self.actionView.frame.size.width, height: self.actionView.frame.size.height)
            self.actionView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.actionView.frame = CGRect(x: self.actionView.frame.origin.x - self.actionView.frame.size.width, y: self.actionView.frame.origin.y, width: self.actionView.frame.size.width, height: self.actionView.frame.size.height)
                self.actionView.layoutIfNeeded()
            }, completion: { (true) in
                self.colorMatching()
            })
        }
        else{
            var constraintToChange:NSLayoutConstraint? = nil
            for constraint in self.view.constraints{ 
                if let id = constraint.identifier {
                    if id == "newleftMenuHeightConstraint" {
                        constraintToChange = constraint
                    }
                }
            }
            self.view.removeConstraint(constraintToChange!)
            UIView.animate(withDuration: 0.3, animations: {
                let newConstraint:NSLayoutConstraint = NSLayoutConstraint(item: self.leftSideMenuStackView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.30, constant: 0 )
                newConstraint.identifier = "leftMenuHeightConstraint"
                self.view.addConstraint(newConstraint)
                self.leftSideMenuStackView.axis = UILayoutConstraintAxis.vertical
                let firstView = self.leftSideMenuStackView.arrangedSubviews[0]
                firstView.isHidden = false
                self.leftSideMenuStackView.layoutIfNeeded()
            })
            UIView.animate(withDuration: 0.3, animations: {
                print(self.actionView.frame.origin.x)
                self.actionView.frame = CGRect(x: self.actionView.frame.origin.x + self.actionView.frame.size.width, y: self.actionView.frame.origin.y, width: self.actionView.frame.size.width, height: self.actionView.frame.size.height)
                self.actionView.layoutIfNeeded()
            }, completion: { (true) in
                self.actionView.isHidden = true
                var constraintToChange:NSLayoutConstraint? = nil
                for constraint in self.view.constraints{
                    if let id = constraint.identifier {
                        if id == "newMenuHeightConstraint" {
                            constraintToChange = constraint
                        }
                        else if id == "stretchToViewLeadingConstraint"{
                            self.view.removeConstraint(constraint)
                        }
                        else if id == "stretchToViewTrailingConstraint" {
                            self.view.removeConstraint(constraint)
                        }
                        else if id == "stretchViewWidthConstraint" {
                            self.view.removeConstraint(constraint)
                        }
                    }
                }
                if let constChange = constraintToChange {
                    self.view.removeConstraint(constChange)
                    UIView.animate(withDuration: 0.3, animations: {
                        let newConstraint:NSLayoutConstraint = NSLayoutConstraint(item: self.mainSideMenu, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.3, constant: 0 )
                        newConstraint.identifier = "menuHeightConstraint"
                        self.view.addConstraint(newConstraint)
                        self.mainSideMenu.axis = UILayoutConstraintAxis.vertical
                        self.mainSideMenu.spacing = 10.0
                        let newConstraint2:NSLayoutConstraint = NSLayoutConstraint(item: self.stretchView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 8)
                        newConstraint2.identifier = "fromTopToStretchVIewConstraint"
                        self.view.addConstraint(newConstraint2)
                        let newConstraint3:NSLayoutConstraint = NSLayoutConstraint(item: self.stretchView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0)
                        newConstraint3.identifier = "stretchViewCenterX"
                        self.view.addConstraint(newConstraint3)
                        self.mainSideMenu.layoutIfNeeded()
                    })
                }
            })
        }
    }
    func colorMatching(){
        let match:MatchColors = MatchColors()
        for cloth in self.stretchView.clothes{
            print(cloth.name)
        }
        var globalMatch:String = "No Match"
        var accessoriesMatch:String = "No Match"
        var topBottomMatch:String = "No Match"
        let algo3 = UserDefaults.standard.integer(forKey: "Matchee.analogousCheck")
        if algo3 == 1 {
            match.chosenAlgorithm = colorMatchingAlgorithms.analoguosRGB
            if globalMatch != NSLocalizedString("MatchColors_Match", comment: "") {
                globalMatch = match.matchGlobal(topColor: self.stretchView.clothes[0].color, beltColor: self.stretchView.clothes[3].color, bottomColor: self.stretchView.clothes[2].color, shoesColor: self.stretchView.clothes[1].color, skinColor:self.stretchView.skinColor)
            }
            if accessoriesMatch != NSLocalizedString("MatchColors_Match", comment: "") {
                accessoriesMatch = match.matchAccessories(beltColor: self.stretchView.clothes[3].color, shoesColor: self.stretchView.clothes[1].color)
            }
            if topBottomMatch != NSLocalizedString("MatchColors_Match", comment: "") {
                topBottomMatch = match.matchTopBottom(topColor:self.stretchView.clothes[0].color , bottomColor: self.stretchView.clothes[2].color)
            }
        }
        let algo1 = UserDefaults.standard.integer(forKey: "Matchee.complementaryCheck")
        if algo1 == 1 {
            match.chosenAlgorithm = colorMatchingAlgorithms.complementaryColorRGB
            if globalMatch != NSLocalizedString("MatchColors_Match", comment: "") {
                globalMatch = match.matchGlobal(topColor: self.stretchView.clothes[0].color, beltColor: self.stretchView.clothes[3].color, bottomColor: self.stretchView.clothes[2].color, shoesColor: self.stretchView.clothes[1].color, skinColor:self.stretchView.skinColor)
            }
            if accessoriesMatch != NSLocalizedString("MatchColors_Match", comment: "") {
                accessoriesMatch = self.match.matchAccessories(beltColor: self.stretchView.clothes[3].color, shoesColor: self.stretchView.clothes[1].color)
            }
            if topBottomMatch != NSLocalizedString("MatchColors_Match", comment: "") {
                topBottomMatch = self.match.matchTopBottom(topColor:self.stretchView.clothes[0].color , bottomColor: self.stretchView.clothes[2].color)
            }
        }
        let algo2 = UserDefaults.standard.integer(forKey: "Matchee.monochromaticCheck")
        if algo2 == 1 {
            match.chosenAlgorithm = colorMatchingAlgorithms.monoChromatic
            if globalMatch != NSLocalizedString("MatchColors_Match", comment: "") {
                globalMatch = match.matchGlobal(topColor: self.stretchView.clothes[0].color, beltColor: self.stretchView.clothes[3].color, bottomColor: self.stretchView.clothes[2].color, shoesColor: self.stretchView.clothes[1].color, skinColor:self.stretchView.skinColor)
            }
            if accessoriesMatch != NSLocalizedString("MatchColors_Match", comment: "") {
                accessoriesMatch = match.matchAccessories(beltColor: self.stretchView.clothes[3].color, shoesColor: self.stretchView.clothes[1].color)
            }
            if topBottomMatch != NSLocalizedString("MatchColors_Match", comment: "") {
                topBottomMatch = match.matchTopBottom(topColor:self.stretchView.clothes[0].color , bottomColor: self.stretchView.clothes[2].color)
            }
        }
        let algo4 = UserDefaults.standard.integer(forKey: "Matchee.splitComplementaryCheck")
        if algo4 == 1 {
            match.chosenAlgorithm = colorMatchingAlgorithms.triadic
            if globalMatch != NSLocalizedString("MatchColors_Match", comment: "") {
                globalMatch = match.matchGlobal(topColor: self.stretchView.clothes[0].color, beltColor: self.stretchView.clothes[3].color, bottomColor: self.stretchView.clothes[2].color, shoesColor: self.stretchView.clothes[1].color, skinColor:self.stretchView.skinColor)
            }
            if accessoriesMatch != NSLocalizedString("MatchColors_Match", comment: "") {
                accessoriesMatch = match.matchAccessories(beltColor: self.stretchView.clothes[3].color, shoesColor: self.stretchView.clothes[1].color)
            }
            if topBottomMatch != NSLocalizedString("MatchColors_Match", comment: "") {
                topBottomMatch = match.matchTopBottom(topColor:self.stretchView.clothes[0].color , bottomColor: self.stretchView.clothes[2].color)
            }
        }
        self.updateScores(GlobalMatch:globalMatch, TopBottomMatch:topBottomMatch,  AccessoriesMatch: accessoriesMatch)
    }
    func showHideBottomMenuFromTap(_ notification: NSNotification?){
        let mixpanel = Mixpanel.sharedInstance()
        var properties = [String: String]()
        if let clothingElement = notification?.userInfo?["clothingElement"] as? Cloth {
            let colorString:String = clothingElement.color.hexString
            self.selectedClothingElement = clothingElement
            self.clothColorLabel.text = self.selectedClothingElement.name + " HUE "
            self.clothHueLabel.text = "Hex color code = " + colorString
            horizontalColorPicker.currentColor = clothingElement.color
            horizontalSaturationPicker.currentColor = clothingElement.color
            horizontalBrightnessPicker.currentColor = clothingElement.color
            properties = ["SelectedCloth": clothingElement.name]
            mixpanel!.track("Main_ClickOnClothes", properties: properties)
        }
        else{
        }
        if changeColorView.isHidden == true{
            changeColorView.isHidden = false
            changeColorView.alpha = 0
            self.changeColorView.frame = CGRect(x: self.changeColorView.frame.origin.x, y: UIScreen.main.bounds.height, width: self.changeColorView.frame.size.width, height: self.colorPickerViewHeight)
            UIView.animate(withDuration: 0.2, animations: {
                self.changeColorView.frame = CGRect(x: self.changeColorView.frame.origin.x, y: UIScreen.main.bounds.height - self.colorPickerViewHeight, width: self.changeColorView.frame.size.width, height: self.colorPickerViewHeight)
                if self.modelBottomConstraint.constant < 9{
                    self.modelBottomConstraint.constant = self.modelBottomConstraint.constant + self.colorPickerViewHeight + 8
                }
                self.view.layoutIfNeeded()
                self.changeColorView.alpha = 1.0
            }, completion: { (value:Bool) in
                self.stretchView.initSiblingView()
            })
        }
    }
    @IBAction func changeToManButtonAction(_ sender: UIButton) {
        UserDefaults.standard.setValue("M", forKey: "Matchee.currentGender")
        UserDefaults.standard.synchronize()
        self.changeToManButton.setBackgroundImage(UIImage(named:"buttonGenderSelected"), for: UIControlState.normal)
        self.changeToWomanButton.setBackgroundImage(UIImage(named:"buttonGenderNotSelected"), for: UIControlState.normal)
        let storageManager = Storage()
        let clothInstance:Cloth = Cloth()
        var clothes:[Cloth] = [Cloth]()
        let currentSet:[Clothes]? = storageManager.getCurrentClothingSet(gender: 0)
        if let currentClothesSet = currentSet {
            clothes = clothInstance.getClothesObjectsForUI(clothesFromStorage: currentClothesSet)
            stretchView.initWithClothes(clothes: clothes)
        }
        else{
            let success = stretchView.restoreCurrentUsedClothes()
            if success {
            }
            else{
                clothes = clothInstance.getStandardClothesSetForUI()
                stretchView.initWithClothes(clothes: clothes)
            }
        }
        self.stretchView.initBackgroundView()
        self.stretchView.initBackgroundView(imageName: "m-model")
    }
    @IBAction func changeToWomanButtonAction(_ sender: UIButton) {
        UserDefaults.standard.setValue("W", forKey: "Matchee.currentGender")
        UserDefaults.standard.synchronize()
        self.changeToManButton.setBackgroundImage(UIImage(named:"buttonGenderNotSelected"), for: UIControlState.normal)
        self.changeToWomanButton.setBackgroundImage(UIImage(named:"buttonGenderSelected"), for: UIControlState.normal)
        let storageManager = Storage()
        let clothInstance:Cloth = Cloth()
        var clothes:[Cloth] = [Cloth]()
        let currentSet:[Clothes]? = storageManager.getCurrentClothingSet(gender: 1)
        if let currentClothesSet = currentSet {
            clothes = clothInstance.getClothesObjectsForUI(clothesFromStorage: currentClothesSet)
            stretchView.initWithClothes(clothes: clothes)
        }
        else{
            let success = stretchView.restoreCurrentUsedClothes()
            if success {
            }
            else{
                clothes = clothInstance.getStandardClothesSetForUI()
                stretchView.initWithClothes(clothes: clothes)
            }
        }
        self.stretchView.initBackgroundView()
        self.stretchView.initBackgroundView(imageName: "w-model")
    }
    @IBAction func changeSkinColorAction(_ sender: UIButton) {
        if self.changeSkinColorStackView.arrangedSubviews.count < 2{
            self.scoresAndStylesView.alpha = 0
            var skinColors:SkinColors = SkinColors()
            let skinColorsArray = skinColors.getSkinColorArray()
            var tag = 0
            for skinColor in skinColorsArray {
                let button1:UIButton = UIButton()
                button1.backgroundColor = skinColor
                button1.heightAnchor.constraint(equalToConstant: 30).isActive = true
                button1.widthAnchor.constraint(equalToConstant: 84).isActive = true
                button1.addTarget(self, action: #selector(self.selectSkinColor(_:)), for: .touchUpInside)
                button1.tag = tag
                button1.isHidden = true
                tag = tag + 1
                self.changeSkinColorStackView.addArrangedSubview(button1)
                UIView.animate(withDuration: 0.3) {
                    button1.isHidden = false
                    button1.layoutIfNeeded()
                }
            }
        }
        else {
            self.scoresAndStylesView.alpha = 1.0
            for _ in 1...changeSkinColorStackView.arrangedSubviews.count-1   {
                UIView.animate(withDuration: 0.2) {
                    self.changeSkinColorStackView.arrangedSubviews[1].isHidden = true
                    self.changeSkinColorStackView.arrangedSubviews[1].removeFromSuperview()
                }
            }
        }
    }
    func selectSkinColor(_ sender:UIButton){
        var skinColors:SkinColors = SkinColors()
        let skinColorsArray = skinColors.getSkinColorArray()
        self.scoresAndStylesView.alpha = 1.0
        for _ in 1...changeSkinColorStackView.arrangedSubviews.count-1   {
            UIView.animate(withDuration: 0.2) {
                self.changeSkinColorStackView.arrangedSubviews[1].isHidden = true
                self.changeSkinColorStackView.arrangedSubviews[1].removeFromSuperview()
            }
        }
        let button:UIButton = self.changeSkinColorStackView.arrangedSubviews[0] as! UIButton
        button.backgroundColor = skinColorsArray[sender.tag]
        let currentGender:String = UserDefaults.standard.string(forKey: "Matchee.currentGender")!
        if currentGender == "M"{
            self.stretchView.changeBackgroundViewColor(color:skinColorsArray[sender.tag], image:"m-model")
        }
        else{
            self.stretchView.changeBackgroundViewColor(color:skinColorsArray[sender.tag], image:"w-model")
        }
    }
    @IBAction func showFineTuningColorPicker(_ sender: UIButton) {
        self.colorPickerFineTuningOutlet.isHidden = false
        self.colorPickerFineTuningImageView.color = self.selectedClothingElement.color
        self.ColorHEXTextField.text = self.selectedClothingElement.color.hexString
        UIView.animate(withDuration: 0.5, animations: {
            self.colorPickerFineTuneConstraint.constant = self.colorPickerFineTuneConstraint.constant - self.view.frame.height
            self.colorPickerFineTuningImageView.layoutIfNeeded()
        })
    }
    @IBAction func hideFineTuningColorPicker(_ sender: UIButton) {
        let colorString:String = self.fineTunedColorView.backgroundColor!.hexString
        self.clothColorLabel.text = self.selectedClothingElement.name + " HUE "
        self.clothHueLabel.text = "Hex color code = " + colorString
        self.stretchView.setImageViewColor(cloth: self.selectedClothingElement, color: self.fineTunedColorView.backgroundColor!)
        self.colorMatching()
        UIView.animate(withDuration: 0.5, animations: {
            self.colorPickerFineTuneConstraint.constant = self.colorPickerFineTuneConstraint.constant + self.view.frame.height
        })
    }
    @IBAction func showDesignerViewAction(_ sender: UIButton) {
        self.updateDesignerView()
        self.leftSideMenuStackView.isHidden = true
        self.designerView.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.designerView.frame = CGRect(x: self.designerView.frame.origin.x + self.designerView.frame.size.width, y: self.designerView.frame.origin.y, width: self.designerView.frame.size.width, height: self.designerView.frame.size.height)
            print(self.designerLeadingConstraint.constant)
            self.designerLeadingConstraint.constant = self.designerLeadingConstraint.constant + self.designerView.frame.size.width
            self.designerView.layoutIfNeeded()
        }, completion:{ (true) in
            if self.actionView.isHidden == false {
                self.showHideActionView()
            }
        })
    }
    func hideDesignerView(){
    }
    func changeClothColorFromDetection(_ notification: NSNotification){
        if let selectedColor:UIColor = notification.userInfo?["selectedColor"] as? UIColor {
            self.stretchView.setImageViewColor(cloth: self.selectedClothingElement, color: selectedColor)
            self.colorMatching()
        }
    }
    func presentCameraPicker(_ notification: NSNotification?){
        if let clothingElement = notification?.userInfo?["clothingElement"] as? Cloth {
            self.selectedClothingElement = clothingElement
        }
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            self.picker.sourceType = UIImagePickerControllerSourceType.camera
            self.picker.cameraCaptureMode = .photo
            self.picker.cameraDevice = .rear
            self.picker.showsCameraControls = true
            let customViewController = ColorDetectorViewController(
                nibName:"ColorDetectorViewController",
                bundle: nil)
            let customView:ColorDetectorView = customViewController.view as! ColorDetectorView
            customView.frame = CGRect(x: picker.view.frame.origin.x, y: picker.view.frame.origin.y, width: picker.view.frame.size.width, height: picker.view.frame.size.height - 100)
            self.picker.modalPresentationStyle = .fullScreen
            self.present(self.picker,animated: true,completion: {
                self.picker.cameraOverlayView = customView
                self.picker.cameraOverlayView?.isUserInteractionEnabled = true
            })
        } else { 
            let alertVC = UIAlertController(
                title: "No Camera",
                message: "Sorry, this device has no camera",
                preferredStyle: .alert)
            let okAction = UIAlertAction(
                title: "OK",
                style:.default,
                handler: nil)
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    func updateDesignerView(){
        self.topDesignerLabel.text = currentClothPiecesOfStretchView.sharedInstance.top[0] as? String
        self.beltDesignerLabel.text = currentClothPiecesOfStretchView.sharedInstance.belt[0] as? String
        self.bottomDesignerLabel.text = currentClothPiecesOfStretchView.sharedInstance.bottom[0] as? String
        self.shoesDesignerLabel.text = currentClothPiecesOfStretchView.sharedInstance.shoes[0] as? String
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5, animations: {
            self.colorPickerFineTuneConstraint.constant = self.colorPickerFineTuneConstraint.constant - 120
            self.colorPickerFineTuningImageView.layoutIfNeeded()
        })
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.5, animations: {
            self.colorPickerFineTuneConstraint.constant = self.colorPickerFineTuneConstraint.constant + 120
            self.colorPickerFineTuningImageView.layoutIfNeeded()
        })
        self.colorPickerFineTuningImageView.color = Color.init(hex:self.ColorHEXTextField.text!)
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.lengthOfBytes(using: String.Encoding.ascii))! + string.lengthOfBytes(using: String.Encoding.ascii) - range.length
        return (newLength >  7 ) ? false : true
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: false, completion: {
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                let circleCropController = KACircleCropViewController(withImage: pickedImage)
                circleCropController.delegate = self
                self.present(circleCropController, animated: true, completion: nil)
            }
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)    {
        picker.dismiss(animated:true, completion: nil)
    }
    func circleCropDidCancel() {
        dismiss(animated: false, completion: nil)
    }
    func circleCropDidCropImage(_ image: UIImage) {
        dismiss(animated: false, completion: {
            let customViewController = ColorTuningViewController(
                nibName:"ColorTuningViewController",
                bundle: nil)
            customViewController.view.frame = self.view.frame
            customViewController.imageFromPicker = image
            self.present(customViewController, animated: true, completion: nil)
        })
    }
    private var counter = 0
    func updateScores(GlobalMatch:String, TopBottomMatch:String, AccessoriesMatch:String){
        let redColor = UIColor(red: 217/255.0, green: 144/255.0, blue: 134/255.0, alpha: 1.0)
        let greenColor = UIColor(red: 133/255.0, green: 214/255.0, blue: 168/255.0, alpha: 1.0)
        if GlobalMatch != NSLocalizedString("MatchColors_Match", comment: ""){
            self.globalMatchLabel.textColor = redColor
            self.allMatchIcons.image = UIImage(named: "men_all_NOMatch")
        }
        else{
            self.globalMatchLabel.textColor = greenColor
            self.allMatchIcons.image = UIImage(named: "men_all_Match")
        }
        self.globalMatchLabel.text = GlobalMatch
        if TopBottomMatch != NSLocalizedString("MatchColors_Match", comment: ""){ 
            self.tobBottomMatchLabel.textColor = redColor
            self.topMatchIcons.image = UIImage(named: "men_top_NOMatch")
        }
        else{
            self.tobBottomMatchLabel.textColor = greenColor
            self.topMatchIcons.image = UIImage(named: "men_top_Match")
        }
        self.tobBottomMatchLabel.text = TopBottomMatch
        if AccessoriesMatch != NSLocalizedString("MatchColors_Match", comment: ""){
            self.accessoriesMatchLabel.textColor = redColor
            self.accMatchIcons.image = UIImage(named: "men_acc_NOMatch")
        }
        else{
            self.accessoriesMatchLabel.textColor = greenColor
            self.accMatchIcons.image = UIImage(named: "men_acc_Match")
        }
        self.accessoriesMatchLabel.text = AccessoriesMatch
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
     func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        let storageManager = Storage()
        let storedSets = storageManager.getNumberOfExistingSets()
        return storedSets + 1
    }
     func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StyleCell", for: indexPath) as! StyleCollectionViewCell
        if indexPath.row == collectionView.numberOfItems(inSection: indexPath.section)-1 {
            cell.beltColorValue = UIColor.clear
            cell.topColorValue = UIColor.clear
            cell.bottomColorValue = UIColor.clear
            cell.shoesColorValue = UIColor.clear
            cell.maskImage.image = UIImage(named: "buttonAdd")
            cell.updateCellColors()
        }
        else{
            cell.maskImage.image = UIImage(named: "mask")
            let storageManager = Storage()
            let clothesSets = storageManager.getAllClothingSets()
            var clothes:[Clothes] = [Clothes]()
            if let clothesSet = clothesSets?[indexPath.row]{ 
               let clothesIds = NSKeyedUnarchiver.unarchiveObject(with: clothesSet.clothesIds as! Data) as! NSArray
               clothes = storageManager.getCloth(clothIDs: clothesIds as! [Int])
            }
            var colors:[UIColor] = [UIColor]()
            for clothFetched in clothes {
                let color = NSKeyedUnarchiver.unarchiveObject(with: clothFetched.color as! Data) as! (UIColor)
                colors.append(color)
            }
            if colors.count == 4 {
                cell.topColorValue = colors[0]
                cell.beltColorValue = colors[3]
                cell.bottomColorValue = colors[2]
                cell.shoesColorValue = colors[1]
                cell.updateCellColors()
                print("index path for stored set = \(indexPath.row + 2)")
                storedSetsColors.append(colors)
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath)-> CGSize{
        return CGSize(width: 40.0, height: 40.0)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        let storageManager = Storage()
        if indexPath.row == collectionView.numberOfItems(inSection: indexPath.section)-1 {
            SweetAlert().showAlert(NSLocalizedString("SaveStylePopup_Title", comment: "") , subTitle: NSLocalizedString("SaveStylePopup_SubTitle", comment: ""), style: AlertStyle.none, buttonTitle:NSLocalizedString("SaveStylePopup_Cancel", comment: ""), buttonColor:UIColor(red: 217/255.0, green: 144/255.0, blue: 134/255.0, alpha: 1.0) , otherButtonTitle:NSLocalizedString("SaveStylePopup_Ok", comment: ""), otherButtonColor: UIColor(red: 133/255.0, green: 214/255.0, blue: 168/255.0, alpha: 1.0)) { (isOtherButton) -> Void in
                if isOtherButton == true {
                    print("Cancel Button Pressed")
                }
                else {
                    let result = storageManager.storeClothesSet(clothesArray: self.stretchView.clothes)
                    if result {
                        _ = SweetAlert().showAlert(NSLocalizedString("SaveStylePopup_Saved", comment: ""), subTitle: NSLocalizedString("SaveStylePopup_SavedTitle", comment: ""), style: AlertStyle.success)
                        self.storedSetsColors.removeAll()
                        collectionView.reloadData()
                    }
                    else{
                        _ = SweetAlert().showAlert(NSLocalizedString("SaveStylePopup_NotSaved", comment: ""), subTitle: NSLocalizedString("SaveStylePopup_NotSavedTitle", comment: ""), style: AlertStyle.error)
                    }
                }
            }
        }
        else{
            print("Selected set index path is \(indexPath.row) and storedSetColors = \(storedSetsColors)")
            let colors = storedSetsColors[indexPath.row]
            self.stretchView.setStoredSetColorsToCurrentClothes(storedColors: colors)
            self.colorMatching()
        }
    }
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int{
        return 5
    }
    let pointOfInterest = UIView()
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        let flatCutoutPathMaker = { (frame: CGRect) -> UIBezierPath in
            return UIBezierPath(rect: frame)
        }
        var coachMark : CoachMark
        switch(index) {
        case 0:
            coachMark = coachMarksController.helper.makeCoachMark(for: self.stretchView.clothes[0].imageView){ (frame: CGRect) -> UIBezierPath in
                return UIBezierPath(ovalIn: frame.insetBy(dx: -100, dy: -100))
            }
        case 1:
            coachMark = coachMarksController.helper.makeCoachMark(for: self.stretchView.clothes[0].imageView){ (frame: CGRect) -> UIBezierPath in
                return UIBezierPath(ovalIn: frame.insetBy(dx: 50, dy: 50))
            }
            coachMark.arrowOrientation = .top
        case 2:
            coachMark = coachMarksController.helper.makeCoachMark(for: self.stretchView.clothes[0].imageView){ (frame: CGRect) -> UIBezierPath in
                return UIBezierPath(ovalIn: frame.insetBy(dx: 50, dy: 50))
            }
            coachMark.arrowOrientation = .top
        case 3:
            coachMark = coachMarksController.helper.makeCoachMark(for: self.stretchView.clothes[0].imageView){ (frame: CGRect) -> UIBezierPath in
                return UIBezierPath(ovalIn: frame.insetBy(dx: 0, dy: 0))
            }
        case 4:
            coachMark = coachMarksController.helper.makeCoachMark(for: self.matcheeButtonOutlet, pointOfInterest: self.matcheeButtonOutlet?.center){ (frame: CGRect) -> UIBezierPath in
                return UIBezierPath(ovalIn: frame.insetBy(dx: -4, dy: -4))
            }
        default:
            coachMark = coachMarksController.helper.makeCoachMark()
        }
        coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
        return coachMark
    }
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachMarkBodyView = CustomCoachMarkBodyView()
        var coachMarkArrowView:CustomCoachMarkArrowView? =  nil
        coachMarkBodyView.hintLabel.textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping
        var width: CGFloat = 0.0
        switch(index) {
        case 0:
            coachMarkBodyView.hintLabel.text = NSLocalizedString("tutorial_leftRight", comment: "")
            coachMarkBodyView.nextButton.setTitle("Ok!", for: UIControlState.normal)
            width = self.stretchView.clothes[0].imageView.bounds.width
            coachMarkArrowView = CustomCoachMarkArrowView(orientation: .top, imageName:"tutorial_swipeleftright")
            let oneThirdOfWidth = coachMarksController.overlay.frame.size.width / 3
            let adjustedWidth = width >= oneThirdOfWidth ? width - 2 * coachMark.horizontalMargin : width
            coachMarkArrowView!.plate.addConstraint(NSLayoutConstraint(item: coachMarkArrowView!.plate, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: adjustedWidth))
        case 1:
            coachMarkBodyView.hintLabel.text = NSLocalizedString("tutorial_color", comment: "")
            coachMarkBodyView.nextButton.setTitle("Ok!", for: UIControlState.normal)
            width = self.stretchView.clothes[0].imageView.bounds.width
            coachMarkArrowView = CustomCoachMarkArrowView(orientation: .top, imageName:"tutorial_tap")
            let oneThirdOfWidth = coachMarksController.overlay.frame.size.width / 3
            let adjustedWidth = width >= oneThirdOfWidth ? width - 2 * coachMark.horizontalMargin : width
            coachMarkArrowView!.plate.addConstraint(NSLayoutConstraint(item: coachMarkArrowView!.plate, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: adjustedWidth))
        case 2:
            coachMarkBodyView.hintLabel.text = NSLocalizedString("tutorial_camera", comment: "")
            coachMarkBodyView.nextButton.setTitle("Ok!", for: UIControlState.normal)
            width = self.stretchView.clothes[0].imageView.bounds.width
            coachMarkArrowView = CustomCoachMarkArrowView(orientation: .top, imageName:"tutorial_camera")
            let oneThirdOfWidth = coachMarksController.overlay.frame.size.width / 3
            let adjustedWidth = width >= oneThirdOfWidth ? width - 2 * coachMark.horizontalMargin : width
            coachMarkArrowView!.plate.addConstraint(NSLayoutConstraint(item: coachMarkArrowView!.plate, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: adjustedWidth))
        case 3:
            coachMarkBodyView.hintLabel.text = NSLocalizedString("tutorial_pinch", comment: "")
            coachMarkBodyView.nextButton.setTitle("Ok!", for: UIControlState.normal)
            width = self.matcheeButtonOutlet.bounds.width
            coachMarkArrowView = CustomCoachMarkArrowView(orientation: .top, imageName:"tutorial_pinch")
            let oneThirdOfWidth = coachMarksController.overlay.frame.size.width / 3
            let adjustedWidth = width >= oneThirdOfWidth ? width - 2 * coachMark.horizontalMargin : width
            coachMarkArrowView!.plate.addConstraint(NSLayoutConstraint(item: coachMarkArrowView!.plate, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: adjustedWidth))
        case 4:
            coachMarkBodyView.hintLabel.text = NSLocalizedString("tutorial_match", comment: "")
            coachMarkBodyView.nextButton.setTitle("Go!", for: UIControlState.normal)
            width = self.matcheeButtonOutlet.bounds.width
            coachMarkArrowView = CustomCoachMarkArrowView(orientation: .top, imageName:"")
            let oneThirdOfWidth = coachMarksController.overlay.frame.size.width / 3
            let adjustedWidth = width >= oneThirdOfWidth ? width - 2 * coachMark.horizontalMargin : width
            coachMarkArrowView!.plate.addConstraint(NSLayoutConstraint(item: coachMarkArrowView!.plate, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: adjustedWidth))
        default: break
        }
        return (bodyView: coachMarkBodyView, arrowView: coachMarkArrowView)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DesignerSegue1"
        {
            switch (sender as! UIButton).tag {
            case 0:
                (segue.destination as? DesignerDetailsViewController)?.URLString = (currentClothPiecesOfStretchView.sharedInstance.top[1] as? String)!
                (segue.destination as? DesignerDetailsViewController)?.designerISProfile = (currentClothPiecesOfStretchView.sharedInstance.top[2] as? String)!
            case 1:
                (segue.destination as? DesignerDetailsViewController)?.URLString = (currentClothPiecesOfStretchView.sharedInstance.belt[1] as? String)!
                (segue.destination as? DesignerDetailsViewController)?.designerISProfile = (currentClothPiecesOfStretchView.sharedInstance.belt[2] as? String)!
            case 2:
                (segue.destination as? DesignerDetailsViewController)?.URLString = (currentClothPiecesOfStretchView.sharedInstance.bottom[1] as? String)!
                (segue.destination as? DesignerDetailsViewController)?.designerISProfile = (currentClothPiecesOfStretchView.sharedInstance.bottom[2] as? String)!
            case 3:
                (segue.destination as? DesignerDetailsViewController)?.URLString = (currentClothPiecesOfStretchView.sharedInstance.shoes[1] as? String)!
                (segue.destination as? DesignerDetailsViewController)?.designerISProfile = (currentClothPiecesOfStretchView.sharedInstance.shoes[2] as? String)!
            default:
                break
            }
        }
    }
}
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
}
