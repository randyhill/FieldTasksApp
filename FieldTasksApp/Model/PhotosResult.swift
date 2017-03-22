import UIKit

// Filenames are an array that maps to an array of corresponding Images. Display order is the array order
// Filenames are empty if images haven't been saved to server. Images are empty if not created yet, or not loaded from disk/server
// This class maps from file names or indexes to images, returning nil if images aren't loaded yet.
private class PhotosResultMap {
    private var indexMap = [Int : UIImage]()
    private var nameMap = [String: UIImage?]()

    // MARK: Access -------------------------------------------------------------------------------
    func count() -> Int {
        return indexMap.count
    }

    func at(index: Int) -> UIImage? {
        return indexMap[index]
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
        indexMap = [Int : UIImage]()
        nameMap = [String : UIImage?]()
    }

    // MARK: Images -------------------------------------------------------------------------------
    func add(image: UIImage, fileName: String?) {
        let newIndex = indexMap.count
        indexMap[newIndex] = image
        if let fileName = fileName {
            nameMap[fileName] = image
        }
    }

    func set(image: UIImage, forIndex: Int) {
         indexMap[forIndex] = image
    }

    func remove(atIndex: Int) {
        indexMap[atIndex] = nil
    }

    func remove(image: UIImage) {
        // Get images out in index order, without the removed image
        var newArray = [UIImage]()
        for i in 0..<indexMap.count {
            if let value = indexMap[i] {
                if value !== image {
                    newArray += [value]
                }
            }
        }
        // rebuild index map with new images in array order
        indexMap = [Int : UIImage]()
        for i in 0..<newArray.count {
            indexMap[i] = newArray[i]
        }
    }

    // MARK: Filenames -------------------------------------------------------------------------------
    // Add new filename and link to corresponding image if it exists.
    func add(fileName: String) {
        let newIndex = indexMap.count

        // Use updateValue, as nameMap[x] = nil doesn't assign nil, it removes key
        nameMap.updateValue(indexMap[newIndex], forKey: fileName)
    }

    func add(fileName: String, toIndex: Int) {
        nameMap.updateValue(indexMap[toIndex], forKey: fileName)
    }

    func remove(forName: String) {
        nameMap[forName] = nil
    }
}

@objc(PhotosResult)
open class PhotosResult: _PhotosResult {
    private var photosMap = PhotosResultMap()
    private let imageDirectoryURL = getImageDirectory()

    override var completed: Bool {
        get {
            return (photosMap.count() > 0)
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
        photosMap.add(image: photo, fileName: nil)
    }

    func set(photo: UIImage, forIndex : Int) {
        photosMap.set(image: photo, forIndex: forIndex)
    }

    func at(index: Int) -> UIImage? {
        return photosMap.at(index: index)
    }

    func remove(photo: UIImage) {
        photosMap.remove(image: photo)
    }

    func removeAll() {
        file_names?.removeAll()
        photosMap.removeAll()
    }

    func count() -> Int {
        return photosMap.count()
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

    private func saveFile(index: Int) {
        if let photo = photosMap.at(index: index)  {
            let fileName = fileNames![index]
            self.photoToFile(fileName: fileName, photo: photo)
        }
    }

    private func photoToFile(fileName : String, photo : UIImage) {
        if let data = UIImagePNGRepresentation(photo) {
            let fileURL = imageDirectoryURL.appendingPathComponent(fileName)
            do {
                try data.write(to: fileURL)
            } catch {
                FTErrorMessage(error: "Could not write image: \(error)")
            }
        }
    }

    private func photoFromFile(name: String) -> UIImage? {
        let fileURL = imageDirectoryURL.appendingPathComponent(name)
        return UIImage(contentsOfFile: fileURL.path)
    }

    func loadAll(imageLoaded: @escaping (_ image: UIImage)->()) {
        for fileName in file_names! {
            loadFile(fileName: fileName, imageLoaded : imageLoaded)
        }
    }

    // Photo is either loaded, or can be loaded from disc, or needs to be loaded from server
     private func loadFile(fileName : String, imageLoaded: @escaping (_ image: UIImage)->()) {
        if let image = photosMap.named(name: fileName) {
           imageLoaded(image)
        }
        else if let image = photoFromFile(name: fileName) {
            photosMap.add(image: image, fileName: fileName)
            imageLoaded(image)
        } else {
            ServerMgr.shared.downloadFile(imageFileName: fileName, completion: { (imageData, errorString) in
                // Lets do UI stuff on main thread.
                DispatchQueue.main.async {
                    if let imData = imageData {
                        if let image = UIImage(data: imData) {
                            self.photosMap.add(image: image, fileName: fileName)
                            self.photoToFile(fileName: fileName, photo: image)
                            imageLoaded(image)
                        }
                    } else {
                        FTAlertError(message: errorString ?? "Unknown error")
                    }
                }
            })
        }
    }
}
