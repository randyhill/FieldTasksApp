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
    var lastSync : Date?
    let cSyncValue = "TemplatesSync"

    init() {
        self.lastSync = Globals.getSettingsValue(key: cSyncValue) as? Date ?? Globals.shared.stringToDate(dateString: "2017-01-01")
    }

    func syncList(completion: @escaping ( _ error: String?)->()) {
        // Do any additional setup after loading the view, typically from a nib.
        ServerMgr.shared.syncTemplates(sinceDate: self.lastSync!) { (result, timeStamp, error) in
            FTAssert(exists: timeStamp, error: "No time stamp for templates sync")
            FTAssert(exists: result, error: "No result for templates sync")
            if let error = error {
                completion(error)
            } else {
                 if let templateList = result  {
                    if let error = SyncTemplates.syncList(newList: templateList) {
                        completion(error)
                    }
                    self.lastSync = timeStamp
                    Globals.saveSettingsValue(key: self.cSyncValue, value: timeStamp as AnyObject)
                    completion(nil)
                }
            }
        }
    }

    func all() -> [Template] {
        if let list = CoreDataMgr.shared.fetchTemplates() {
            return list
        }
        return [Template]()
    }

    func templatesFromId(idList : [String]) -> [Template]{
        if let list = CoreDataMgr.shared.fetchObjectsWithIds(entityName: Template.entityName(), ids: idList) {
            return list as! [Template]
        }
        return [Template]()
    }

    private func removeTemplate(templateId : String) {
        CoreDataMgr.shared.removeObjectById(entityName: Template.entityName(), objectId: templateId)
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
                    template.fromDict(templateDict: resultDict)
                    CoreDataMgr.shared.save()
                }
                completion(error)
            }
        } else {
            ServerMgr.shared.saveTemplate(template: template) { (error ) in
                CoreDataMgr.shared.save()
                completion(error)
            }
        }
    }
}
