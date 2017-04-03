//
//  TemplatesMgr
//  FieldTasksApp
//
//  Created by CRH on 2/26/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import Foundation


class TemplatesMgr {
    static let shared = TemplatesMgr()

    func all() -> [Template] {
        if let list = CoreDataMgr.fetchTemplates(context: CoreDataMgr.shared.mainThreadContext!) {
            return list
        }
        return [Template]()
    }

    func templatesFromId(idList : [String]) -> [Template]{
        if let list = CoreDataMgr.fetchObjectsWithIds(context: CoreDataMgr.shared.mainThreadContext!, entityName: Template.entityName(), ids: idList) {
            return list as! [Template]
        }
        return [Template]()
    }

    private func removeTemplate(templateId : String) {
        CoreDataMgr.removeObjectById(context: CoreDataMgr.shared.mainThreadContext!, entityName: Template.entityName(), objectId: templateId)
    }

    func deleteTemplate(templateId : String) {
        var index = 0
        for template in self.all() {
            if template.id == templateId {
                NetworkOpsMgr.shared.deleteTemplate(templateId: templateId)
                self.removeTemplate(templateId: templateId)
                break
            }
            index += 1
        }
    }

    func updateTemplate(template: Template) {
        if template.id == "" {
            // Create new template
            NetworkOpsMgr.shared.newTemplate(template: template)
        } else {
            NetworkOpsMgr.shared.saveTemplate(template: template)
            CoreDataMgr.shared.saveOnMainThread()
        }
    }
}
