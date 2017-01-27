//
//  Globals.swift
//  FieldTasksApp
//
//  Created by CRH on 8/26/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import FlatUIKit
import SVProgressHUD

class Globals {
    static let shared = Globals()
    var utcFormatter = DateFormatter()      // Convert UTC date strings
    var dateFormatter = DateFormatter()     // For visual display
    let smallFont = UIFont.flatFont(ofSize: 13.0)!
    let mediumFont = UIFont.flatFont(ofSize: 16.0)!
    let bigFont = UIFont.boldFlatFont(ofSize: 18.0)!
    let textColor = UIColor.clouds()
    let bgColor = UIColor.greenSea()
    let barColor = UIColor.asbestos()
    let barButtonColor = UIColor.belizeHole()

    init() {
        utcFormatter.locale = Locale(identifier: "en_US_POSIX")
        utcFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        utcFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        UIBarButtonItem.configureFlatButtons(with: barButtonColor, highlightedColor: barButtonColor, cornerRadius: 3.0)
    }
}

extension UIViewController {
//    func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alert.addAction(ok)
//        self.present(alert, animated: true, completion: nil)
//    }

    func configureNavBar() {
        self.navigationController?.navigationBar.configureFlatNavigationBar(with: Globals.shared.barColor)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.clouds(), NSFontAttributeName : Globals.shared.bigFont]
        self.navigationController?.navigationBar.tintColor = UIColor.clouds()
    }
}

extension UITableViewCell {
    func configureDataCell() {
        configureFlatCell(with: UIColor.greenSea(), selectedColor: UIColor.clouds(), roundingCorners: .allCorners)
     }

    func configureHeaderCell() {
        configureFlatCell(with: UIColor.peterRiver(), selectedColor: UIColor.clouds(), roundingCorners: .allCorners)
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

extension UIImage {

    // Fix orientation of images when saved to server.
    func fixOrientation() -> UIImage {

        // No-op if the orientation is already correct
        if ( self.imageOrientation == UIImageOrientation.up ) {
            return self;
        }

        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform: CGAffineTransform = CGAffineTransform.identity

        if ( self.imageOrientation == UIImageOrientation.down || self.imageOrientation == UIImageOrientation.downMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
        }

        if ( self.imageOrientation == UIImageOrientation.left || self.imageOrientation == UIImageOrientation.leftMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
        }

        if ( self.imageOrientation == UIImageOrientation.right || self.imageOrientation == UIImageOrientation.rightMirrored ) {
            transform = transform.translatedBy(x: 0, y: self.size.height);
            transform = transform.rotated(by: CGFloat(-M_PI_2));
        }

        if ( self.imageOrientation == UIImageOrientation.upMirrored || self.imageOrientation == UIImageOrientation.downMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }

        if ( self.imageOrientation == UIImageOrientation.leftMirrored || self.imageOrientation == UIImageOrientation.rightMirrored ) {
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }

        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx: CGContext = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
                                       bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0,
                                       space: self.cgImage!.colorSpace!,
                                       bitmapInfo: self.cgImage!.bitmapInfo.rawValue)!;

        ctx.concatenate(transform)

        if ( self.imageOrientation == UIImageOrientation.left ||
            self.imageOrientation == UIImageOrientation.leftMirrored ||
            self.imageOrientation == UIImageOrientation.right ||
            self.imageOrientation == UIImageOrientation.rightMirrored ) {
            ctx.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.height,height: self.size.width))
        } else {
            ctx.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.width,height: self.size.height))
        }

        // And now we just create a new UIImage from the drawing context and return it
        return UIImage(cgImage: ctx.makeImage()!)
    }
}
