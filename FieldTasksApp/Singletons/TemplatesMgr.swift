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
    private var list = [Template]()
    private var hash = [String: Template]()

    init() {
        // Request access and initial location
        self.refreshList(location: nil) { (templates, error) in
            FTAssertString(error: error)
        }
    }

    func refreshList(location: FTLocation?, completion: @escaping (_ list: [Template]?, _ error: String?)->()) {
        // Do any additional setup after loading the view, typically from a nib.
        ServerMgr.shared.loadTemplates(location: location) { (result, error) in
            if let error = error {
                completion(nil, error)
            } else {
                if let templateList = result  {
                    self.list.removeAll()
                    for template in templateList {
                        if let templateDict = template as? [String : AnyObject] {
                            let template = Template(templateDict: templateDict)
                            self.hash[template.id] = template
                            self.list += [template]
                        }
                    }
                    completion(self.list, nil)
                }
            }
        }
    }

    func templateList() -> [Template] {
        return list
    }

    func templatesFromId(idList : [String]) -> [Template]{
        var templates = [Template]()
        for templateId in idList {
            if let template = hash[templateId] {
                templates += [template]
            } else {
                FTErrorMessage(error: "template with id: \(templateId) missing")
            }
        }
        return templates
    }

    private func removeTemplate(templateId : String) {
        for i in 0 ..< list.count {
            let template = list[i]
            if template.id == templateId {
                list.remove(at: i)
                hash[templateId] = nil
                break
            }
        }
    }

    func deleteTemplate(templateId : String, completion: @escaping (_ error : String?)->()) {
        var index = 0
        for template in list {
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
            list += [template]
            ServerMgr.shared.newTemplate(template: template) { (resultDict, error ) in
                if let resultDict = resultDict as? [String: AnyObject]{
                    // Update with id, and any other changes.
                    template.fromDict(templateDict: resultDict)
                    self.hash[template.id] = template
                }
                completion(error)
            }
        } else {
            ServerMgr.shared.saveTemplate(template: template) { (error ) in
                completion(error)
            }
        }
    }
}
