import UIKit
import CoreData
protocol StandardCloth {
    var shirt: String { get }
    var shoes: String { get }
    var pants: String { get }
    var belt: String { get }
}
public enum ClothDrawingOrder:Int16{
    case top
    case shoes
    case pants
    case belt
}
struct Designers {
    let multicolorfitting:NSArray = ["multicolorfitting","http://www.ememapps.com/multicolorfitting.html",""]
    let sarah:NSArray = ["Sarah\nMaffeis","https://www.instagram.com/sarahmaffeis/","sarahmaffeis"]
    let nevena:NSArray = ["Nevena\nZizovic","https://www.instagram.com/sphynx_design","sphynx_design"]
    let edita:NSArray = ["Edita\nMauraite","https://www.instagram.com/edita.mauraite/","edita.mauraite"]
}
struct clothPiece {
    var cloth:String
    var drawingOrder:ClothDrawingOrder
    var designer:NSArray
}
class Cloth {
    public var imageView:UIImageView = UIImageView()
    public var image:UIImage = UIImage()
    public var color:UIColor = #colorLiteral(red: 0.8352941176, green: 0.7019607843, blue: 0.5921568627, alpha: 1) 
    public var name:String = ""
    public var gender:Int = 0  
    public var drawingOrder:ClothDrawingOrder = ClothDrawingOrder.top
    func getStandardClothesSetForUI()->[Cloth] {
        let currentGender:String = UserDefaults.standard.string(forKey: "MulticolorFitting.currentGender")!
        if currentGender == "W"{
            return addStandardClothes(clothes: ClothesWomen(), gender: 1)
        }
        else {
            return addStandardClothes(clothes: ClothesMen())
        }
    }
    private func addStandardClothes<T:StandardCloth>(clothes: T, gender:Int = 0) -> [Cloth] {
        let shirt:Cloth = Cloth()
        let belt:Cloth = Cloth()
        let pants:Cloth = Cloth()
        let shoes:Cloth = Cloth()
        var array:[Cloth] = [Cloth]()
        guard let shirtImage = UIImage(named: clothes.shirt) else {
            fatalError("Cannot load standard shirt image")
        }
        shirt.imageView = UIImageView()
        shirt.image = shirtImage
        shirt.name = clothes.shirt
        shirt.drawingOrder = ClothDrawingOrder.top
        shirt.gender = gender
        array.append(shirt)
        guard let shoesImage = UIImage(named: clothes.shoes) else {
            fatalError("Cannot load standard shoes image")
        }
        shoes.imageView = UIImageView()
        shoes.image = shoesImage
        shoes.name = clothes.shoes
        shoes.color = UIColor.white
        shoes.drawingOrder = ClothDrawingOrder.shoes
        shoes.gender = gender
        array.append(shoes)
        guard let pantsImage = UIImage(named: clothes.pants) else {
            fatalError("Cannot load standard pants image")
        }
        pants.imageView = UIImageView()
        pants.image = pantsImage
        pants.name = clothes.pants
        pants.drawingOrder = ClothDrawingOrder.pants
        pants.gender = gender
        array.append(pants)
        guard let beltImage = UIImage(named: clothes.belt) else {
            fatalError("Cannot load standard belt image")
        }
        belt.imageView = UIImageView()
        belt.image = beltImage
        belt.name = clothes.belt
        belt.color = UIColor.white
        belt.drawingOrder = ClothDrawingOrder.belt
        belt.gender = gender
        array.append(belt)
        return array
    }
    func getClothesObjectsForUI(clothesFromStorage:[Clothes])->[Cloth]{
        var clothesForUI:[Cloth] = [Cloth]()
        for cloth in clothesFromStorage {
            guard let clothColor:Data = cloth.color else {
                fatalError("Could not find color for cloth")
            }
            guard let clothImageName = cloth.imageName else {
                fatalError("Could not find image for cloth")
            }
            guard let clothImage = UIImage(named: clothImageName) else {
                fatalError("Could not find image for cloth")
            }
            guard let clothName = cloth.name else {
                fatalError("Could not find name for cloth")
            }
            let clothUI:Cloth = Cloth()
            clothUI.color = NSKeyedUnarchiver.unarchiveObject(with: clothColor) as! (UIColor)
            clothUI.gender = Int(cloth.gender)
            clothUI.image = clothImage
            clothUI.imageView = UIImageView()
            clothUI.name = clothName
            clothUI.drawingOrder = ClothDrawingOrder(rawValue: cloth.drawingOrder)!
            clothesForUI.append(clothUI)
        }
        let sortedArray =  clothesForUI.sorted {
            $0.drawingOrder.rawValue < $1.drawingOrder.rawValue
        }
        return sortedArray
    }    
}
