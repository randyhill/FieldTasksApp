//
//  FormListController
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit

class FormListController: UITableViewController {
    var formsList = [Form]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Forms"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(refreshList))

        self.refreshList()
    }

    func refreshList() {
        // Do any additional setup after loading the view, typically from a nib.
        ServerManager.sharedInstance.loadForms { (result, error) in
            if error != nil {
                print("Failed to load forms: \(error)")
            } else {
                if let formList = result  {
                    self.formsList.removeAll()
                    for formObject in formList {
                        if let formDict = formObject as? [String : AnyObject] {
                            self.formsList += [Form(formDict: formDict)]
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                 }

            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Table Methods -------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formsList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FormCell", forIndexPath: indexPath)
        let form = formsList[indexPath.row]
        cell.textLabel!.text = "\(form.name) Tasks: \(form.tasks.count)"
        cell.detailTextLabel!.text = "Description: \(form.description)"
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let formController = self.storyboard?.instantiateViewControllerWithIdentifier("FormController") as? FormController {
            formController.form = formsList[indexPath.row]
            let navController = UINavigationController(rootViewController: formController) // Creating a navigation controller with resultController at the root of the navigation stack.
            self.presentViewController(navController, animated: true, completion: {

            })
        }
    }
}

