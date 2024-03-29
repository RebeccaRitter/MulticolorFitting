import Foundation
import StoreKit
import SystemConfiguration
#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif
fileprivate func macOS(_ block: () -> Void) {
    #if os(OSX)
        block()
    #endif
}
fileprivate let secondsInDay  = 86400.0
fileprivate let secondsInWeek = 604800.0
fileprivate let MacAppStoreBundleID = "com.apple.appstore"
fileprivate let AppLookupURLFormat = "https://itunes.apple.com/%@/lookup"
fileprivate let iOSAppStoreURLScheme = "itms-apps"
fileprivate let iOSAppStoreURLFormat = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%i&pageNumber=0&sortOrdering=2&mt=8"
fileprivate let macOsAppStoreURLFormat = "macappstore://itunes.apple.com/app/id%i"
public let JudexUserRated = Notification.Name("JudexUserRated")
public let JudexUserAskedReminder = Notification.Name("JudexUserAskedReminder")
public let JudexUserDeclined = Notification.Name("JudexUserDeclinedNotification")
public let JudexDidOpenAppStore = Notification.Name("JudexDidOpenAppStoreNotification")
public let JudexDidFailToOpenAppStore = Notification.Name("JudexDidFailToOpenAppStoreNotification")
public class Judex {
    public static var shared = Judex()
    var appStoreCountry: String = {
        var countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String
        if countryCode == "150" {
            return "eu"
        } else if countryCode?.lowercased() == "gi" {
            return "gb"
        }
        return countryCode ?? "us"
    }()
    public var applicationName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    public var applicationVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    public var applicationBundleID = Bundle.main.bundleIdentifier ?? ""
    public var promptAtLaunch = true
    public var promptForNewVersion = false
    public var usesUntilPrompt: Double = 10
    public var significantEventsUntilPrompt = 10
    public var daysUntilPrompt: Double = 10
    public var remindPeriod = 3.0
    public var useAvailableLanguages = true
    public private(set) var isAlertOnScreen = false
    public var verbose = false
    var userDefaults = UserDefaults.standard
    fileprivate func setAndSynchronize(_ value: Any?, forKey key: String) {
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    var appStoreId: Int {
        get {
            return userDefaults.integer(forKey: "Judex-AppStore-ID")
        }
        set {
            setAndSynchronize(newValue, forKey: "Judex-AppStore-ID")
        }
    }
    var appStoreGenreId: Int {
        get {
            return userDefaults.integer(forKey: "Judex-AppStore-Genre-ID")
        }
        set {
            setAndSynchronize(newValue, forKey: "Judex-AppStore-Genre-ID")
        }
    }
    var firstUsed: Date? {
        get {
            return userDefaults.object(forKey: "Judex-First-Used") as? Date
        }
        set {
            setAndSynchronize(newValue, forKey: "Judex-First-Used")
        }
    }
    var lastReminder: Date? {
        get {
            return userDefaults.object(forKey: "Judex-Last-Reminder") as? Date
        }
        set {
            setAndSynchronize(newValue, forKey: "Judex-Last-Reminder")
        }
    }
    var usesCount: Int {
        get {
            return userDefaults.integer(forKey: "Judex-Uses-Count")
        }
        set {
            setAndSynchronize(newValue, forKey: "Judex-Uses-Count")
        }
    }
    var eventsCount: Int {
        get {
            return userDefaults.integer(forKey: "Judex-Events-Count")
        }
        set {
            setAndSynchronize(newValue, forKey: "Judex-Events-Count")
        }
    }
    var declinedVersion: String? {
        get {
            return userDefaults.string(forKey: "Judex-Declined-Version")
        }
        set {
            setAndSynchronize(newValue, forKey: "Judex-Declined-Version")
        }
    }
    var declinedThisVersion: Bool {
        get {
            return userDefaults.string(forKey: "Judex-Declined-Version") == applicationVersion
        }
    }
    var declined: Bool {
        get {
            return userDefaults.bool(forKey: "Judex-Declined")
        }
        set {
            setAndSynchronize(newValue, forKey: "Judex-Declined")
        }
    }
    var rated: Bool {
        get {
            return userDefaults.string(forKey: "Judex-Rated-Version") != nil
        }
    }
    var ratedVersion: String? {
        get {
            return userDefaults.string(forKey: "Judex-Rated-Version")
        }
        set {
            setAndSynchronize(newValue, forKey: "Judex-Rated-Version")
        }
    }
    var ratedThisVersion: Bool {
        get {
            return userDefaults.string(forKey: "Judex-Rated-Version") == applicationVersion
        }
    }
    var ratingsUrl: URL? {
        get {
            if appStoreId == 0 { log("Cannot find appStoreId."); return nil }
            var formatUrl = ""
#if os(iOS)
                formatUrl = String(format: iOSAppStoreURLFormat, appStoreId)
#elseif os(OSX)
                formatUrl = String(format: macOsAppStoreURLFormat, appStoreId)
#endif
            return URL(string: formatUrl)
        }
    }
    private var _alertTitle: String? = nil
    public var alertTitle: String {
        get {
            let def = "Rate %@"
            return _alertTitle ?? localizedTextForString(def, default: def).replacingOccurrences(of: "%@", with: applicationName)
        }
        set {
            _alertTitle = newValue
        }
    }
    private var _alertMessage: String? = nil
    public var alertMessage: String {
        get {
            let def = "If you enjoy using %@, would you mind taking a moment to rate it? It won't take more than a minute. Thanks for your support!"
            return _alertMessage ?? localizedTextForString(def, default: def).replacingOccurrences(of: "%@", with: applicationName)
        }
        set {
            _alertMessage = newValue
        }
    }
    private var _alertPositiveButton: String? = nil
    public var alertPositiveButton: String {
        get {
            let def = "Rate %@"
            return _alertPositiveButton ?? localizedTextForString(def, default: def).replacingOccurrences(of: "%@", with: applicationName)
        }
        set {
            _alertPositiveButton = newValue
        }
    }
    private var _alertDeclinedButton: String? = nil
    public var alertDeclinedButton: String {
        get {
            let def = "No, Thanks"
            return _alertDeclinedButton ?? localizedTextForString(def, default: def)
        }
        set {
            _alertDeclinedButton = newValue
        }
    }
    private var _alertRemindButton: String? = nil
    public var alertRemindButton: String {
        get {
            let def = "Remind me later"
            return _alertRemindButton ?? localizedTextForString(def, default: def)
        }
        set {
            _alertRemindButton = newValue
        }
    }
#if os(iOS)
    public var customPrompt: ((_ viewController: UIViewController) -> Void)? = nil
#endif
    init() {
#if os(iOS)
            NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
#endif
        DispatchQueue.main.async(execute: configure)
    }
    public func incrementUsesCounter() {
        usesCount = usesCount + 1
    }
    public func incrementEventsCounter() {
        eventsCount = eventsCount + 1
    }
    open func shouldPrompt() -> Bool {
        if declined {
            log("User declined to rate the app.")
            return false
        }
        if declinedThisVersion {
            log("User declined to rate this current version.")
            return false
        }
        if ratedThisVersion {
            log("User already rated this version.")
            return false
        }
        if rated && promptForNewVersion == false {
            log("User already rated this version and promptForNewVersion is disabled.")
            return false
        }
        let current = Date()
        if current.timeIntervalSince(firstUsed ?? current) < daysUntilPrompt * secondsInDay {
            log("User has used the app less than \(daysUntilPrompt) days.")
            return false
        }
        if current.timeIntervalSince(lastReminder ?? current) < remindPeriod * secondsInDay {
            log("User has rejected to give a review less than \(remindPeriod) days.")
            return false
        }
        return true
    }
    private func check(completion: ((_ success: Bool) -> Void)? = nil) {
        var serviceURLString = String(format: AppLookupURLFormat, appStoreCountry)
        if appStoreId != 0 {
            serviceURLString.append("?id=\(appStoreId)")
        } else {
            serviceURLString.append("?bundleId=\(applicationBundleID)")
        }
        let serviceURL = URL(string: serviceURLString)!
        let task = URLSession.shared.dataTask(with: serviceURL) { (data, response, error) in
            if let e =  error {
                completion?(false)
                self.log("Server returned an error \(e.localizedDescription)")
                return
            }
            if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] {
                    let lookup = json["results"] as! [[String: Any]]
                    let appStoreId = self.extract(key: "trackId", fromLookup: lookup ) as? Int ?? 0
                    let appStoreGenreId = self.extract(key: "primaryGenreId", fromLookup: lookup ) as? Int ?? 0
                    if appStoreId != 0 {
                        self.log("Found app store id: \(appStoreId)")
                    }
                    if appStoreGenreId != 0 {
                        self.log("Found app store genre app id: \(appStoreGenreId)")
                    }
                    self.appStoreId = appStoreId
                    self.appStoreGenreId = appStoreGenreId
                    let latestVersion = self.extract(key: "version", fromLookup: lookup) as? String ?? ""
                    if latestVersion.compare(self.applicationVersion, options: .numeric) == .orderedDescending  {
                        self.log("Found that the current installet app is not the latest version which is \(latestVersion).")
                    }
                } else {
                    completion?(false)
                    self.log("Server returned an invalid response.")
                }
            }
            completion?(true)
        }
        task.resume()
    }
    public func promptIfRequired() {
        if shouldPrompt() {
            DispatchQueue.main.async {
                self.promptForRating()
            }
        }
    }
    public func promptForRating() {
        isAlertOnScreen = true
#if os(iOS)
            var topViewController = UIApplication.shared.delegate!.window!!.rootViewController!
            while topViewController.presentedViewController != nil {
                topViewController = topViewController.presentedViewController!
            }
            if let customPrompt = customPrompt {
                customPrompt(topViewController)
            } else {
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: alertRemindButton, style: .default) { action in
                    self.remindLater()
                })
                alert.addAction(UIAlertAction(title: alertDeclinedButton, style: .default) { action in
                    self.decline()
                })
                alert.addAction(UIAlertAction(title: alertPositiveButton, style: .destructive) { action in
                    self.rate()
                })
                topViewController.present(alert, animated: true)
            }
