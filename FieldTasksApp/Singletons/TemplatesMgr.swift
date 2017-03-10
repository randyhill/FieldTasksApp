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
    let cSyncValue = "TemplatsSync"

    init() {
        self.lastSync = Globals.getSettingsValue(key: cSyncValue) as? Date ?? Globals.shared.stringToDate(dateString: "2017-01-01")
        self.syncList(completion: { (error) in
            FTAssertString(error: error)
        })
    }

//    func refreshList(location: FTLocation?, completion: @escaping (_ list: [Template]?, _ error: String?)->()) {
//        // Do any additional setup after loading the view, typically from a nib.
//        ServerMgr.shared.loadTemplates( location: location) { (result, timeStamp, error) in
//            if let error = error {
//                completion(nil, error)
//            } else {
//                if let templateList = result  {
//                    let error = SyncTemplates.syncList(newList: templateList)
//                    completion(self.all(), error)
//                }
//            }
//        }
//    }

    func syncList(completion: @escaping ( _ error: String?)->()) {
        // Do any additional setup after loading the view, typically from a nib.
        ServerMgr.shared.syncTemplates(sinceDate: self.lastSync!) { (result, timeStamp, error) in
            if let error = error {
                completion(error)
            } else {
                if let templateList = result  {
                    let error = SyncTemplates.syncList(newList: templateList)
                    completion(error)
                }
            }
        }
    }

    func all() -> [Template] {
        if let list = CoreDataMgr.shared.fetchObjects(entityName: Template.entityName()) {
            return list as! [Template]
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
//                    self.hash[template.id!] = template
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
