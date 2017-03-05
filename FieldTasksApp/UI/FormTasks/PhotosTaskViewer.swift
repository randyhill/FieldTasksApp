//
//  PhotosTaskViewer
//  FieldTasksApp
//
//  Created by CRH on 8/23/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

class PhotoCell : UICollectionViewCell {
    var delegate: PhotosTaskViewer?
    var image : UIImage?
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    @IBAction func closeTapped(_ sender: Any) {
        delegate?.removePicture(deleteImage: image!)
    }
}

class PhotosHeader : UICollectionReusableView {
    var delegate: PhotosTaskViewer?
    @IBOutlet weak var addButton: FUIButton!
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var cameraButton: FUIButton!

    @IBAction func cameraTapped(_ sender: UIButton) {
        if let controller = delegate {
            controller.snapIt(sender: sender)
        }
    }
    @IBAction func tapped(_ sender: UIButton) {
        if let controller = delegate {
            controller.pickIt(sender: sender)
        }
    }

}

class PhotosTaskViewer : BaseTaskViewer, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = self.view.backgroundColor
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.collectionView.reloadData()
    }

    func setPicture(picture : UIImage) {
        let data = photoData
        if data.isSingle {
            self.result.photos = [picture]
        } else {
            self.result.photos += [picture]
            self.scrollToBottomAnimated(animated: true)
        }
        self.collectionView.reloadData()
    }

    func removePicture(deleteImage : UIImage) {
        var newImages = [UIImage] ()
        for image in result.photos {
            if image !== deleteImage {
                newImages += [image]
            }
        }
        result.photos = newImages
        collectionView.reloadData()
    }

    // Return nil if data user entered is valid or error message if not
    override func validate() -> String? {
        if (result.photos.count == 0) {
            return "No photo selected/taken"
        }
        return nil
    }

    override func save() {
    }

    override func restore() {
        if result.photos.count > 0 {
            self.collectionView.reloadData()
        } else {
            for fileName in result.fileNames {
                ServerMgr.shared.downloadFile(imageFileName: fileName, completion: { (imageData, errorString) in
                    // Lets do UI stuff on main thread.
                    DispatchQueue.main.async {
                        if let imData = imageData {
                            if let image = UIImage(data: imData) {
                                self.setPicture(picture: image)
                            }
                        } else {
                            FTAlertError(message: errorString ?? "Unknown error")
                        }
                    }
                })
            }
        }
    }

    var photoData : PhotosTask {
        get {
            return task as! PhotosTask
        }
    }
    var result : PhotosResult {
        get {
            return task!.result as! PhotosResult
        }
    }

    @objc func snapIt(sender: UIButton!) {
        getImage(sourceType: .camera)
    }
    @objc func pickIt(sender: UIButton!) {
        getImage(sourceType: .photoLibrary)
    }

    func getImage(sourceType : UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.makeNavBarFlat()
        picker.sourceType = sourceType

        // Hack to work around different text color for picker buttons. FlatUIKit's color specific nav bar buttons can't be called from Swift.
        // So I just change them globally before picker is displayed and restore after
        UINavigationBar.appearance().barTintColor = Globals.shared.barColor
        UINavigationBar.appearance().barStyle = UIBarStyle.default
        UINavigationBar.appearance().tintColor = UIColor.clouds()   // Text color
        self.present(picker, animated: true, completion: {
            // Restore
            UIBarButtonItem.configureFlatButtons(with: Globals.shared.barButtonColor, highlightedColor: Globals.shared.barButtonColor, cornerRadius: 3.0)
        })
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
            setPicture(picture: picture)
        }
        picker.dismiss(animated: true) {

        }
    }

    // MARK: Collection Methods -------------------------------------------------------------------------------
    func scrollToBottomAnimated(animated: Bool) {
        guard self.collectionView.numberOfSections > 0 else{
            return
        }

        let items = self.collectionView.numberOfItems(inSection: 0)
        if items == 0 { return }

        let collectionViewContentHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height
        let isContentTooSmall: Bool = (collectionViewContentHeight < self.collectionView.bounds.size.height)

        if isContentTooSmall {
            self.collectionView.scrollRectToVisible(CGRect(x: 0, y: collectionViewContentHeight - 1, width: 1, height: 1), animated: animated)
            return
        }

        self.collectionView.scrollToItem(at: NSIndexPath(item: items - 1, section: 0) as IndexPath, at: .bottom, animated: animated)
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // The first cell always start expanded with an height of 300
        return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.width)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return result.photos.count
    }

    // Header
    func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "PhotosHeader",
                                                                             for: indexPath) as! PhotosHeader
            let data = photoData
            headerView.delegate = self
            headerView.backgroundColor = Globals.shared.barColor
            headerView.addButton.makeFlatButton()
            headerView.addButton.setTitle(data.isSingle ? "Set Image" : "Add Image", for: .normal)
            headerView.addButton.isHidden = !isEditable
            headerView.cameraButton.makeFlatButton()
            headerView.cameraButton.isHidden = !UIImagePickerController.isSourceTypeAvailable(.camera)
            headerView.headerText.makeTitleStyle()
            headerView.headerText.text = "Images: \(result.photos.count)"
            headerView.headerText.isHidden = data.isSingle
            return headerView
        default:
            //4
            assert(false, "Unexpected element kind")
        }
    }

    // Cell
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell",
                                                      for: indexPath)
        if let cell = cell as? PhotoCell {
            // Configure the cell
            let image = result.photos[indexPath.row]
            cell.imageView.image = image
            cell.delegate = self
            cell.image = image
            cell.closeButton.layer.cornerRadius = 16.0
            cell.closeButton.isHidden = !isEditable
        }
        return cell

    }
}