#elseif os(OSX)
    if onlyPromptIfMainWindowIsAvailable && NSApplication.shared().mainWindow == nil {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.promptForRating()
        }
        return
    }
    let alert = NSAlert()
    alert.messageText = alertTitle
    alert.informativeText = alertMessage
    alert.addButton(withTitle: alertPositiveButton)
    alert.addButton(withTitle: alertRemindButton)
    alert.addButton(withTitle: alertDeclinedButton)
    alert.beginSheetModal(for: NSApplication.shared().mainWindow!) { returnCode in
        let index = returnCode - NSAlertFirstButtonReturn
        switch(index) {
        case 0:
            self.rate()
        case 1:
            self.remindLater()
        default:
            self.decline()
        }
    }
#endif
    }
    public func remindLater() {
        lastReminder = Date()
        declinedVersion = applicationVersion
        NotificationCenter.default.post(name: JudexUserAskedReminder, object: nil)
        isAlertOnScreen = false
    }
    public func decline() {
        declined = true
        NotificationCenter.default.post(name: JudexUserDeclined, object: nil)
        isAlertOnScreen = false
    }
    public func rate() {
        ratedVersion = applicationVersion
        openRatingsInAppStore()
        NotificationCenter.default.post(name: JudexUserRated, object: nil)
        isAlertOnScreen = false
    }
    fileprivate func extract(key: String, fromLookup results: [[String: Any]]) -> Any? {
        if let first = results.first {
            return first[key]
        }
        return nil
    }
    fileprivate func configure() {
        if firstUsed == nil {
            firstUsed = Date()
        }
        incrementUsesCounter()
        check() { completed in
            if completed && self.promptAtLaunch {
                self.promptIfRequired()
            }
        }
    }
