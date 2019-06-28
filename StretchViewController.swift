import UIKit
import CoreData
import Mixpanel
import Instructions
import NKOColorPickerView
class stretchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CoachMarksControllerDataSource, CoachMarksControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, KACircleCropViewControllerDelegate, DTColorPickerImageViewDelegate, UITextFieldDelegate {
    private let modelHeight = 600
    private let modelWidth = 300
    private let modelShiftAfterActionViewBecomesVisible:CGFloat = 45.0
    private let numberOfActiveAlgorithms:Int = 0
    private var keyboardLifting:CGFloat = 120.0
    private var colorPickerViewHeight:CGFloat = 134.0
    private var selectedClothingElement:Cloth = Cloth()
    private var timer:Timer = Timer()
    private var match:MatchColors = MatchColors()
    private var storedSetsColors:[[UIColor]] = [[UIColor]]()
    private var cameraDetectionClothTag = -1
    @IBOutlet var stretchView: StretchableView!
    @IBOutlet var changeColorView: UIView!
    private var counter = 0
    private let settingsView:UIView = UIView()
    var isShowColor = false
    let pointOfInterest = UIView()
    @IBOutlet var clothColorLabel: UILabel!
    @IBOutlet var clothHueLabel: UILabel!
    @IBOutlet var colorPickerImageView: DTColorPickerImageView!
    @IBOutlet var colorPickerFineTuningOutlet: UIView!
    @IBOutlet var colorPickerFineTuningImageView: NKOColorPickerView!
    @IBOutlet var fineTunedColorView: UIView!
    @IBOutlet var colorHEXTextField: UITextField!
    @IBOutlet var pencilImageView: UIImageView!
    @IBOutlet var modelBottomConstraint: NSLayoutConstraint!
    @IBOutlet var sideMenuHeightConstraint: NSLayoutConstraint!
    @IBOutlet var colorPickerFineTuneConstraint: NSLayoutConstraint!
    @IBOutlet weak var colorPickerFineTuneHeightConstraint: NSLayoutConstraint!
    @IBOutlet var mainSideMenu: UIStackView!
    @IBOutlet var shareButtonOutlet: UIButton!
    @IBOutlet var matcheeButtonOutlet: UIButton!
    @IBOutlet var colorPickerOutlet: UIButton!
    @IBOutlet var actionView: UIView!
    @IBOutlet var changeToManButton: UIButton!
    @IBOutlet var changeToWomanButton: UIButton!
    @IBOutlet var changeSkinColorButton: UIButton!
    @IBOutlet var changeSkinColorStackView: UIStackView!
    @IBOutlet var stylesCollectionView: UICollectionView!
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
        setupUI()
        addNotifications()
        setupDelegatesAndDatasources()
        setupCollectionView()
        setupStorageManager()
        setupFineColorPicker()
        checkIfAppNeedsRating()
        setupClothesArrays()
        let currentGender:String = UserDefaults.standard.string(forKey: "MulticolorFitting.currentGender")!
        if currentGender == "M"{
            changeToManButtonAction(UIButton())
        }
        else{
            changeToWomanButtonAction(UIButton())
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UserDefaults.standard.bool(forKey: "MulticolorFitting.isFirstLaunch"){
            UserDefaults.standard.set(1, forKey: "MulticolorFitting.complementaryCheck")
            UserDefaults.standard.synchronize()
            UserDefaults.standard.set(1, forKey: "MulticolorFitting.monochromaticCheck")
            UserDefaults.standard.synchronize()
            UserDefaults.standard.set(true, forKey: "MulticolorFitting.isFirstLaunch")
            UserDefaults.standard.synchronize()
            coachMarksController.startOn(self)
        }
    }
    fileprivate func setupUI() {
        fitStretchView()
        addGestureRecognizers()
        changeColorView.isHidden = true
        colorPickerOutlet.layer.cornerRadius = 20.5
        colorPickerOutlet.clipsToBounds = true
        changeSkinColorStackView.layer.cornerRadius = 15.0
        changeSkinColorStackView.clipsToBounds = true
        changeSkinColorButton.layer.cornerRadius = 15.0
        changeSkinColorButton.clipsToBounds = true
        shareButtonOutlet.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        matcheeButtonOutlet.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        coachMarksController.overlay.color = UIColor(red: 80/255.0, green: 80/255.0, blue: 80/255.0, alpha: 0.85)
        coachMarksController.overlay.allowTap = true
        colorPickerFineTuningOutlet.isHidden = true
        colorPickerFineTuneConstraint.constant = colorPickerFineTuneConstraint.constant + view.frame.height
    }
    fileprivate func setupCollectionView() {
        stylesCollectionView.delegate = self
        stylesCollectionView.dataSource = self
        stylesCollectionView.register(UINib(nibName:"StyleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StyleCell")
    }
    fileprivate func setupDelegatesAndDatasources() {
        coachMarksController.dataSource = self
        colorHEXTextField.delegate = self
        picker.delegate = self
        colorPickerImageView.delegate = self
    }
    fileprivate func setupStorageManager() {
        let storageManager = StorageManager()
        storageManager.initClothesStorage()
    }
    fileprivate func setupFineColorPicker() {
        let colorDidChangeBlock: NKOColorPickerDidChangeColorBlock = { (color) in
            self.fineTunedColorView.backgroundColor = color!
            self.colorHEXTextField.text = color!.hexString
            let b = color!.hsba().b
            if b < 0.6 {
                self.colorHEXTextField.textColor = UIColor.white
                self.pencilImageView.image = UIImage(named: "pencil_white")
            }
            else{
                self.colorHEXTextField.textColor = UIColor.darkGray
                self.pencilImageView.image = UIImage(named: "pencil_black")
            }
        }
        colorPickerFineTuningImageView.didChangeColorBlock = colorDidChangeBlock
    }
    fileprivate func checkIfAppNeedsRating() {
        Judex.shared.daysUntilPrompt = 3
        Judex.shared.remindPeriod = -1
        Judex.shared.promptIfRequired()
    }
    fileprivate func setupClothesArrays() {
        let clothStructMen = ClothesMen()
        let clothStructWomen = ClothesWomen()
        menClothesArray = clothStructMen.getMenClothesFromStruct()
        womenClothesArray = clothStructWomen.getWomenClothesFromStruct()
    }
    fileprivate func fitStretchView(){
        let screenHeight = UIScreen.main.bounds.height
        switch screenHeight {
        case 896:
            colorPickerViewHeight = 164.0
            self.colorPickerFineTuneConstraint.constant = -20.0
            self.colorPickerFineTuneHeightConstraint.constant = -130.0
            self.keyboardLifting = 140.0
        case 812:
            colorPickerViewHeight = 144.0
            self.colorPickerFineTuneConstraint.constant = -20.0
            self.colorPickerFineTuneHeightConstraint.constant = -130.0
            self.keyboardLifting = 140.0
        default:
            colorPickerViewHeight = 134.0
        }
    }
    fileprivate func addGestureRecognizers(){
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.actionView.addGestureRecognizer(swipeRight)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizer.Direction.up
        self.view.addGestureRecognizer(swipeUp)
    }
    fileprivate func addNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(showHideBottomMenuFromTap(_:)), name: NSNotification.Name(rawValue: "Notification.showBottomMenu"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveCurrentUsedClothes), name: NSNotification.Name(rawValue: "Notification.saveCurrentUsedClothes"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(colorMatching), name: NSNotification.Name(rawValue: "Notification.colorMatching"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentCameraPicker(_:)), name: NSNotification.Name(rawValue: "Notification.presentPicker"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeClothColorFromDetection(_:)), name: NSNotification.Name(rawValue: "Notification.changeClothColorFromDetection"), object: nil)
    }
    @objc func saveCurrentUsedClothes(){
        stretchView.saveCurrentUsedClothes()
    }
    func showHideActionView(){
        if actionView.isHidden {
            actionView.frame = CGRect(x: actionView.frame.origin.x + actionView.frame.size.width, y: actionView.frame.origin.y, width: actionView.frame.size.width, height: actionView.frame.size.height)
            actionView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.actionView.frame = CGRect(x: self.actionView.frame.origin.x - self.actionView.frame.size.width, y: self.actionView.frame.origin.y, width: self.actionView.frame.size.width, height: self.actionView.frame.size.height)
                self.actionView.layoutIfNeeded()
            }, completion: { (true) in
                self.colorMatching()
            })
        }
        else{
            UIView.animate(withDuration: 0.3, animations: {
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
                        self.mainSideMenu.axis = NSLayoutConstraint.Axis.vertical
                        self.mainSideMenu.spacing = 10.0
                        let newConstraint2:NSLayoutConstraint = NSLayoutConstraint(item: self.stretchView, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 8)
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
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                self.showHideActionView()
                break
            case UISwipeGestureRecognizer.Direction.down:
                break
            case UISwipeGestureRecognizer.Direction.left:
                break
            case UISwipeGestureRecognizer.Direction.up:
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
                self.mainSideMenu.axis = NSLayoutConstraint.Axis.horizontal
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
        mixpanel?.track("Button_Share", properties: properties)
        let myWebsite = NSURL(string:"https://itunes.apple.com/app/MulticolorFitting/id1470576113?mt=8")
        let img: UIImage = UIImage(named: "logo")!
        guard let url = myWebsite else {
            print("nothing found")
            return
        }
        let shareItems:Array = [(img),url]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToVimeo]
        self.present(activityViewController, animated: true, completion: nil)
    }
    @IBAction func changeAlgorithmButtonAction(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "MulticolorFitting.HasChangedAlgorithm")
        UserDefaults.standard.synchronize()
        let mixpanel = Mixpanel.sharedInstance()
        var properties = [String: String]()
        properties = ["Algorithm": ""]
        mixpanel?.track("Main_ClickOnChangeAlgorithm", properties: properties)
    }
    @objc func colorMatching(){
        let match:MatchColors = MatchColors()
        var globalMatch:String = "No Match"
        var accessoriesMatch:String = "No Match"
        var topBottomMatch:String = "No Match"
        let algo3 = UserDefaults.standard.integer(forKey: "MulticolorFitting.analogousCheck")
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
        let algo1 = UserDefaults.standard.integer(forKey: "MulticolorFitting.complementaryCheck")
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
        let algo2 = UserDefaults.standard.integer(forKey: "MulticolorFitting.monochromaticCheck")
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
        let algo4 = UserDefaults.standard.integer(forKey: "MulticolorFitting.splitComplementaryCheck")
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
        self.updateColorMatchingUI(GlobalMatch:globalMatch, TopBottomMatch:topBottomMatch,  AccessoriesMatch: accessoriesMatch)
    }
    @objc func showHideBottomMenuFromTap(_ notification: NSNotification?){
        let mixpanel = Mixpanel.sharedInstance()
        var properties = [String: String]()
        if let clothingElement = notification?.userInfo?["clothingElement"] as? Cloth {
            let colorString:String = clothingElement.color.hexString
            selectedClothingElement = clothingElement
            clothColorLabel.text = selectedClothingElement.name + " HUE "
            clothHueLabel.text = "Hex color code = " + colorString
            properties = ["SelectedCloth": clothingElement.name]
            mixpanel?.track("Main_ClickOnClothes", properties: properties)
        }
        else{
        }
        if changeColorView.isHidden == true{
            changeColorView.isHidden = false
            changeColorView.alpha = 0
            changeColorView.frame = CGRect(x: changeColorView.frame.origin.x, y: UIScreen.main.bounds.height, width: changeColorView.frame.size.width, height: colorPickerViewHeight)
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
        UserDefaults.standard.setValue("M", forKey: "MulticolorFitting.currentGender")
        UserDefaults.standard.synchronize()
        changeToManButton.setBackgroundImage(UIImage(named:"buttonGenderSelected"), for: UIControl.State.normal)
        changeToWomanButton.setBackgroundImage(UIImage(named:"buttonGenderNotSelected"), for: UIControl.State.normal)
        let storageManager = StorageManager()
        let clothInstance:Cloth = Cloth()
        var clothes:[Cloth] = [Cloth]()
        let currentSet:[Clothes]? = storageManager.getCurrentClothingSet(gender: 0)
        if let currentClothesSet = currentSet {
            clothes = clothInstance.getClothesObjectsForUI(clothesFromStorage: currentClothesSet)
            stretchView.initWithClothes(clothes: clothes)
        }
        else{
            let success = stretchView.restoreCurrentUsedClothes()
            if !success {
                clothes = clothInstance.getStandardClothesSetForUI()
                stretchView.initWithClothes(clothes: clothes)
            }
        }
        stretchView.initBackgroundView()
        stretchView.initBackgroundView(imageName: "m-model")
    }
    @IBAction func changeToWomanButtonAction(_ sender: UIButton) {
        UserDefaults.standard.setValue("W", forKey: "MulticolorFitting.currentGender")
        UserDefaults.standard.synchronize()
        changeToManButton.setBackgroundImage(UIImage(named:"buttonGenderNotSelected"), for: UIControl.State.normal)
        changeToWomanButton.setBackgroundImage(UIImage(named:"buttonGenderSelected"), for: UIControl.State.normal)
        let storageManager = StorageManager()
        let clothInstance:Cloth = Cloth()
        var clothes:[Cloth] = [Cloth]()
        let currentSet:[Clothes]? = storageManager.getCurrentClothingSet(gender: 1)
        if let currentClothesSet = currentSet {
            clothes = clothInstance.getClothesObjectsForUI(clothesFromStorage: currentClothesSet)
            stretchView.initWithClothes(clothes: clothes)
        }
        else{
            let success = stretchView.restoreCurrentUsedClothes()
            if !success {
                clothes = clothInstance.getStandardClothesSetForUI()
                stretchView.initWithClothes(clothes: clothes)
            }
        }
        stretchView.initBackgroundView()
        stretchView.initBackgroundView(imageName: "w-model")
    }
    @IBAction func changeSkinColorAction(_ sender: UIButton) {
        if changeSkinColorStackView.arrangedSubviews.count < 2{
            scoresAndStylesView.alpha = 0
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
                changeSkinColorStackView.addArrangedSubview(button1)
                UIView.animate(withDuration: 0.3) {
                    button1.isHidden = false
                    button1.layoutIfNeeded()
                }
            }
        }
        else {
            scoresAndStylesView.alpha = 1.0
            for _ in 1...changeSkinColorStackView.arrangedSubviews.count-1   {
                UIView.animate(withDuration: 0.2) {
                    self.changeSkinColorStackView.arrangedSubviews[1].isHidden = true
                    self.changeSkinColorStackView.arrangedSubviews[1].removeFromSuperview()
                }
            }
        }
    }
    @objc func selectSkinColor(_ sender:UIButton){
        var skinColors:SkinColors = SkinColors()
        let skinColorsArray = skinColors.getSkinColorArray()
        scoresAndStylesView.alpha = 1.0
        for _ in 1...changeSkinColorStackView.arrangedSubviews.count-1   {
            UIView.animate(withDuration: 0.2) {
                self.changeSkinColorStackView.arrangedSubviews[1].isHidden = true
                self.changeSkinColorStackView.arrangedSubviews[1].removeFromSuperview()
            }
        }
        let button:UIButton = changeSkinColorStackView.arrangedSubviews[0] as! UIButton
        button.backgroundColor = skinColorsArray[sender.tag]
        let currentGender:String = UserDefaults.standard.string(forKey: "MulticolorFitting.currentGender")!
        if currentGender == "M"{
            stretchView.changeBackgroundViewColor(color:skinColorsArray[sender.tag], image:"m-model")
        }
        else{
            stretchView.changeBackgroundViewColor(color:skinColorsArray[sender.tag], image:"w-model")
        }
    }
    @IBAction func showFineTuningColorPicker(_ sender: UIButton) {
        if isShowColor  {
        }else{
            isShowColor = true
            colorPickerFineTuningOutlet.isHidden = false
            colorPickerFineTuningImageView.color = self.selectedClothingElement.color
            colorHEXTextField.text = selectedClothingElement.color.hexString
            UIView.animate(withDuration: 0.5, animations: {
                self.colorPickerFineTuneConstraint.constant = self.colorPickerFineTuneConstraint.constant - self.view.frame.height
                self.colorPickerFineTuningImageView.layoutIfNeeded()
            })
        }
    }
    @IBAction func hideFineTuningColorPicker(_ sender: UIButton) {
        isShowColor = false
        let colorString:String = fineTunedColorView.backgroundColor!.hexString
        self.clothColorLabel.text = selectedClothingElement.name + " HUE "
        self.clothHueLabel.text = "Hex color code = " + colorString
        self.stretchView.setImageViewColor(cloth: selectedClothingElement, color: fineTunedColorView.backgroundColor!)
        self.colorMatching()
        UIView.animate(withDuration: 0.5, animations: {
            self.colorPickerFineTuneConstraint.constant = self.colorPickerFineTuneConstraint.constant + self.view.frame.height
        })
    }
    @objc func changeClothColorFromDetection(_ notification: NSNotification){
        if let selectedColor:UIColor = notification.userInfo?["selectedColor"] as? UIColor {
            self.stretchView.setImageViewColor(cloth: self.selectedClothingElement, color: selectedColor)
            self.colorMatching()
        }
    }
    @objc func presentCameraPicker(_ notification: NSNotification?){
        if let clothingElement = notification?.userInfo?["clothingElement"] as? Cloth {
            selectedClothingElement = clothingElement
        }
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.cameraCaptureMode = .photo
            picker.cameraDevice = .rear
            picker.showsCameraControls = true
            let customViewController = ColorDetectorViewController(
                nibName:"ColorDetectorViewController",
                bundle: nil)
            let customView:ColorDetectorView = customViewController.view as! ColorDetectorView
            customView.frame = CGRect(x: picker.view.frame.origin.x, y: picker.view.frame.origin.y, width: picker.view.frame.size.width, height: picker.view.frame.size.height - 100)
            picker.modalPresentationStyle = .fullScreen
            present(picker, animated: true, completion: {
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
            present(alertVC, animated: true, completion: nil)
        }
    }
    func imageView(_ imageView: DTColorPickerImageView, didPickColorWith color: UIColor) {
        let colorString:String = color.hexString
        self.clothColorLabel.text = self.selectedClothingElement.name + " HUE "
        self.clothHueLabel.text = "Hex color code = " + colorString
        self.stretchView.setImageViewColor(cloth: self.selectedClothingElement, color: color)
        self.colorMatching()
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        picker.dismiss(animated: false, completion: {
            if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DesignerSegue1"
        {
        }
    }
}
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
extension stretchViewController {
    func updateColorMatchingUI(GlobalMatch:String, TopBottomMatch:String, AccessoriesMatch:String){
        let redColor = MC.MulticolorFittingRedColor
        let greenColor = MC.MulticolorFittingGreenColor
        let matchText = NSLocalizedString("MatchColors_Match", comment: "")
    }
}
extension stretchViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        let storageManager = StorageManager()
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
            let storageManager = StorageManager()
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
        let storageManager = StorageManager()
        if indexPath.row == collectionView.numberOfItems(inSection: indexPath.section)-1 {
            let alertMainButtonColor = MC.MulticolorFittingRedColor
            let alertSecondButtonColor = MC.MulticolorFittingGreenColor
            SweetAlertViewController().showAlert(NSLocalizedString("SaveStylePopup_Title", comment: "") ,
                                                 subTitle: NSLocalizedString("SaveStylePopup_SubTitle", comment: ""),
                                                 style: AlertStyle.none,
                                                 buttonTitle:NSLocalizedString("SaveStylePopup_Cancel", comment: ""),
                                                 buttonColor: alertMainButtonColor,
                                                 otherButtonTitle:NSLocalizedString("SaveStylePopup_Ok", comment: ""),
                                                 otherButtonColor: alertSecondButtonColor ) { (isOtherButton) -> Void in
                                                    if isOtherButton == true {
                                                        print("Cancel Button Pressed")
                                                    }
                                                    else {
                                                        let result = storageManager.storeClothesSet(clothesArray: self.stretchView.clothes)
                                                        if result {
                                                            _ = SweetAlertViewController().showAlert(NSLocalizedString("SaveStylePopup_Saved", comment: ""), subTitle: NSLocalizedString("SaveStylePopup_SavedTitle", comment: ""), style: AlertStyle.success)
                                                            self.storedSetsColors.removeAll()
                                                            collectionView.reloadData()
                                                        }
                                                        else{
                                                            _ = SweetAlertViewController().showAlert(NSLocalizedString("SaveStylePopup_NotSaved", comment: ""), subTitle: NSLocalizedString("SaveStylePopup_NotSavedTitle", comment: ""), style: AlertStyle.error)
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
}
extension stretchViewController {
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int{
        return 5
    }
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
            coachMarkBodyView.nextButton.setTitle("Ok!", for: UIControl.State.normal)
            width = stretchView.clothes[0].imageView.bounds.width
            coachMarkArrowView = CustomCoachMarkArrowView(orientation: .top, imageName:"tutorial_swipeleftright")
            let oneThirdOfWidth = coachMarksController.overlay.frame.size.width / 3
            let adjustedWidth = width >= oneThirdOfWidth ? width - 2 * coachMark.horizontalMargin : width
            coachMarkArrowView!.plate.addConstraint(NSLayoutConstraint(item: coachMarkArrowView!.plate, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: adjustedWidth))
        case 1:
            coachMarkBodyView.hintLabel.text = NSLocalizedString("tutorial_color", comment: "")
            coachMarkBodyView.nextButton.setTitle("Ok!", for: UIControl.State.normal)
            width = stretchView.clothes[0].imageView.bounds.width
            coachMarkArrowView = CustomCoachMarkArrowView(orientation: .top, imageName:"tutorial_tap")
            let oneThirdOfWidth = coachMarksController.overlay.frame.size.width / 3
            let adjustedWidth = width >= oneThirdOfWidth ? width - 2 * coachMark.horizontalMargin : width
            coachMarkArrowView!.plate.addConstraint(NSLayoutConstraint(item: coachMarkArrowView!.plate, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: adjustedWidth))
        case 2:
            coachMarkBodyView.hintLabel.text = NSLocalizedString("tutorial_camera", comment: "")
            coachMarkBodyView.nextButton.setTitle("Ok!", for: UIControl.State.normal)
            width = stretchView.clothes[0].imageView.bounds.width
            coachMarkArrowView = CustomCoachMarkArrowView(orientation: .top, imageName:"tutorial_camera")
            let oneThirdOfWidth = coachMarksController.overlay.frame.size.width / 3
            let adjustedWidth = width >= oneThirdOfWidth ? width - 2 * coachMark.horizontalMargin : width
            coachMarkArrowView!.plate.addConstraint(NSLayoutConstraint(item: coachMarkArrowView!.plate, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: adjustedWidth))
        case 3:
            coachMarkBodyView.hintLabel.text = NSLocalizedString("tutorial_pinch", comment: "")
            coachMarkBodyView.nextButton.setTitle("Ok!", for: UIControl.State.normal)
            width = matcheeButtonOutlet.bounds.width
            coachMarkArrowView = CustomCoachMarkArrowView(orientation: .top, imageName:"tutorial_pinch")
            let oneThirdOfWidth = coachMarksController.overlay.frame.size.width / 3
            let adjustedWidth = width >= oneThirdOfWidth ? width - 2 * coachMark.horizontalMargin : width
            coachMarkArrowView!.plate.addConstraint(NSLayoutConstraint(item: coachMarkArrowView!.plate, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: adjustedWidth))
        case 4:
            coachMarkBodyView.hintLabel.text = NSLocalizedString("tutorial_match", comment: "")
            coachMarkBodyView.nextButton.setTitle("Go!", for: UIControl.State.normal)
            width = matcheeButtonOutlet.bounds.width
            coachMarkArrowView = CustomCoachMarkArrowView(orientation: .top, imageName:"")
            let oneThirdOfWidth = coachMarksController.overlay.frame.size.width / 3
            let adjustedWidth = width >= oneThirdOfWidth ? width - 2 * coachMark.horizontalMargin : width
            coachMarkArrowView!.plate.addConstraint(NSLayoutConstraint(item: coachMarkArrowView!.plate, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: adjustedWidth))
        default: break
        }
        return (bodyView: coachMarkBodyView, arrowView: coachMarkArrowView)
    }
}
extension stretchViewController {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5, animations: {
            self.colorPickerFineTuneConstraint.constant = self.colorPickerFineTuneConstraint.constant - self.keyboardLifting
            self.colorPickerFineTuningImageView.layoutIfNeeded()
        })
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.5, animations: {
            self.colorPickerFineTuneConstraint.constant = self.colorPickerFineTuneConstraint.constant + self.keyboardLifting
            self.colorPickerFineTuningImageView.layoutIfNeeded()
        })
        colorPickerFineTuningImageView.color = Color.init(hex:colorHEXTextField.text!)
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.lengthOfBytes(using: String.Encoding.ascii))! + string.lengthOfBytes(using: String.Encoding.ascii) - range.length
        return (newLength >  7 ) ? false : true
    }
}
