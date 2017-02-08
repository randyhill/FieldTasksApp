//
//  TemplatesController
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit

class TemplateCell : UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var tasks: UILabel!
    @IBOutlet weak var body: UILabel!
}

class TemplatesController: UITableViewController {
    var templatesList = [Template]()
    var location : Location?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Templates"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshList))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(goBack))
        makeNavBarFlat()

        self.refreshList()
    }

    func goBack() {
        self.dismiss(animated: true) { 

        }
    }

    func refreshList() {
        // Do any additional setup after loading the view, typically from a nib.
        ServerMgr.shared.loadTemplates(location: location) { (result, error) in
            if error != nil {
                print("Failed to load forms: \(error)")
            } else {
                if let formList = result  {
                    self.templatesList.removeAll()
                    for formObject in formList {
                        if let formDict = formObject as? [String : AnyObject] {
                            self.templatesList += [Template(templateDict: formDict)]
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                 }

            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Table Methods -------------------------------------------------------------------------------
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templatesList.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TemplateCell", for: indexPath as IndexPath)
        if let cell = cell as? TemplateCell {
            let form = templatesList[indexPath.row]
            cell.title!.text = form.name
            cell.tasks!.text = "Tasks: \(form.tasks.count)"
            if form.description.characters.count > 0 {
                cell.body!.text = "Description: \(form.description)"
            } else {
                cell.body!.text = ""
            }
            cell.makeCellFlat()
            cell.title.makeTitleLabel()
            cell.tasks.makeTitleLabel()
            cell.body.makeDetailLabel()
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let formController = self.storyboard?.instantiateViewController(withIdentifier: "TemplateController") as? TemplateController {
            // Create form so it's editable.
            formController.form = Form(template: templatesList[indexPath.row])
            let navController = UINavigationController(rootViewController: formController) // Creating a navigation controller with resultController at the root of the navigation stack.
            self.present(navController, animated: true, completion: {

            })
        }
    }
}