#if os(iOS)
    @objc func applicationWillEnterForeground(not: Notification) {
        guard UIApplication.shared.applicationState == .background else { return }
        incrementUsesCounter()
        check()
        if (self.promptAtLaunch) {
            self.promptIfRequired()
        }
    }
    func openRatingsInAppStore() {
        guard let ratingsUrl = ratingsUrl else {
            self.log("Ratings url is invalid, could not open the page.")
            return
        }
        guard UIApplication.shared.canOpenURL(ratingsUrl) == true else {
            self.log("Ratings page cannot be opened, are you in the simulator? If yes, please ignore this message.")
            return
        }
        self.log("Raings page will be opened using: \(ratingsUrl)")
        if #available(iOS 10, *) {
            UIApplication.shared.open(ratingsUrl, options: [:]) { completed in
                if completed {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: JudexDidOpenAppStore, object: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: JudexDidFailToOpenAppStore, object: nil)
                    }
                }
            }
        } else {
            UIApplication.shared.openURL(ratingsUrl)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: JudexDidOpenAppStore, object: nil)
            }
        }
    }
#endif
#if os(OSX)
    var onlyPromptIfMainWindowIsAvailable: Bool = true
    func openRatingsInAppStore() {
        guard let ratingsUrl = ratingsUrl else {
            self.log("Ratings url is invalid, could not open the page.")
            return
        }
        self.log("Raings page will be opened using: \(ratingsUrl)")
        NSWorkspace.shared().open(ratingsUrl)
        openAppPageWhenAppStoreLaunched()
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: JudexDidOpenAppStore, object: nil)
        }
    }
    func openAppPageWhenAppStoreLaunched() {
        guard let ratingsUrl = ratingsUrl else {
            self.log("Ratings url is invalid, could not open the page.")
            return
        }
        for app in NSWorkspace.shared().runningApplications {
            if app.bundleIdentifier == MacAppStoreBundleID {
                NSWorkspace.shared().perform(#selector(NSWorkspace.open(_:)), with: ratingsUrl, afterDelay: 2.5)
                return
            }
        }
        openAppPageWhenAppStoreLaunched()
    }
#endif
    fileprivate func log(_ message: String) {
        if verbose {
            print("[Judex] \(message)")
        }
    }
    private var bundle: Bundle? = nil
    fileprivate func localizedTextForString(_ key: String, default fallback: String) -> String {
        if bundle == nil {
            var bundlePath = Bundle(for: Judex.self).path(forResource: "Judex", ofType: "bundle") ?? ""
            if useAvailableLanguages {
                bundle = Bundle(path: bundlePath)
                var language = Locale.preferredLanguages.first ?? "en"
                if bundle?.localizations.contains(language) ?? false {
                    bundlePath = bundle?.path(forResource: language, ofType: "lproj") ?? ""
                }
                language = language.components(separatedBy: "-").first!
                if bundle?.localizations.contains(language) ?? false {
                    bundlePath = bundle?.path(forResource: language, ofType: "lproj") ?? ""
                }
            }
            bundle = Bundle(path: bundlePath) ?? Bundle.main
        }
        let translated = bundle?.localizedString(forKey: key, value: fallback, table: nil)
        return Bundle.main.localizedString(forKey: key, value: translated, table: nil)
    }
}
