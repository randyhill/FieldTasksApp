//
//  UITableViewCell.swift
//  FieldTasksApp
//
//  Created by CRH on 2/5/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit



extension UITableViewCell {

    func makeCellFlat() {
        configureFlatCell(with: UIColor.greenSea(), selectedColor: UIColor.wetAsphalt(), roundingCorners: .allCorners)
        if let title = self.textLabel {
            title.font = UIFont.boldFlatFont(ofSize: cTitleFontSize)
            title.textColor = UIColor.clouds()
        }
        if let body = self.detailTextLabel {
            body.font = UIFont.flatFont(ofSize: cDetailFontSize)
            body.textColor = UIColor.clouds()
        }
    }

    func makeCellFlat(backgroundColor: UIColor, selectedColor: UIColor) {
        configureFlatCell(with: backgroundColor, selectedColor: selectedColor, roundingCorners: .allCorners)
        if let title = self.textLabel {
            title.font = UIFont.boldFlatFont(ofSize: cTitleFontSize)
            title.textColor = UIColor.clouds()
        }
        if let body = self.detailTextLabel {
            body.font = UIFont.flatFont(ofSize: cDetailFontSize)
            body.textColor = UIColor.clouds()
        }
    }

    func configureHeaderCell() {
        configureFlatCell(with: UIColor.belizeHole(), selectedColor: UIColor.clouds(), roundingCorners: .allCorners)
        cornerRadius = 5.0
    }

    func addSeparator(y: CGFloat, margin: CGFloat, color: UIColor)
    {
        let sepFrame = CGRect(x: margin, y: self.frame.height - y, width: self.frame.width - margin, height: y);
        let seperatorView = UIView(frame: sepFrame);
        seperatorView.backgroundColor = color;
        self.addSubview(seperatorView);
    }
}
