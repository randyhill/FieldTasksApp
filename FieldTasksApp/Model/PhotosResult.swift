import UIKit

// Filenames are an array that maps to an array of corresponding Images. Display order is the array order
// Images are empty if not created yet, or not loaded from disk/server
// This class maps from file names or indexes to images, returning nil if images aren't loaded yet.
private class PhotosResultMap {
    private var photos = [UIImage]()
    private var nameMap = [String: UIImage?]()

    // MARK: Access -------------------------------------------------------------------------------
    func count() -> Int {
        return photos.count
    }

    func at(index: Int) -> UIImage? {
        return photos[index]
    }

    func named(name: String) -> UIImage? {
        //  values returned as UIImage??, so special case
        let image = nameMap[name]
        if image == nil {
            return nil
        }
        return image!
    }

    func removeAll() {
         photos = [UIImage]()
        nameMap = [String : UIImage?]()
    }

    // MARK: Images -------------------------------------------------------------------------------
    // If fileName already exists, replace image
    func set(image: UIImage, fileName: String) {
        if nameMap[fileName] == nil {
            photos += [image]
        }
        nameMap[fileName] = image
    }

    func remove(atIndex: Int, forName: String) {
        photos.remove(at: atIndex)
        nameMap[forName] = nil
     }
}

@objc(PhotosResult)
open class PhotosResult: _PhotosResult {
    private var photosMap = PhotosResultMap()
    private let imageDirectoryURL = getImageDirectory()

    override var completed: Bool {
        get {
            return self.count() > 0
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
    func add(photo : UIImage, fileName: String) {
        self.set(photo: photo, fileName: fileName)
        file_names! += [fileName]
    }

    func set(photo : UIImage, fileName: String) {
        if self.photoToFile(fileName: fileName, photo: photo) {
            photosMap.set(image: photo, fileName: fileName)
        }
    }

    func at(index: Int) -> UIImage? {
        return photosMap.at(index: index)
    }

    func remove(index: Int) {
        let fileName = file_names![index]
        photosMap.remove(atIndex: index, forName: fileName)
        file_names!.remove(at: index)
    }

    func removeAll() {
        file_names?.removeAll()
        photosMap.removeAll()
    }

    func count() -> Int {
        return photosMap.count()
    }

    // MARK: FileName Methods -------------------------------------------------------------------------------

    private func photoToFile(fileName : String, photo : UIImage) -> Bool {
        if let data = UIImagePNGRepresentation(photo) {
            let fileURL = imageDirectoryURL.appendingPathComponent(fileName)
            do {
                try data.write(to: fileURL)
            } catch {
                FTErrorMessage(error: "Could not write image: \(error)")
                return false
            }
        }
        return true
    }

    private func photoFromFile(name: String) -> UIImage? {
        let fileURL = imageDirectoryURL.appendingPathComponent(name)
        return UIImage(contentsOfFile: fileURL.path)
    }

    func loadAll(progress: @escaping (_ progress: Float)->(), imageLoaded: @escaping (_ image: UIImage)->()) {
        var downloads = [String]()
        for fileName in file_names! {
            if let image = photosMap.named(name: fileName) {
                imageLoaded(image)
            }
            else if let image = photoFromFile(name: fileName) {
                photosMap.set(image: image, fileName: fileName)
                imageLoaded(image)
            } else {
                downloads += [fileName]
            }
        }
        if downloads.count > 0 {
            NetworkOpsMgr.shared.downloadImages(fileNames: downloads, photosResult: self, progress: progress, imageLoaded: imageLoaded)
        }
    }

    // Photo is either loaded, or can be loaded from disc, or needs to be loaded from server
//     private func loadImage(fileName : String, progress: @escaping (_ progress: Float)->(), imageLoaded: @escaping (_ image: UIImage)->()) {
//        if let image = photosMap.named(name: fileName) {
//           imageLoaded(image)
//        }
//        else if let image = photoFromFile(name: fileName) {
//            photosMap.set(image: image, fileName: fileName)
//            imageLoaded(image)
//        } else {
//            NetworkOpsMgr.shared.downloadImage(fileName: fileName, photosResult: self, progress: progress, imageLoaded: imageLoaded)
//        }
//    }
}
