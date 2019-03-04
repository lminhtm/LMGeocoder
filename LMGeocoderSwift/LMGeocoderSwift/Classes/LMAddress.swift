//
//  LMAddress.swift
//  LMGeocoderSwift
//
//  Created by LMinh on 12/18/18.
//  Copyright © 2018 LMinh. All rights reserved.
//

import UIKit
import CoreLocation
import Contacts

/// A result from a reverse geocode request, containing a human-readable address.
/// Some of the fields may be nil, indicating they are not present.
open class LMAddress: NSObject {

    // MARK: - PROPERTIES
    
    /// The location coordinate.
    open var coordinate: CLLocationCoordinate2D?
    
    /// The precise street address.
    open var streetNumber: String?
    
    /// The named route.
    open var route: String?
    
    /// The incorporated city or town political entity.
    open var locality: String?
    
    /// The first-order civil entity below a localit.
    open var subLocality: String?
    
    /// The civil entity below the country level.
    open var administrativeArea: String?
    
    /// The additional administrative area information.
    open var subAdministrativeArea: String?
    
    /// The neighborhood information.
    open var neighborhood: String?
    
    /// The Postal/Zip code.
    open var postalCode: String?
    
    /// The country name.
    open var country: String?
    
    /// The ISO country code.
    open var ISOcountryCode: String?
    
    /// The formatted address.
    open var formattedAddress: String?
    
    /// An array of NSString containing formatted lines of the address.
    open var lines: [String]?
    
    /// The raw source object.
    open var rawSource: AnyObject?
    
    // MARK: - INIT
    
    /// Custom initialization with response from server.
    ///
    /// - Parameters:
    ///   - locationData: Response object recieved from server
    ///   - serviceType: Pass here kLMGeocoderGoogleService or kLMGeocoderAppleService
    init(locationData: AnyObject, serviceType: LMGeocoderService) {
        super.init()
        switch serviceType {
        case .AppleService:
            self.parseAppleResponse(locationData: locationData)
        default:
            self.parseGoogleResponse(locationData: locationData)
        }
    }
    
    // MARK: SUPPORT
    
    private func parseAppleResponse(locationData: AnyObject) {
        
        guard let placemark = locationData as? CLPlacemark else { return }
        
        self.coordinate = placemark.location?.coordinate
        self.streetNumber = placemark.thoroughfare
        self.locality = placemark.locality
        self.subLocality = placemark.subLocality
        self.administrativeArea = placemark.administrativeArea
        self.subAdministrativeArea = placemark.subAdministrativeArea
        self.postalCode = placemark.postalCode
        self.country = placemark.country
        self.ISOcountryCode = placemark.isoCountryCode
        if #available(iOS 11.0, *) {
            if let postalAddress = placemark.postalAddress {
                self.formattedAddress = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
            }
        }
        self.rawSource = placemark
    }
    
    private func parseGoogleResponse(locationData: AnyObject) {
        
        guard let locationDict = locationData as? Dictionary<String, Any> else { return }
        
        let addressComponents = locationDict["address_components"]
        let formattedAddress = locationDict["formatted_address"] as? String
        
        var lat = 0.0
        var lng = 0.0
        if let geometry = locationDict["geometry"] as? Dictionary<String, Any> {
            if let location = geometry["location"] as? Dictionary<String, Any> {
                if let latitude = location["lat"] as? Double {
                    lat = Double(latitude)
                }
                if let longitute = location["lng"] as? Double {
                    lng = Double(longitute)
                }
            }
        }
        
        self.coordinate = CLLocationCoordinate2DMake(lat, lng)
        self.streetNumber = self.getComponent(component: "street_number", array: addressComponents, type: "long_name")
        self.route = self.getComponent(component: "route", array: addressComponents, type: "long_name")
        self.locality = self.getComponent(component: "locality", array: addressComponents, type: "long_name")
        self.subLocality = self.getComponent(component: "sublocality", array: addressComponents, type: "long_name")
        self.administrativeArea = self.getComponent(component: "administrative_area_level_1", array: addressComponents, type: "long_name")
        self.subAdministrativeArea = self.getComponent(component: "administrative_area_level_2", array: addressComponents, type: "long_name")
        self.neighborhood = self.getComponent(component: "neighborhood", array: addressComponents, type: "long_name")
        self.postalCode = self.getComponent(component: "postal_code", array: addressComponents, type: "short_name")
        self.country = self.getComponent(component: "country", array: addressComponents, type: "long_name")
        self.ISOcountryCode = self.getComponent(component: "country", array: addressComponents, type: "short_name")
        self.formattedAddress = formattedAddress
        self.lines = formattedAddress?.components(separatedBy: ", ")
        self.rawSource = locationData
    }
    
    private func getComponent(component: String, array: Any?, type: String) -> String? {
        
        guard let array = array as? NSArray else { return nil }
        
        let index = array.indexOfObject { (obj, idx, stop) -> Bool in
            return false
        }
        
        if index == NSNotFound || index >= array.count {
            return nil
        }
        
        if let dict = array[index] as? [String: Any] {
            return dict[type] as? String
        }
        return nil;
    }
}
