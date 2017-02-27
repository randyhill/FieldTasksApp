//
//  TemplateEditorController.swift
//  FieldTasksApp
//
//  Created by CRH on 2/26/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

enum TaskTools : Int {
    case Text = 0, Number, Choices, Photos
}

class TasksToolIcon : UIImageView {
    var lastLocation = CGPoint(x: 0, y: 0)
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }

    override init(image: UIImage?) {
        super.init(image: image)

        let panRecognizer = UIPanGestureRecognizer(target:self, action: #selector(detectPan))
        self.gestureRecognizers = [panRecognizer]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func detectPan(recognizer:UIPanGestureRecognizer) {
        let translation  = recognizer.translation(in: self.superview!)
        self.center = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
        print("pan")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.superview?.bringSubview(toFront: self)
        lastLocation = self.center
        print("touches began")
    }
}

class TasksToolBar : UIView {
    var toolViews = [TasksToolIcon]()
    var toolImages = [UIImage]()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Add icon views
        for i in TaskTools.Text.rawValue ... TaskTools.Photos.rawValue {
            var image : UIImage?
            switch i {
            case TaskTools.Text.rawValue: image = UIImage(named: "text.png")
            case TaskTools.Number.rawValue: image = UIImage(named: "number.png")
            case TaskTools.Choices.rawValue: image = UIImage(named: "choices.png")
            case TaskTools.Photos.rawValue: image = UIImage(named: "photo.png")
            default:
                FTErrorMessage(error: "Bad case in TasksToolBar")
            }
            if let image = image {
                let imageView = TasksToolIcon(image: image)
                imageView.contentMode = .center
                imageView.layer.borderColor = UIColor.clouds().cgColor
                imageView.layer.borderWidth = 2.0
                self.toolImages += [image]
                self.toolViews += [imageView]
                self.addSubview(imageView)
            }
        }
        self.backgroundColor = UIColor.wetAsphalt()
    }

    override func draw(_ rect: CGRect) {
        self.resizeViews(frame: rect)
        super.draw(rect)
    }

    func resizeViews(frame: CGRect) {
        for i in TaskTools.Text.rawValue ... TaskTools.Photos.rawValue {
            let imageView = toolViews[i]
            let width = 1/4 * frame.width - 1
            let offset = CGFloat(i) * (width + 1)
            imageView.frame = CGRect(x: offset, y: 0, width: width, height: frame.height)
        }
    }
}

class TemplateEditorController : UIViewController {
    var listController : TemplateEditorListController?
    var template : Template?
    @IBOutlet weak var toolbar: TasksToolBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let template = template {

        } else {
            self.title = "New Template"
        }
        self.navigationItem.rightBarButtonItem = FlatBarButton(title: "Cancel", target: self, action: #selector(cancelAction))
        self.navigationItem.leftBarButtonItem = FlatBarButton(title: "Done", target: self, action: #selector(doneAction))
        makeNavBarFlat()
        self.view.backgroundColor = UIColor.wetAsphalt()

        // Do any additional setup after loading the view, typically from a nib.
        let halfSizeOfView = 25.0
        let maxViews = 25
        let insetSize = self.view.bounds.insetBy(dx: CGFloat(Int(2 * halfSizeOfView)), dy: CGFloat(Int(2 * halfSizeOfView))).size
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        listController = segue.destination as? TemplateEditorListController
        listController?.parentTemplateEditorController = self
    }

    func cancelAction () {
        self.dismiss(animated: true) { 

        }
    }

    func doneAction () {
        self.dismiss(animated: true) { 

        }

    }
    
}
