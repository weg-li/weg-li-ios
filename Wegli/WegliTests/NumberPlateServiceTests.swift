@testable import Wegli
import XCTest

class NumberPlateServiceTests: XCTestCase {
    /// Not a real test but it is somewhat testing code
    func testRecognizer1() {
        let sut = NumberPlateRecognizerService.sharedInstance
        
        let images = readImages()
        
        sut.scan(images: images.images) { result in
            switch result {
            case .success(let plates):
                print(plates)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /// Not a real test but it is somewhat testing code
    func testRecognizer2() {
        let sut = NumberPlateRecognizerService.sharedInstance
        
        let images = readImages()
        
        zip(images.images, images.paths).forEach { (image, imagePath) in
            sut.scan(image: image, path: imagePath) { result in
                switch result {
                case .failure(let error):
                    print("WegLi - Recognizer: \(error)")
                case .success(let plates):
                    for plate in plates {
                        print("WegLi - Recognizer: \(plate)")
                    }
                }
            }
        }
    }
    
    private func readImages() -> (images: [UIImage], paths: [String]) {
        let exampleNumbers = ["32"]
        let bundle =  Bundle(for: type(of: self))
        var exampleImagePaths = [String]()
        var exampleImages = [UIImage]()
        for number in exampleNumbers {
            if let imagePath = bundle.path(forResource: number, ofType: "jpg"), let image = UIImage(named: imagePath) {
                
                if let last = imagePath.split(separator: "/").last {
                    exampleImagePaths.append(last.description)
                } else {
                    exampleImagePaths.append(imagePath)
                }
                exampleImages.append(image)
            } else {
                print("Can not find image with \(number).jpg")
            }
        }
        return (exampleImages, exampleImagePaths)
    }
}
