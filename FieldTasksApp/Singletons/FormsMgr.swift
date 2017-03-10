//
//  FormsMgr.swift
//  FieldTasksApp
//
//  Created by CRH on 3/4/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import Foundation

class FormsMgr {
    static let shared = FormsMgr()

    init() {
        // Request access and initial location
        self.refreshList(location: nil) { (forms, error) in
            FTAssertString(error: error)
        }
    }

    func refreshList(location: FTLocation?, completion: @escaping (_ forms: [Form]?, _ error: String?)->(Void)) {
        ServerMgr.shared.loadForms(location: location) { (result, timeStamp, error) in
            FTAssertString(error: error)
            if let formList = result  {
                let error = SyncForms.syncList(newList: formList)
                completion(nil, error)
            }
        }
    }

    func newForm(template: Template) -> Form {
        let newForm = CoreDataMgr.shared.createForm()
        newForm.initFromTemplate(template: template)
        return newForm
    }

    // Return form for  template if last form wasn't submitted
    func formExists(templateId: String) -> Form? {
        return CoreDataMgr.shared.fetchUnfinishedFormByTemplateId(templateId: templateId)
    }
}
