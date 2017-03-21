import UIKit

@objc(PhotosResult)
open class PhotosResult: _PhotosResult {
    var photos = [UIImage]()

    override var completed: Bool {
        get {
            return (photos.count > 0)
        }
    }

    override func fromDict(results: [String : AnyObject]) {
        super.fromDict(results: results)
        fileNames = results["fileNames"] as? [String] ?? [String]()
    }

    override func toDict() -> [String : AnyObject]{
        var dict = super.toDict()
        dict["fileNames"] = fileNames as AnyObject?
        return dict
    }
}
