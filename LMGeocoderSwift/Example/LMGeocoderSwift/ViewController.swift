//
//  ViewController.swift
//  LMGeocoderSwift
//
//  Created by LMinh on 03/02/2019.
//  Copyright (c) 2019 LMinh. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import LMGeocoderSwift

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var latitudeView: UIView!
    @IBOutlet weak var longitudeView: UIView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    // MARK: VIEW LIFECYCLE
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // You can set your google API key here
        LMGeocoder.sharedInstance.googleAPIKey = ""
        
        // Start getting current location
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.distanceFilter = 10
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        // Configure UI
        self.configureUI()
    }
    
    func configureUI() {
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        // Black background
        self.latitudeView.layer.cornerRadius = 5
        self.longitudeView.layer.cornerRadius = 5
        self.addressView.layer.cornerRadius = 5
        self.latitudeView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.longitudeView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.addressView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        // Show camera on real device for nice effect
        let hasCamera = AVCaptureDevice.devices().count > 0
        if hasCamera {
            let session = AVCaptureSession();
            session.sessionPreset = AVCaptureSession.Preset.high;
            
            let captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            captureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill;
            captureVideoPreviewLayer.frame = self.backgroundImageView.bounds;
            self.backgroundImageView.layer.addSublayer(captureVideoPreviewLayer)
            
            let device = AVCaptureDevice.default(for: AVMediaType.video);
            do {
                let input = try AVCaptureDeviceInput.init(device: device!)
                session.addInput(input)
                session.startRunning()
            }
            catch {
            }
        }
        else {
            self.backgroundImageView.image = UIImage(named: "background")
        }
    }
    
    // MARK: LOCATION MANAGER DELEGATE
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coordinate = locations.last?.coordinate {
            
            // Update UI
            self.latitudeLabel.text = String(format: "%f", coordinate.latitude)
            self.longitudeLabel.text = String(format: "%f", coordinate.longitude)
            
            // Start to reverse geocode
            LMGeocoder.sharedInstance.cancelGeocode()
            LMGeocoder.sharedInstance.reverseGeocode(coordinate: coordinate,
                                                     service: .AppleService,
                                                     completionHandler: { (results: Array<LMAddress>?, error: Error?) in
                                                        
                                                        // Parse formatted address
                                                        var formattedAddress: String? = "-"
                                                        if let address = results?.first, error == nil {
                                                            formattedAddress = address.formattedAddress
                                                        }
                                                        
                                                        // Update UI
                                                        DispatchQueue.main.async {
                                                            self.addressLabel.text = formattedAddress
                                                        }
            })
        }
    }
}

