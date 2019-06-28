import UIKit
class PrivacyViewController: UIViewController {
    @IBOutlet weak var mainWebview: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let PrivacyHtml = try! String(contentsOfFile: Bundle.main.path(forResource: "pro", ofType: "html")!, encoding: String.Encoding.utf8)
        mainWebview.loadHTMLString(PrivacyHtml, baseURL: URL.init(fileURLWithPath: "/Users/summer/Desktop/MulticolorFitting/MulticolorFitting/pro.html") )
        
    }
    @IBAction func dismisscon(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
}
