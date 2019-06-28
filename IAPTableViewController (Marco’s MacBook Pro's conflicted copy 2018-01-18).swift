import UIKit
import SwiftyStoreKit
import StoreKit
var sharedSecret = "ff1feed8d74647babc75975b6832ce59"
enum RegisteredPurchase:String
{
    case triadic = "Triadic_IAP"
}
class NetworkActivityIndicatorManager : NSObject {
    private static var loadingCount = 0
    class func NetworkOperationStarted() {
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        loadingCount += 1
    }
    class func networkOperationFinished(){
        if loadingCount > 0 {
            loadingCount -= 1
        }
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}
class IAPTableViewController: UITableViewController {
    var triadic = RegisteredPurchase.triadic
    var productsInfo = NSMutableArray()
    @IBAction func dismissAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)   
    }
    @IBAction func restoreButtonAction(_ sender: UIBarButtonItem) {
        self.restorePurchases()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getInfo(purchase: .triadic)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.productsInfo.count < 1 {
            return 1
        }
        else {
            return self.productsInfo.count
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IAPCell", for: indexPath)
        if self.productsInfo.count > 0 {
            cell.textLabel?.text = (self.productsInfo[indexPath.row] as! Dictionary<String, Any>)["title"] as! String?
            cell.detailTextLabel?.text = (self.productsInfo[indexPath.row] as! Dictionary<String, Any>)["description"] as! String?
        }
        else{
            cell.textLabel?.text = NSLocalizedString("addons_loading", comment: "Loading...")
            cell.detailTextLabel?.text = NSLocalizedString("addons_loading", comment: "Loading...")
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("addons_tableViewTitle", comment: "Available purchases")
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            if SwiftyStoreKit.canMakePayments   {
                self.purchase(purchase: .triadic)
            }
        }
    }
    func getInfo(purchase : RegisteredPurchase) {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([Bundle.main.bundleIdentifier! + "." + purchase.rawValue], completion: {
            result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            self.productsInfo.removeAllObjects()
            for product in result.retrievedProducts{
                var dict = Dictionary<String, Any>()
                dict = ["title": product.localizedTitle, "description": product.localizedDescription,"price":product.localizedPrice!]
                self.productsInfo.add(dict)
            }
            if self.productsInfo.count > 0 {
                self.tableView.reloadData()
            }
            else{
                self.showAlert(alert: self.alertForProductRetrievalInfo(result: result))
            }
        })
    }
    func purchase(purchase : RegisteredPurchase) {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.purchaseProduct(Bundle.main.bundleIdentifier! + "." + purchase.rawValue, completion: {
            result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            if case .success(let product) = result {
                if product.productId == Bundle.main.bundleIdentifier! + "." + "Triadic_IAP"{
                    UserDefaults.standard.set(1, forKey: "Matchee.splitComplementaryPurchased")
                    UserDefaults.standard.set(1, forKey: "Matchee.splitComplementaryCheck")
                    UserDefaults.standard.synchronize()
                    self.showAlert(alert: self.alertWithTitle(title: "Thank you!", message: "Your new algorithm is now available =)"))
                }
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
                self.showAlert(alert: self.alertForPurchaseResult(result: result))
            }
        })
    }
    func restorePurchases() {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true, completion: {
            result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            for product in result.restoredPurchases {
                if product.productId == Bundle.main.bundleIdentifier! + "." + "Triadic_IAP"{
                    UserDefaults.standard.set(1, forKey: "Matchee.splitComplementaryPurchased")
                    UserDefaults.standard.set(1, forKey: "Matchee.splitComplementaryCheck")
                    UserDefaults.standard.synchronize()
                    self.showAlert(alert: self.alertWithTitle(title: NSLocalizedString("addons_purchaseSuccessAlert_title", comment: "Thank you!"), message: NSLocalizedString("addons_purchaseSuccessAlert_message", comment: "Your new algorithm is now available =)")))
                }
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            }
            self.showAlert(alert: self.alertForRestorePurchases(result: result))
        })
    }
    func verifyReceipt() {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.verifyReceipt(using: sharedSecret as! ReceiptValidator, completion: {
            result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            self.showAlert(alert: self.alertForVerifyReceipt(result: result))
            if case .error(let error) = result {
                if case .noReceiptData = error {
                    self.refreshReceipt()
                }
            }
        })
    }
    func verifyPurcahse(product : RegisteredPurchase) {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.verifyReceipt(using: sharedSecret as! ReceiptValidator, completion: {
            result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            switch result{
            case .success(let receipt):
                let productID = Bundle.main.bundleIdentifier! + "." + product.rawValue
                    let purchaseResult = SwiftyStoreKit.verifyPurchase(productId: productID, inReceipt: receipt)
                    self.showAlert(alert: self.alertForVerifyPurchase(result: purchaseResult))
            case .error(let error):
                self.showAlert(alert: self.alertForVerifyReceipt(result: result))
                if case .noReceiptData = error {
                    self.refreshReceipt()
                }
            }
        })
    }
    func refreshReceipt() {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { result in
            switch result {
            case .success(let receipt):
                print("Verify receipt success: \(receipt)")
            case .error(let error):
                print("Verify receipt failed: \(error)")
            }
        }
    }
}
extension IAPTableViewController {
    func alertWithTitle(title : String, message : String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
    func showAlert(alert : UIAlertController) {
        guard let _ = self.presentedViewController else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    func alertForProductRetrievalInfo(result : RetrieveResults) -> UIAlertController {
        if let product = result.retrievedProducts.first {
            let priceString = product.localizedPrice!
            return alertWithTitle(title: product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
        }
        else if let invalidProductID = result.invalidProductIDs.first {
            return alertWithTitle(title: "Could not retreive product info", message: "Invalid product identifier: \(invalidProductID)")
        }
        else {
            let errorString = result.error?.localizedDescription ?? "Unknown Error. Please Contact Support"
            return alertWithTitle(title: "Could not retreive product info" , message: errorString)
        }
    }
    func alertForPurchaseResult(result : PurchaseResult) -> UIAlertController {
        switch result {
        case .success(let product):
            print("Purchase Succesful: \(product.productId)")
            return alertWithTitle(title: "Thank You", message: "Purchase completed")
        case .error(let error):
            print("Purchase Failed: \(error)")
            switch error.code {
            case.storeProductNotAvailable(let productID):
                return alertWithTitle(title: "Purchase Failed", message: "\(productID) is not a valid product identifier")
            case .paymentCancelled:
                return alertWithTitle(title: "Purchase Failed", message: "Payment canceled")
            case .paymentNotAllowed:
                return alertWithTitle(title: "Purchase Failed", message: "You are not allowed to make payments")
            default:
                return alertWithTitle(title: "Purchase Failed", message: "Error occurred with error code: \(error.code.rawValue)")
                break;
            }
        }
    }
    func alertForRestorePurchases(result : RestoreResults) -> UIAlertController {
        if result.restoreFailedPurchases.count > 0 {
            print("Restore Failed: \(result.restoreFailedPurchases)")
            return alertWithTitle(title: "Restore Failed", message: "Unknown Error. Please Contact Support")
        }
        else if result.restoredPurchases.count > 0 {
            return alertWithTitle(title: "Purchases Restored", message: "All purchases have been restored.")
        }
        else {
            return alertWithTitle(title: "Nothing To Restore", message: "No previous purchases were made.")
        }
    }
    func alertForVerifyReceipt(result: VerifyReceiptResult) -> UIAlertController {
        switch result {
        case.success(let receipt):
            return alertWithTitle(title: "Receipt Verified", message: "Receipt Verified Remotely")
        case .error(let error):
            switch error {
            case .noReceiptData:
                return alertWithTitle(title: "Receipt Verification", message: "No receipt data found, application will try to get a new one. Try Again.")
            default:
                return alertWithTitle(title: "Receipt verification", message: "Receipt Verification failed")
            }
        }
    }
    func alertForVerifySubscription(result: VerifySubscriptionResult) -> UIAlertController {
        switch result {
        case .purchased(let expiryDate):
            return alertWithTitle(title: "Product is Purchased", message: "Product is valid until \(expiryDate)")
        case .notPurchased:
            return alertWithTitle(title: "Not purchased", message: "This product has never been purchased")
        case .expired(let expiryDate):
            return alertWithTitle(title: "Product Expired", message: "Product is expired since \(expiryDate)")
        }
    }
    func alertForVerifyPurchase(result : VerifyPurchaseResult) -> UIAlertController {
        switch result {
        case .purchased:
            return alertWithTitle(title: "Product is Purchased", message: "Product will not expire")
        case .notPurchased:
            return alertWithTitle(title: "Product not purchased", message: "Product has never been purchased")
        }
    }
    func alertForRefreshRecepit(result:VerifyReceiptResult) -> UIAlertController {
        switch result {
        case .success(let receiptData):
            return alertWithTitle(title: "Receipt Refreshed", message: "Receipt refreshed successfully")
        case .error(let error):
            return alertWithTitle(title: "Receipt refresh failed", message: "Receipt refresh failed")
        }
    }
}
