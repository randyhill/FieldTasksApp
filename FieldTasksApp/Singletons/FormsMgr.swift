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
    private var submissions = [Form]()
    private var unsubmitted = [String: Form]()

    init() {
        // Request access and initial location
        self.refreshList(location: nil) { (forms, error) in
            FTAssertString(error: error)
        }
    }

    func refreshList(location: FTLocation?, completion: @escaping (_ forms: [Form]?, _ error: String?)->(Void)) {
        ServerMgr.shared.loadForms(location: location) { (result, error) in
            FTAssertString(error: error)
            if let formList = result  {
                self.submissions.removeAll()
                for formObject in formList {
                    if let formDict = formObject as? [String : Any] {
                        let newForm = Form()
                        newForm.fromDict(templateDict: formDict)
                        self.submissions += [newForm]
                    }
                }
                self.submissions.sort(by: { (formA, formB) -> Bool in
                    return formA.createDate.compare(formB.createDate) == .orderedDescending
                })
                completion(self.submissions, error)
            }
        }
    }

    func newForm(template: Template) -> Form {
        let newForm = Form()
        newForm.initFromTemplate(template: template)
        unsubmitted[template.id] = newForm
        return newForm
    }

    // Return form if it wasn't submitted
    func formExists(templateId: String) -> Form? {
        return unsubmitted[templateId]
    }

    // Form was successfully submitted, clear it from unsubmitted list
    func formSubmitted(form: Form) {
        unsubmitted[form.templateId] = nil
    }
}
