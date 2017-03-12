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
    var lastSync : Date?
    let cSyncValue = "FormsSync"

    init() {
        // Request access and initial location
        self.lastSync = Globals.getSettingsValue(key: cSyncValue) as? Date ?? Globals.shared.stringToDate(dateString: "2017-01-01")
//        self.refreshList(location: nil) { (forms, error) in
//            FTAssertString(error: error)
//        }
    }

    func syncList(completion: @escaping ( _ error: String?)->(Void)) {
        ServerMgr.shared.syncForms(sinceDate: lastSync!) { (result, timeStamp, error) in
            FTAssert(exists: timeStamp, error: "No time stamp for templates sync")
            FTAssert(exists: result, error: "No result for templates sync")
            FTAssertString(error: error)
            if let formList = result  {
                if let error = SyncForms.syncList(newList: formList) {
                    completion(error)
                } else {
                    self.lastSync = timeStamp
                    Globals.saveSettingsValue(key: self.cSyncValue, value: self.lastSync as AnyObject)
                    completion(nil)
                }
            }
        }
    }

    func all() -> [Form] {
        if let list = CoreDataMgr.shared.fetchObjects(entity: Form.entity(managedObjectContext: CoreDataMgr.shared.context!)!) {
            return list as! [Form]
        }
        return [Form]()
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
