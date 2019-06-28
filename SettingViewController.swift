import UIKit
import MessageUI
import StoreKit
class SettingViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var btnRateApp: UIButton!
    @IBOutlet weak var btnFeedBack: UIButton!
    @IBOutlet weak var btnRestorePurchase: UIButton!
    @IBOutlet weak var btnPoli: UIButton!
    @IBOutlet weak var btnContact: UIButton!
    var urlAppGuide:URL = URL(string: "https://itunes.apple.com/app/MulticolorFitting/id1470576113?mt=8")!
    var mail:String = "jsonkeny@gmail.com"
    @available(iOS 10.0, *)
    func clearAllFile() {
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        print("Directory: \(paths)")
        do
        {
                    let ac = UIAlertController(title: "Cleared!", message: "The Cache is Cleared!!!", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
        }catch let error {
            print(error.localizedDescription)
        }
    }
    @IBAction func DimissAction(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
    @IBAction func abtnRateApp(_ sender: UIButton) {
        UIApplication.shared.open(urlAppGuide, options: [:], completionHandler: nil)
    }
    @IBAction func abtnFeedBack(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail(){
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients([mail])
            composeVC.setSubject("Wallpaper Feedback")
            composeVC.setMessageBody("Hey Bro! Here's my feedback.", isHTML: false)
            self.present(composeVC, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Warring", message: "Mail services are not available", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func abtnRestorePurchase(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            self.clearAllFile()
        } else {
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
            self.view.backgroundColor = UIColor.white
    }
    func setUpUI(){
        btnRateApp.set(image: #imageLiteral(resourceName: "rateOUR"), title: " Rate our app", titlePosition: .T, additionalSpacing: 50, state: .normal)
        btnFeedBack.set(image: #imageLiteral(resourceName: "feedback"), title: "  Feedback", titlePosition: .right, additionalSpacing: 50, state: .normal)
        btnRestorePurchase.set(image: #imageLiteral(resourceName: "cleanC"), title: "  Clear cache", titlePosition: .right, additionalSpacing: 50, state: .normal)
        btnPoli.set(image: #imageLiteral(resourceName: "PrivacyIM"), title: "Privacy Policy", titlePosition: .right, additionalSpacing: 50, state: .normal)
        btnContact.set(image: #imageLiteral(resourceName: "AboutUS"), title: "About US", titlePosition: .right, additionalSpacing: 50, state: .normal)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension SettingViewController{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
