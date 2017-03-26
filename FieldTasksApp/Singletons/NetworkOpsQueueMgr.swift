//
//  NetworkOpsQueueMgr.swift
//  FieldTasksApp
//
//  Created by CRH on 3/25/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import Foundation

class NetworkOpQueueMgr {
    static let shared = NetworkOpQueueMgr()
    let queue = DispatchQueue(label: "com.fieldtasks.networkqueue")

    func submitForm(form : Form, photoFileList: PhotoFileList) {
        queue.async {
            // upload Photos to server first.
            ServerMgr.shared.uploadImagesWithoutUI(photoFileList: photoFileList, completion: { (photoFileList, error) in
                if let _ = photoFileList {
                    // Photo file names should have been copied to photo tasks, we can submit form now
                    form.submitForm(completion: { (error) in
                        if let error = error {
                            FTErrorMessage(error: "Error submitting form: \(error)")
                        } else {
                            // Form's object id should be updated from server, write object back to server.
                            FTErrorMessage(error: "Form submitted successfully")
                            let backgroundContext = CoreDataMgr.shared.getNewContext()
                            backgroundContext.perform({
                                CoreDataMgr.shared.saveInContext(context: backgroundContext)
                            })
                        }
                    })
                } else {
                    FTErrorMessage(error:"Photos upload failed because of: \(error!)")
                }
            })
        }
    }
}
