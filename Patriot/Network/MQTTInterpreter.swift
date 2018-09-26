//
//  MQTTInterpreter.swift
//  PatriotMac
//
//  Created by Ron Lisle on 9/7/18.
//  Copyright © 2018 Ron Lisle. All rights reserved.
//

import Foundation

class MQTTInterpreter: MQTTReceiving {
    
    var connectionDelegate: ConnectionReporting?
    var stateCollection: StateCollection?
    
    func connectionDidChange(isConnected: Bool) {
        connectionDelegate?.connectionDidChange(isConnected: isConnected)
    }
    
    func didReceiveMessage(topic: String, message: String) {
        
        // Decode patriot messages
        // t:"patriot" m:"<device>:<percent>
        if topic.hasPrefix("patriot") {
            let messageParts = message.split(separator: ":")
            let device = String(messageParts[0])
            if let percent = Int(messageParts[1]) {
                Log.text("Interpreter updating state: \(device) = \(percent)", type: .debug)
                // TODO: what about type?
                stateCollection?.updateState(named: device, type: .light, percent: percent)
            }
            
        // Decode SmartThings messages
        // t: smartthings/<device>/type m:value
        } else if topic.hasPrefix("smartthings") {
            let topicParts = topic.split(separator: "/")
            let stDevice = String(topicParts[1])
            let stType = String(topicParts[2])
            // Handle message based on stType
            // TODO: refactor this!
            switch(stType) {
            case "contact":
                Log.text("Interpreter smartthings \(stDevice) contact is: \(message)", type: .debug)
                updateState(state: stDevice, type: .contact, percent: (message == "closed") ? 0 : 100)
                
            case "level":
                Log.text("Interpreter smartthings \(stDevice) level is: \(message)", type: .debug)
                if let dimming = Int(message) {
                    // TODO: could level be other device types?
                    updateState(state: stDevice, type: .lamp, percent: dimming)
                }
                
            case "motion":
                Log.text("Interpreter smartthings \(stDevice) motion is: \(message)", type: .debug)
                updateState(state: stDevice + " Motion", type: .motion, percent: (message == "inactive") ? 0 : 100)

            case "presence":
                Log.text("Interpreter smartthings \(stDevice) presence is: \(message)", type: .debug)
                updateState(state: stDevice, type: .presence, percent: (message == "present") ? 100 : 0)

            case "switch":
                Log.text("Interpreter smartthings \(stDevice) switch is: \(message)", type: .debug)
                updateState(state: stDevice, type: .lamp, percent: (message == "on") ? 100 : 0)
                
            case "temperature":
                Log.text("Interpreter smartthings \(stDevice) temperature is: \(message)", type: .debug)
                if let percent = Int(message) {
                    updateState(state: stDevice, type: .temperature, percent: percent)
                }
                
            default:
                Log.text("Interpreter smartthings unknown device \(stDevice) state: \(message)", type: .warning)
            }
        } else {
            Log.text("Interpreter unknown MQTT topic: \(topic) message: \(message)", type: .debug)
        }
    }
    
    func updateState(state: String, type: StateType, percent: Int) {
        stateCollection?.updateState(named: state, type: type, percent: percent)
    }
}
