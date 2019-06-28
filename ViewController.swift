import UIKit
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel(frame: CGRect(x: self.view.bounds.width/2-100, y: self.view.bounds.height/2-50, width: 200, height: 100))
        label.text = "Drag Me"
        label.textAlignment = NSTextAlignment.center
        self.view .addSubview(label)
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(gestureRecognizer:)))
        let gestureTap = UITapGestureRecognizer(target: self, action: #selector(self.wasTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(gesture)
        label.addGestureRecognizer(gestureTap)
    }
    func wasTapped(){
        self.performSegue(withIdentifier: "stretchViewsSegue", sender: self) 
    }
    func wasDragged(gestureRecognizer:UIPanGestureRecognizer){
        let translation = gestureRecognizer.translation(in: view)
        let label = gestureRecognizer.view!
        label.center = CGPoint(x: self.view.bounds.width/2+translation.x, y: self.view.bounds.height/2+translation.y)
        let xFromCenter = label.center.x - self.view.bounds.width/2
        var rotation = CGAffineTransform(rotationAngle: xFromCenter/200)
        let scale = min(abs(100 / xFromCenter), 1)
        var stretchAndRotation = rotation.scaledBy(x: scale, y: scale)
        label.transform = stretchAndRotation
        if gestureRecognizer.state == UIGestureRecognizerState.ended{
            if label.center.x < 100{
                print("not chosen")
            } else if label.center.x > self.view.bounds.width-100{
                print("chosen")
            }
            rotation = CGAffineTransform(rotationAngle: 0)
            stretchAndRotation = rotation.scaledBy(x: 1, y: 1)
            label.transform = stretchAndRotation
            label.center = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height/2 )
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
