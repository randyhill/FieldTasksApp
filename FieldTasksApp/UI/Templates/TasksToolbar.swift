//
//  TemplateTasksBar.swift
//  FieldTasksApp
//
//  Created by CRH on 2/27/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

enum TemplateTasksTool : Int {
    case Text = 0, Number, Choices, Photos

    func taskType() -> TaskType {
        switch self {
        case .Text:
            return TaskType.Text
        case .Number:
            return TaskType.Number
        case .Choices:
            return TaskType.Choices
        case .Photos:
            return TaskType.Photos
        }
    }
}

protocol TemplateTasksToolProtocol {
    func addTask(taskType: TaskType)
}

class TemplateTasksToolIcon : UIImageView {
    var delegate : TemplateTasksToolProtocol?
    var taskType : TaskType?

    init(image: UIImage?, tool : TemplateTasksTool, delegate: TemplateTasksToolProtocol) {
        super.init(image: image)

        //        let panRecognizer = UIPanGestureRecognizer(target:self, action: #selector(detectPan))
        //        self.gestureRecognizers = [panRecognizer]
        self.isUserInteractionEnabled = true
        self.taskType = tool.taskType()
        self.delegate = delegate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //    func detectPan(recognizer:UIPanGestureRecognizer) {
    //        let translation  = recognizer.translation(in: self.superview!)
    //        self.center = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
    //        print("pan")
    //    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.superview?.bringSubview(toFront: self)
        self.backgroundColor = UIColor.asbestos()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = UIColor.wetAsphalt()
        if let touch = touches.first {
            let location = touch.location(in: self)
            if let hitView = self.hitTest(location, with: event), hitView == self {
                delegate?.addTask(taskType: self.taskType!)
            }
        }
    }
}

class TasksToolbar : UIView, TemplateTasksToolProtocol {
    var toolViews = [TemplateTasksToolIcon]()
    var toolImages = [UIImage]()
    var delegate : TemplateTasksToolProtocol?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Add icon views
        for toolIndex in TemplateTasksTool.Text.rawValue ... TemplateTasksTool.Photos.rawValue {
            var image : UIImage?
            switch toolIndex {
            case TemplateTasksTool.Text.rawValue: image = UIImage(named: "text.png")
            case TemplateTasksTool.Number.rawValue: image = UIImage(named: "number.png")
            case TemplateTasksTool.Choices.rawValue: image = UIImage(named: "choices.png")
            case TemplateTasksTool.Photos.rawValue: image = UIImage(named: "photo.png")
            default:
                FTErrorMessage(error: "Bad case in TasksToolBar")
            }
            if let image = image {
                let imageView = TemplateTasksToolIcon(image: image, tool: TemplateTasksTool(rawValue: toolIndex)!, delegate: self)
                imageView.contentMode = .center
                imageView.layer.borderColor = UIColor.clouds().cgColor
                imageView.layer.borderWidth = 2.0
                self.toolImages += [image]
                self.toolViews += [imageView]
                self.addSubview(imageView)
            }
        }
        self.backgroundColor = UIColor.wetAsphalt()
        self.isUserInteractionEnabled = true
    }

    func addTask(taskType: TaskType) {
        delegate?.addTask(taskType: taskType)
    }

    override func draw(_ rect: CGRect) {
        self.resizeViews(frame: rect)
        super.draw(rect)
    }

    func resizeViews(frame: CGRect) {
        for i in TemplateTasksTool.Text.rawValue ... TemplateTasksTool.Photos.rawValue {
            let imageView = toolViews[i]
            let width = 1/4 * frame.width - 1
            let offset = CGFloat(i) * (width + 1)
            imageView.frame = CGRect(x: offset, y: 0, width: width, height: frame.height)
        }
    }
}
