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

    func all() -> [Form] {
        if let list = CoreDataMgr.shared.fetchForms() {
            return list
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
