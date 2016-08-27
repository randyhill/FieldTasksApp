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
    var containerFrame = CGRectZero
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

    override init(controller : UIViewController, container : UIView, task: FormTask) {
        super.init(controller : controller, container: container, task: task)

        // Picture frame
        containerFrame = container.frame
        pictureView.frame = CGRectMake(0, 0, containerFrame.width, containerFrame.height)
        pictureView.layer.borderWidth = 2.0
        container.addSubview(pictureView)

        // Picture button
        pictureButton.frame = CGRectMake(container.frame.width - kButtonSize.width, 0, kButtonSize.width, kButtonSize.height)
        pictureButton.setTitle("Take Picture", forState: .Normal)
        pictureButton.setTitleColor(container.tintColor, forState: .Normal)
        pictureButton.backgroundColor = UIColor.lightGrayColor()
        pictureButton.layer.cornerRadius = 8.0
        pictureButton.userInteractionEnabled = true
        pictureButton.addTarget(self, action: #selector(PhotoTaskHandler.snapIt), forControlEvents: .TouchUpInside)
        container.addSubview(pictureButton)
    }

    @objc func snapIt(sender: UIButton!) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            picker.sourceType = .Camera
        }
        controller?.presentViewController(picker, animated: true, completion: {
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

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
            setPicture(picture)
        }
        picker.dismissViewControllerAnimated(true) {
            print("done")
        }
    }

    // Return nil if data user entered is valid or error message if not
    override func validate() -> String? {
        return nil
    }

    override func save() {
        result.save(self.pictureView.image)
    }
    override func restore() {
        if let picture = result.photo {
            setPicture(picture)
        }
    }
}