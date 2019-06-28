import UIKit
protocol KACircleCropViewControllerDelegate
{
    func circleCropDidCancel()
    func circleCropDidCropImage(_ image: UIImage)
}
class KACircleCropViewController: UIViewController, UIScrollViewDelegate {
    var delegate: KACircleCropViewControllerDelegate?
    var image: UIImage
    let imageView = UIImageView()
    let scrollView = KACircleCropScrollView(frame: CGRect(x: 0, y: 0, width: 240, height: 240))
    let cutterView = KACircleCropCutterView()
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 42))
    let okButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
    let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
    init(withImage image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        scrollView.backgroundColor = UIColor.black
        imageView.image = image
        imageView.frame = CGRect(origin: CGPoint.zero, size: image.size)
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        scrollView.contentSize = image.size
        let scaleWidth = scrollView.frame.size.width / scrollView.contentSize.width
        scrollView.minimumZoomScale = scaleWidth
        if imageView.frame.size.width < scrollView.frame.size.width {
            print("We have the case where the frame is too small")
            scrollView.maximumZoomScale = scaleWidth * 2
        } else {
            scrollView.maximumZoomScale = 1.0
        }
        scrollView.zoomScale = scaleWidth
        scrollView.contentOffset = CGPoint(x: 0, y: (scrollView.contentSize.height - scrollView.frame.size.height)/2)
        cutterView.frame = view.frame
        cutterView.frame.size.height += 100
        cutterView.frame.size.width = cutterView.frame.size.height
        label.text = "Zoom over color"
        label.textAlignment = .center
        label.textColor = UIColor(red: 215/255.0, green: 182/255.0, blue: 154/255.0, alpha: 1.0)
        label.font = label.font.withSize(24)
        label.numberOfLines = 2
        label.minimumScaleFactor  = 0.5
        label.lineBreakMode = .byTruncatingMiddle
        okButton.setTitle("Ok", for: UIControl.State())
        okButton.setTitleColor(UIColor.white, for: UIControl.State())
        okButton.titleLabel?.font = backButton.titleLabel?.font.withSize(17)
        okButton.addTarget(self, action: #selector(didTapOk), for: .touchUpInside)
        backButton.setTitle("<", for: UIControl.State())
        backButton.setTitleColor(UIColor.white, for: UIControl.State())
        backButton.titleLabel?.font = backButton.titleLabel?.font.withSize(30)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        setLabelAndButtonFrames()
        view.addSubview(scrollView)
        view.addSubview(cutterView)
        cutterView.addSubview(label)
        cutterView.addSubview(okButton)
        cutterView.addSubview(backButton)
    }
    func setLabelAndButtonFrames() {
        scrollView.center = view.center
        cutterView.center = view.center
        label.frame.origin = CGPoint(x: cutterView.frame.size.width/2 - label.frame.size.width/2, y: view.frame.origin.y + 144)
        okButton.frame.origin = CGPoint(x: cutterView.frame.size.width/2 + view.frame.size.width/2 - okButton.frame.size.width - 12, y: view.frame.size.height - okButton.frame.size.height)
        backButton.frame.origin = CGPoint(x: cutterView.frame.size.width/2 - view.frame.size.width/2 + 3, y: view.frame.size.height - okButton.frame.size.height)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            self.setLabelAndButtonFrames()
            }) { (UIViewControllerTransitionCoordinatorContext) -> Void in
        }
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    override var prefersStatusBarHidden : Bool {
        return true
    }
    @objc func didTapOk() {
        let newSize = CGSize(width: image.size.width*scrollView.zoomScale, height: image.size.height*scrollView.zoomScale)
        let offset = scrollView.contentOffset
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 240, height: 240), false, 0)
        let circlePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 240, height: 240))
        circlePath.addClip()
        var sharpRect = CGRect(x: -offset.x, y: -offset.y, width: newSize.width, height: newSize.height)
        sharpRect = sharpRect.integral
        image.draw(in: sharpRect)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let imageData = finalImage!.pngData() {
            if let pngImage = UIImage(data: imageData) {
                delegate?.circleCropDidCropImage(pngImage)
            } else {
                delegate?.circleCropDidCancel()
            }
        } else {
            delegate?.circleCropDidCancel()
        }
    }
    @objc func didTapBack() {
        delegate?.circleCropDidCancel()
    }
}
