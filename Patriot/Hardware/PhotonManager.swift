//
//  PhotonManager.swift
//  Patriot
//
//  This class manages the collection of Photon microcontrollers
//
//  Discovery will search for all the Photon devices on the network
//  in the logged-in user's account.
//
//  When a new device is found, it will be added to the photons collection
//  and a delegate called.
//  This is the anticipated way of updating displays, etc.
//
//  The current activity state will be gleaned from the exposed Activities
//  properties of one or more Photons initially, but then tracked directly
//  after initialization by subscribing to particle or MQTT events.
//
//  Subscribing to particle events will also allow detecting new Photons
//  as they come online.
//
//  This file uses the Particle SDK: 
//      https://docs.particle.io/reference/ios/#common-tasks
//
//  Created by Ron Lisle on 11/13/16.
//  Copyright © 2016, 2017 Ron Lisle. All rights reserved.
//

import Foundation
import Particle_SDK
import PromiseKit

enum ParticleSDKError : Error
{
    case invalidUserPassword
    case invalidToken
    case notLoggedIn
}


class PhotonManager: NSObject
{
    var subscribeHandler:  Any?                 // Particle.io subscribe handle
    var deviceDelegate:    DeviceNotifying?     // Reports changes to devices
    var activityDelegate:  ActivityNotifying?   // Reports changes to activities

    var isLoggedIn = false
    
    var photons: [String: Photon] = [: ]   // All the particle devices attached to logged-in user's account
    let eventName          = "patriot"
    
    //TODO: make this a calculated property using photons collection
    var deviceNames        = Set<String>()      // Names exposed by the "Devices" variables
    
    //TODO: make this a calculated property using photons collection
    var supportedNames     = Set<String>()      // Activity names exposed by the "Supported" variables
    
    //TODO: make this a calculated property using photons collection
    var currentActivities:  [String: Int] = [: ] // List of currently on activities reported by Master
    
}

extension PhotonManager: LoggingIn
{
    /**
     * Login to the particle.io account
     * The particle SDK will use the returned token in subsequent calls.
     * We don't have to save it.
     */
    func login(user: String, password: String, completion: @escaping (Error?) -> Void)
    {
        if !isLoggedIn {
            
            ParticleCloud.sharedInstance().login(withUser: user, password: password) { (error) in
                if error == nil {
                    self.isLoggedIn = true
                    self.getAllPhotonDevices(completion: completion)
                    
                } else {
                    print ("Error logging in: \(error!)")
                    self.isLoggedIn = false
                    completion(error)
                }
            }
        }
    }
    
    func logout()
    {
        ParticleCloud.sharedInstance().logout()
        isLoggedIn = false
    }
    
}



extension PhotonManager: HwManager
{
    /**
     * Locate all the particle.io devices
     */
    func getAllPhotonDevices(completion: @escaping (Error?) -> Void)
    {
        print("getAllPhotonDevices")
        ParticleCloud.sharedInstance().getDevices {
            (devices: [ParticleDevice]?, error: Error?) in
            
            guard devices != nil && error == nil else {
                print("getAllPhotonDevices error: \(error!)")
                completion(error)
                return
            }
            self.addAllPhotonsToCollection(devices: devices!)
                .then { _ -> Void in
                    print("All photons added to collection")
                    self.activityDelegate?.supportedListChanged()
                    completion(error)
            }
        }
    }


    func addAllPhotonsToCollection(devices: [ParticleDevice]) -> Promise<Void>
    {
        print("addAllPhotonsToCollection")
        self.photons = [: ]
        var promises = [Promise<Void>]()
        for device in devices
        {
            if isValidPhoton(device)
            {
                if let name = device.name?.lowercased()
                {
                    print("Adding photon \(name) to collection")
                    let photon = Photon(device: device)
                    photon.delegate = self
                    self.photons[name] = photon
                    //self.deviceDelegate?.deviceFound(name: name) No, this call is for devices, not photons now.
                    let promise = photon.refresh()
                    promises.append(promise)
                }
            }
        }
        return when(fulfilled: promises)
    }
    
    
    func isValidPhoton(_ device: ParticleDevice) -> Bool
    {
        return device.connected
    }
    
    
    func getPhoton(named: String) -> Photon?
    {
        let lowerCaseName = named.lowercased()
        let photon = photons[lowerCaseName]
        
        return photon
    }

