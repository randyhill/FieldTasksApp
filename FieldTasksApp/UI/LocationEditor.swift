//
//  LocationEditor.swift
//  FieldTasksApp
//
//  Created by CRH on 2/21/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import FlatUIKit
import MapKit
import Contacts

private enum FieldType : Int {
    case name = 0, phone, street, city, state, zip, perimeter
}

let cMinPerimeter = 40
let cMaxPerimeter = 400

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
    let addressDictionary = [String(CNPostalAddressStreetKey) : subtitle ?? ""]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)

        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
}

class LocationEditor : UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var titles: [UILabel]!
    @IBOutlet var fields: [UITextField]!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var cancelButton: FUIButton!
    @IBOutlet weak var createButton: FUIButton!
    @IBOutlet weak var perimeterSlider: UISlider!
    var location = FTLocation()
    var annotation : MyAnnotation?
    var perimeter : MKCircle?

     // MARK: View Methods -------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Globals.shared.bgColor
        titleLabel.makeTitleStyle()
        for title in titles {
            title.makeDetailStyle()
        }
        var tagNumber = 0
        for field in fields {
            field.setActiveStyle(isActive: true)
            field.addHideKeyboardButton()
            field.delegate = self
            field.tag = tagNumber
            tagNumber += 1
        }
        cancelButton.makeFlatButton()
        createButton.makeFlatButton()
        initMap()
        perimeterSlider.configureFlatSlider(withTrackColor: UIColor.silver(), progressColor: UIColor.peterRiver(), thumbColor: UIColor.clouds())
        perimeterSlider.minimumValue = Float(cMinPerimeter)
        perimeterSlider.maximumValue = Float(cMaxPerimeter)
        updatePerimeterText(meters: Int(perimeterSlider.value))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FTAlertMessage(message: "Getting current location")
    }

    // MARK: Map Methods -------------------------------------------------------------------------------
    func initMap() {
        map.delegate = self
        if let clLoc = LocationsManager.shared.currentCLLocation() {
            let span = 0.01
            map.centerCoordinate = clLoc.coordinate
            map.region = MKCoordinateRegion(center: clLoc.coordinate, span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span))
            annotation = MyAnnotation(title: "title", subtitle: "sub title", coordinate: clLoc.coordinate)
            updateAnnotationLocation(coordinate: clLoc.coordinate)
            updatePerimeterOverlay(coordinate: clLoc.coordinate, radius: CLLocationDistance(perimeterSlider.value))
        }
        LocationsManager.shared.currentAddress { (locationDict) in
            self.location.updateFromPlacemarkDict(locationDict: locationDict)
            self.updateFieldsFromLocation(theLocation: self.location)
            FTAlertDismiss {}
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MyAnnotation {
            let identifier = "pin"
            var pinView: MKPinAnnotationView?
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                pinView = dequeuedView
            } else {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                pinView?.isDraggable = true
                pinView?.animatesDrop = true
            }
            return pinView
        }
        return nil
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(circle: overlay as! MKCircle)
        circleRenderer.strokeColor = UIColor.peterRiver()
        circleRenderer.lineWidth = 1.0
        return circleRenderer
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! MyAnnotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState,
                 fromOldState oldState: MKAnnotationViewDragState) {
        if newState == MKAnnotationViewDragState.ending {
            if let newCoord = view.annotation?.coordinate {
                location.coordinates = newCoord
                LocationsManager.shared.coordinatesToAddress(coordinates: newCoord, completion: { (locationDict) in
                    self.location.updateFromPlacemarkDict(locationDict: locationDict)
                    self.updateFieldsFromLocation(theLocation: self.location)
                })
            }
        }
    }

    func updateMapFromFields() {
        updateLocationFromFields(theLocation: location)
//        updateOverlaysFromLocation(theLocation: location)
        location.toCLLocation(completion: { (newLocation) in
            self.location.fromCLLocation(clLoc: newLocation)
            self.updateAnnotationLocation(coordinate: newLocation.coordinate)
            self.updatePerimeterOverlay(coordinate: newLocation.coordinate, radius: CLLocationDistance(self.perimeterSlider.value))
        })
    }

    // MARK: Fields -------------------------------------------------------------------------------
    func textFieldDidEndEditing(_ textField: UITextField) // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or 
    {
        if let type = FieldType(rawValue: textField.tag) {
            switch type {
            case FieldType.street, .city, .state, .zip:
                updateMapFromFields()
            case FieldType.perimeter:
                updatePerimeterFromField(textField: textField)
            default:
                break
            }
        }
    }

    func updatePerimeterFromField(textField: UITextField) {
        if var meters = Int(textField.text!) {
            // restrict to min max range
            meters = meters < cMinPerimeter ? cMinPerimeter : meters
            meters = meters > cMaxPerimeter ? cMaxPerimeter : meters
            if let annotation = self.annotation {
                updatePerimeterOverlay(coordinate: annotation.coordinate, radius: Double(meters))
            }
            // Update text if we restricted range or converted to int
            updatePerimeter(meters: meters)
        }
    }

    func updateFieldsFromLocation(theLocation : FTLocation) {
        self.fields[FieldType.name.rawValue].text = location.name
        self.fields[FieldType.street.rawValue].text = location.street
        self.fields[FieldType.city.rawValue].text = location.city
        self.fields[FieldType.state.rawValue].text = location.state
        self.fields[FieldType.zip.rawValue].text = location.zip
        annotation?.title = location.name
        annotation?.subtitle = location.street
        if let coordinate = theLocation.coordinates {
            annotation?.coordinate = coordinate
            self.updatePerimeterOverlay(coordinate: coordinate, radius: CLLocationDistance(perimeterSlider.value))
        }
        self.updatePerimeter(meters: location.perimeter)
    }

    func updateLocationFromFields(theLocation : FTLocation) {
        theLocation.name = self.fields[FieldType.name.rawValue].text ?? ""
        theLocation.street = self.fields[FieldType.street.rawValue].text  ?? ""
        theLocation.city = self.fields[FieldType.city.rawValue].text  ?? ""
        theLocation.state = self.fields[FieldType.state.rawValue].text ?? ""
        theLocation.zip = self.fields[FieldType.zip.rawValue].text ?? ""
        theLocation.perimeter = Int(self.perimeterSlider.value)
        theLocation.coordinates = self.annotation?.coordinate
    }

    func validateFields() -> String? {
        if self.fields[FieldType.name.rawValue].text?.characters.count == 0 {
            return "Locations must have names"
        }
        if self.fields[FieldType.street.rawValue].text?.characters.count == 0 {
            return "Locations must have street addresses"
        }
        if self.fields[FieldType.city.rawValue].text?.characters.count == 0 {
            return "Locations must have city"
        }
        if self.fields[FieldType.state.rawValue].text?.characters.count == 0 {
            return "Locations must have state"
        }
        return nil
    }

    // MARK: Actions Methods -------------------------------------------------------------------------------
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true) {

        }
    }

    @IBAction func createAction(_ sender: Any) {
        if let errorMessage = validateFields() {
            FTAlertMessage(message: "Can't create location: \(errorMessage)")
        } else {
            self.updateLocationFromFields(theLocation: self.location)
            ServerMgr.createLocation(location: location) { (locationDict, error) in
                if let error = error {
                    FTAlertMessage(message: "Creation failed: \(error)")
                } else if let locationId = locationDict?["_id"] as? String {
                    self.location.id = locationId
                    FTAlertMessage(message: "Location created")
                    self.dismiss(animated: true, completion: { 
                        FTAlertDismiss {
                            
                        }
                    })
                }
            }
        }

    }

    @IBAction func perimeterChanged(_ slider: UISlider) {
        // Constrain to specfic increments
        let meters = Int(slider.value/Float(cMinPerimeter))*Int(cMinPerimeter)
        updatePerimeter(meters: meters)
    }

    // MARK: Overlays Methods -------------------------------------------------------------------------------

    func updatePerimeterText(meters: Int) {
        fields[FieldType.perimeter.rawValue].text = "\(meters)"
    }

    func updatePerimeter(meters: Int) {
        updatePerimeterText(meters: meters)
        updatePerimeterOverlay(coordinate: annotation!.coordinate, radius: CLLocationDistance(meters))
        perimeterSlider.value = Float(meters)
    }

    func updatePerimeterOverlay(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance) {
        if let perimeter = self.perimeter {
            self.map.remove(perimeter)
        }
        self.perimeter = MKCircle(center: coordinate, radius: radius)
        self.map.add(self.perimeter!)
    }

    func updateAnnotationLocation(coordinate: CLLocationCoordinate2D) {
        if let annotation = self.annotation {
            self.map.removeAnnotation(annotation)
            annotation.coordinate = coordinate
            self.map.addAnnotation(annotation)
            self.map.setCenter(coordinate, animated: true)
        }
    }
}
