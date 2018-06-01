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
    
    //TODO: make these calculated properties using aggregtion of photons collection
    var devices: [DeviceInfo] = []
    var activities:  [ActivityInfo] = []
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
                    self.subscribeToEvents()
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
            (photons: [ParticleDevice]?, error: Error?) in
            
            guard photons != nil && error == nil else {
                print("getAllPhotonDevices error: \(error!)")
                completion(error)
                return
            }
            self.addAllPhotonsToCollection(photonDevices: photons!)
                .then { _ -> Void in
                    print("All photons added to collection")
                    self.activityDelegate?.supportedListChanged()
                    completion(error)
            }
        }
    }


    func addAllPhotonsToCollection(photonDevices: [ParticleDevice]) -> Promise<Void>
    {
        print("addAllPhotonsToCollection")
        self.photons = [: ]
        var promises = [Promise<Void>]()
        for photonDevice in photonDevices
        {
            if isValidPhoton(photonDevice)
            {
                if let name = photonDevice.name?.lowercased()
                {
                    print("Adding photon \(name) to collection")
                    let photon = Photon(device: photonDevice)
                    photon.delegate = self
                    self.photons[name] = photon
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
                    print("Subscribe: received event with data \(String(describing: event?.data))")
                    if let eventData = event?.data {
                        let splitArray = eventData.components(separatedBy: ":")
                        let name = splitArray[0].lowercased()
                        if let percent: Int = Int(splitArray[1]), percent >= 0, percent <= 100
                        {
                            //TODO: Currently can't tell if this is an activity or device
                            self.activityDelegate?.activityChanged(name: name, isActive: percent != 0)
                            self.deviceDelegate?.deviceChanged(name: name, percent: percent)
                        }
                        else
                        {
                            print("Event data is not a valid number")
                        }
                    }
                    
                })
            }
        })
    }
}


// These methods receive the capabilities of each photon asynchronously
extension PhotonManager: PhotonNotifying
{
    func device(named: String, hasDevices: [DeviceInfo])
    {
        print("device named \(named) hasDevices \(hasDevices)")
        //TODO: remove duplicates
        devices += hasDevices
    }
    
    
    func device(named: String, hasActivities: [ActivityInfo])
    {
        print("device named \(named) hasActivities \(hasActivities)")
        activities += hasActivities
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
