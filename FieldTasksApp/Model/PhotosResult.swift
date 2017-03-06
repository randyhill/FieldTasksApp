import UIKit

@objc(PhotosResult)
open class PhotosResult: _PhotosResult {
    var fileNames = [String]()
    var photos = [UIImage]()

    override var completed: Bool {
        get {
            return (photos.count > 0)
        }
    }

//    override init(task : Task, results: [String : AnyObject]) {
//        super.init(task: task, results: results)
//        if let fileNames = results["fileNames"] as? [String] {
//            self.fileNames = fileNames
//        }
//    }

    override func toDict() -> [String : AnyObject]{
        var dict = super.toDict()
        dict["fileNames"] = fileNames as AnyObject?
        return dict
    }
}
