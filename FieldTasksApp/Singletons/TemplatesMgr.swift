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
        if let list = CoreDataMgr.shared.fetchTemplates(context: CoreDataMgr.shared.mainThreadContext!) {
            return list
        }
        return [Template]()
    }

    func templatesFromId(idList : [String]) -> [Template]{
        if let list = CoreDataMgr.shared.fetchObjectsWithIds(context: CoreDataMgr.shared.mainThreadContext!, entityName: Template.entityName(), ids: idList) {
            return list as! [Template]
        }
        return [Template]()
    }

    private func removeTemplate(templateId : String) {
        CoreDataMgr.shared.removeObjectById(context: CoreDataMgr.shared.mainThreadContext!, entityName: Template.entityName(), objectId: templateId)
    }

    func deleteTemplate(templateId : String, completion: @escaping (_ error : String?)->()) {
        var index = 0
        for template in self.all() {
            if template.id == templateId {
                ServerMgr.shared.deleteTemplate(templateId: templateId, completion: { (error) in
                    if error == nil {
                        self.removeTemplate(templateId: templateId)
                    }
                    completion(error)
                })
                break
            }
            index += 1
        }
    }

    func updateTemplate(template: Template, completion: @escaping (_ error : String?)->()) {
        if template.id == "" {
            ServerMgr.shared.newTemplate(template: template) { (resultDict, error ) in
                if let resultDict = resultDict as? [String: AnyObject]{
                    // Update with id, and any other changes.
                    template.fromDict(context: CoreDataMgr.shared.mainThreadContext!, templateDict: resultDict)
                    CoreDataMgr.shared.saveOnMainThread()
                }
                completion(error)
            }
        } else {
            ServerMgr.shared.saveTemplate(template: template) { (error ) in
                CoreDataMgr.shared.saveOnMainThread()
                completion(error)
            }
        }
    }
}