    func sendCommand(activity: String, percent: Int, completion: @escaping (Error?) -> Void)
    {
        print("sendCommand to activity: \(activity) percent: \(percent)")
        let event = activity + ":" + String(percent)
        publish(event: event, completion: completion)
    }

    func sendCommand(device: String, percent: Int, completion: @escaping (Error?) -> Void)
    {
        print("sendCommand to device: \(device) percent: \(percent)")
        let event = device + ":" + String(percent)
        publish(event: event, completion: completion)
    }

    func publish(event: String, completion: @escaping (Error?) -> Void)
    {
        print("Publishing event: \(eventName) : \(event)")
        ParticleCloud.sharedInstance().publishEvent(withName: eventName, data: event, isPrivate: true, ttl: 60)
        { (error:Error?) in
            if let e = error
            {
                print("Error publishing event \(e.localizedDescription)")
            }
            completion(error)
        }
    }
    
    func subscribeToEvents()
    {
        subscribeHandler = ParticleCloud.sharedInstance().subscribeToMyDevicesEvents(withPrefix: eventName, handler: { (event: ParticleEvent?, error: Error?) in
            if let error = error {
                print("Error subscribing to events: \(error)")
            }
            else
            {
                DispatchQueue.main.async(execute: {
                    //print("Subscribe: received event with data \(String(describing: event?.data))")
                    if let eventData = event?.data {
                        let splitArray = eventData.components(separatedBy: ":")
                        let name = splitArray[0].lowercased()
                        if let percent: Int = Int(splitArray[1]), percent >= 0, percent <= 100
                        {
                            self.activityDelegate?.activityChanged(name: name, percent: percent)
                        }
                        else
                        {
//                            print("Event data is not a valid number")
                        }
                    }
                    
                })
            }
        })
    }
}


extension PhotonManager
{
//    private func parseSupportedNames(_ supported: String) -> Set<String>
//    {
//        print("6. Parsing supported names: \(supported)")
//        var newSupported: Set<String> = []
//        let items = supported.components(separatedBy: ",")
//        for item in items
//        {
//            let lcItem = item.localizedLowercase
//            print("7. New supported = \(lcItem)")
//            newSupported.insert(lcItem)
//        }
//        
//        return newSupported
//    }
    
    
//    func refreshCurrentActivities()
//    {
//        print("8. refreshCurrentActivities")
//        currentActivities = [: ]
//        for (name, photon) in photons
//        {
//            let particleDevice = photon.particleDevice
//            if particleDevice?.variables["Activities"] != nil
//            {
//                print("9.  reading Activities variable from \(name)")
//                particleDevice?.getVariable("Activities") { (result: Any?, error: Error?) in
//                    if error == nil
//                    {
//                        if let activities = result as? String, activities != ""
//                        {
//                            print("10. Activities = \(activities)")
//                            let items = activities.components(separatedBy: ",")
//                            for item in items
//                            {
//                                let parts = item.components(separatedBy: ":")
//                                self.currentActivities[parts[0]] = parts[1]
////                                self.activityDelegate?.activityChanged(event: item)
//                            }
//                        }
//                    } else {
//                        print("Error reading Supported variable. Skipping this device.")
//                    }
//                    print("11. Updated Supported names = \(self.supportedNames)")
//                    self.activityDelegate?.supportedListChanged()
//                }
//            }
//        }
//    }
}


// These methods receive the capabilities of each photon asynchronously
extension PhotonManager: PhotonNotifying
{
    func device(named: String, hasDevices: Set<String>)
    {
        print("device named \(named) hasDevices \(hasDevices)")
        deviceNames = deviceNames.union(hasDevices)
    }
    
    
    func device(named: String, supports: Set<String>)
    {
        print("device named \(named) supports \(supports)")
        supportedNames = supportedNames.union(supports)
    }
    
    
    func device(named: String, hasSeenActivities: [String: Int])
    {
        print("device named \(named) hasSeenActivities \(hasSeenActivities)")
        hasSeenActivities.forEach { (k,v) in currentActivities[k] = v }
    }
}


extension PhotonManager
{
    func readVariable(device: ParticleDevice, name: String) -> Promise<String>
    {
        return Promise { fulfill, reject in
            device.getVariable("Supported")
            { (result: Any?, error: Error?) in
                if let variable = result as? String
                {
                    fulfill(variable)
                }
                else
                {
                    reject(error!)
                }
            }
        }
    }
}
