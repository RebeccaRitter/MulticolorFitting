import UIKit
class GenderSelectionViewController: UIViewController {
    @IBAction func selectWomanAction(_ sender: UIButton) {
        UserDefaults.standard.set("W", forKey: "MulticolorFitting.currentGender")
        UserDefaults.standard.synchronize()
        self.performSegue(withIdentifier: "genderSelectedSegue", sender: self)
    }
    @IBAction func selectManAction(_ sender: UIButton) {
        UserDefaults.standard.set("M", forKey: "MulticolorFitting.currentGender")
        UserDefaults.standard.synchronize()
        self.performSegue(withIdentifier: "genderSelectedSegue", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
