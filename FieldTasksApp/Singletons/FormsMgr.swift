//
//  FormsMgr.swift
//  FieldTasksApp
//                  API to write/read form submissions to CoreData.
//
//  Created by CRH on 3/4/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import Foundation
import CoreData

class FormsMgr {
    static let shared = FormsMgr()

    func all() -> [Form] {
        if let list = CoreDataMgr.fetchForms(context: CoreDataMgr.shared.mainThreadContext!) {
            return list
        }
        return [Form]()
    }

    func submissions() -> [Form] {
        if let list = CoreDataMgr.fetchForms(context: CoreDataMgr.shared.mainThreadContext!) {
            let submissions = list.filter({ (form) -> Bool in
                return form.id != ""
            })
            return submissions
        }
        return [Form]()
    }
    
    func newForm(context: NSManagedObjectContext, template: Template) -> Form {
        let newForm = CoreDataMgr.createForm(context: CoreDataMgr.shared.mainThreadContext!)
        newForm.initFromTemplate(context: context, template: template)
        return newForm
    }

    // Return form for  template if last form wasn't submitted
    func formExists(context: NSManagedObjectContext, templateId: String) -> Form? {
        return CoreDataMgr.fetchUnfinishedFormByTemplateId(context: context, templateId: templateId)
    }
}
