import UIKit

@objc(PhotosResult)
open class PhotosResult: _PhotosResult {
    //private var _photos = [String : UIImage]()
    private var _photos = [UIImage]()
    private let imageDirectoryURL = getImageDirectory()

    override var completed: Bool {
        get {
            return (_photos.count > 0)
        }
    }

    var photos : [UIImage] {
        get {
//            var orderedArray = [UIImage]()
//            for name in file_names! {
//                if let image = _photos[name] {
//                    orderedArray += [image]
//                }
//            }
//            return orderedArray
            return _photos
        }
    }

    var fileNames : [String]? {
        get {
            return file_names
        }
    }

    // MARK: Init Methods -------------------------------------------------------------------------------
    override func fromDict(results: [String : AnyObject]) {
        super.fromDict(results: results)
        file_names = results["fileNames"] as? [String] ?? [String]()
    }

    override func toDict() -> [String : AnyObject]{
        var dict = super.toDict()
        dict["fileNames"] = fileNames as AnyObject?
        return dict
    }

    // MARK: Photo Methods -------------------------------------------------------------------------------
    func add(photo : UIImage) {
        _photos += [photo]
    }

    func set(photo: UIImage, forIndex : Int) {
        FTAssert(isTrue: _photos.count < forIndex, error: "Photo out of index")
        _photos[forIndex] = photo
    }

    func replace(photos: [UIImage]) {
        _photos = photos
    }


    func removeAll() {
        _photos.removeAll()
        file_names?.removeAll()
    }

    // MARK: FileName Methods -------------------------------------------------------------------------------
    func add(fileName: String) {
        file_names! += [fileName]
        saveFile(index: fileNames!.count - 1)
    }

    func set(fileName: String, forIndex : Int) {
        FTAssert(isTrue: file_names!.count < forIndex, error: "File name out of index")
        file_names![forIndex] = fileName
    }


    // MARK: Disk Methods -------------------------------------------------------------------------------
    func saveToDisk() {
         for i in 0..<_photos.count {
            saveFile(index: i)
        }
    }

    func saveFile(index: Int) {
        let photo = _photos[index]
        let fileName = fileNames![index]
        if let data = UIImagePNGRepresentation(photo) {
            let fileURL = imageDirectoryURL.appendingPathComponent(fileName)
            try? data.write(to: fileURL)
        }
    }

    func loadAll() {
        for fileName in file_names! {
            load(fileName: fileName)
        }
    }

    func load(fileName : String) {
        if let image = readFile(name: fileName) {
            self.add(photo: image)
        } else {
            ServerMgr.shared.downloadFile(imageFileName: fileName, completion: { (imageData, errorString) in
                // Lets do UI stuff on main thread.
                DispatchQueue.main.async {
                    if let imData = imageData {
                        if let image = UIImage(data: imData) {
                            self.add(photo: image)
                        }
                    } else {
                        FTAlertError(message: errorString ?? "Unknown error")
                    }
                }
            })
        }
    }


    func readFromDisk() {
        for i in 0..<fileNames!.count {
            if let image = readFile(index: i) {
                _photos += [image]
            } else {
                FTErrorMessage(error: "Could not load Image: \(fileNames![i])")
                _photos += [UIImage(named: "photo.png")!]
            }
        }
        FTAssert(isTrue: _photos.count == fileNames!.count, error: "File names don't match photos")
    }

    func readFile(index: Int) -> UIImage? {
        let fileName = fileNames![index]
        let fileURL = imageDirectoryURL.appendingPathComponent(fileName)
        return UIImage(contentsOfFile: fileURL.path)
    }

    func readFile(name: String) -> UIImage? {
        let fileURL = imageDirectoryURL.appendingPathComponent(name)
        return UIImage(contentsOfFile: fileURL.path)
    }
}
