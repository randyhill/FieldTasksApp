//
//  PhotoTaskHandler.swift
//  FieldTasksApp
//
//  Created by CRH on 8/23/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit

class PhotoTaskHandler : TaskHandler, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var pictureButton = UIButton()
    var pictureView = UIImageView()
    var containerFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
    var photoData : PhotoTaskDescription {
        get {
            return task!.taskDescription as! PhotoTaskDescription
        }
    }
    var result : PhotoResult {
        get {
            return task!.result as! PhotoResult
        }
    }
    let kButtonSize = CGSize(width: 120.0, height: 34.0)

    override init(controller : TaskController, container : UIView, task: FormTask, isEditable: Bool) {
        super.init(controller : controller, container: container, task: task, isEditable: isEditable)

        // Picture frame
        containerFrame = container.frame
        pictureView.frame = CGRect(x: 0, y: 0, width: containerFrame.width, height: containerFrame.height)
        pictureView.layer.borderWidth = 2.0
        container.addSubview(pictureView)

        // Picture button
        if isEditable {
            pictureButton.frame = CGRect(x: container.frame.width - kButtonSize.width, y: 0, width: kButtonSize.width, height: kButtonSize.height)
            pictureButton.setTitle("Take Picture", for: .normal)
            pictureButton.setTitleColor(container.tintColor, for: .normal)
            pictureButton.backgroundColor = UIColor.lightGray
            pictureButton.layer.cornerRadius = 8.0
            pictureButton.isUserInteractionEnabled = true
            pictureButton.addTarget(self, action: #selector(PhotoTaskHandler.snapIt), for: .touchUpInside)
            container.addSubview(pictureButton)
        }
    }

    @objc func snapIt(sender: UIButton!) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        }
        controller?.present(picker, animated: true, completion: {
            print("done")
        })
    }

    func setPicture(picture : UIImage) {
        pictureView.image = picture
        let picProportion = picture.size.height/picture.size.width
        if picProportion < 1.0 {
            let newHeight = containerFrame.height * picProportion
            pictureView.frame.size.height = newHeight
            pictureView.frame.origin.y = (containerFrame.height - newHeight)/2
        } else {
            let newWidth = containerFrame.width / picProportion
            pictureView.frame.size.width = newWidth
            pictureView.frame.origin.x = (containerFrame.width - newWidth)/2
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
            setPicture(picture: picture)
        }
        picker.dismiss(animated: true) {
            print("done")
        }
    }

    // Return nil if data user entered is valid or error message if not
    override func validate() -> String? {
        return nil
    }

    override func save() {
        result.save(newPhoto: self.pictureView.image)
    }
    override func restore() {
        if let picture = result.photo {
            setPicture(picture: picture)
        }
    }
}
