//
//  NewLocationController.swift
//  FieldTasksApp
//
//  Created by CRH on 2/21/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import FlatUIKit
import MapKit
import Contacts

private enum fieldType : Int {
    case name = 0, phone, street, street2, city, state, zip
}

class MyAnnotation : NSObject, MKAnnotation {
    var title : String?
    var subtitle : String?
    var coordinate = CLLocationCoordinate2D()

    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        super.init()
        self.title = title
        self.subtitle = title
        self.coordinate = coordinate
    }

    func mapItem() -> MKMapItem {
        let addressDictionary = [String(CNPostalAddressStreetKey): subtitle]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)

        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
}

class NewLocationController : UIViewController, MKMapViewDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var titles: [UILabel]!
    @IBOutlet var fields: [UITextField]!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var cancelButton: FUIButton!
    @IBOutlet weak var createButton: FUIButton!

    var location = FTLocation()
    var annotation : MyAnnotation?

    // MARK: View Methods -------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Globals.shared.bgColor
        titleLabel.makeTitleStyle()
        for title in titles {
            title.makeDetailStyle()
        }
        for field in fields {
            field.setActiveStyle(isActive: true)
            field.addHideKeyboardButton()
        }
        cancelButton.makeFlatButton()
        createButton.makeFlatButton()
        initMap()

        NotificationCenter.default.addObserver(self, selector: #selector(updateMapFromFields), name: .UITextFieldTextDidEndEditing, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FTAlertMessage(message: "Getting current location")
    }

    // MARK: Map Methods -------------------------------------------------------------------------------
    func initMap() {
        map.delegate = self
        if let clLoc = Locations.shared.currentCLLocation() {
            map.centerCoordinate = clLoc.coordinate
            let span = 0.01
            map.region = MKCoordinateRegion(center: clLoc.coordinate, span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span))
            annotation = MyAnnotation(title: "title", subtitle: "sub title", coordinate: clLoc.coordinate)
            map.addAnnotation(annotation!)
        }
        Locations.shared.currentAddress { (locationDict) in
            self.location.updateFromPlacemarkDict(locationDict: locationDict)
            self.updateFieldsFromLocation(theLocation: self.location)
            FTAlertDismiss {}
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MyAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.isDraggable = true
                view.animatesDrop = true
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            return view
        }
        return nil
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! MyAnnotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == MKAnnotationViewDragState.ending {
            if let newCoord = view.annotation?.coordinate {
                location.coordinates = newCoord
                Locations.shared.coordinatesToAddress(coordinates: newCoord, completion: { (locationDict) in
                    self.location.updateFromPlacemarkDict(locationDict: locationDict)
                    self.updateFieldsFromLocation(theLocation: self.location)
                })
            }
        }
    }

    func updateMapFromFields() {
        updateLocationFromFields()
        location.toCLLocation(completion: { (newLocation) in
            self.location.fromCLLocation(clLoc: newLocation)
            self.annotation?.coordinate = newLocation.coordinate
        })
    }


    // MARK: Fields -------------------------------------------------------------------------------
    func updateFieldsFromLocation(theLocation : FTLocation) {
        self.fields[fieldType.name.rawValue].text = location.name
        self.fields[fieldType.street.rawValue].text = location.street
        self.fields[fieldType.street2.rawValue].text = location.street2
        self.fields[fieldType.city.rawValue].text = location.city
        self.fields[fieldType.state.rawValue].text = location.state
        self.fields[fieldType.zip.rawValue].text = location.zip
        annotation?.title = location.name
        annotation?.subtitle = location.street
        if let coordinate = theLocation.coordinates {
            annotation?.coordinate = coordinate
        }
    }

    func updateLocationFromFields() {
        location.name = self.fields[fieldType.name.rawValue].text ?? ""
        location.street = self.fields[fieldType.street.rawValue].text  ?? ""
        location.street2 = self.fields[fieldType.street2.rawValue].text ?? ""
        location.city = self.fields[fieldType.city.rawValue].text  ?? ""
        location.state = self.fields[fieldType.state.rawValue].text ?? ""
        location.zip = self.fields[fieldType.zip.rawValue].text ?? ""
        annotation?.title = location.name
        annotation?.subtitle = location.street
    }

    // MARK: Actions Methods -------------------------------------------------------------------------------
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true) {

        }
    }

    @IBAction func createAction(_ sender: Any) {

    }
}
