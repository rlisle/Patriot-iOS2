//
//  MQTTEncoder.swift
//  PatriotMac
//
//  Created by Ron Lisle on 9/8/18.
//  Copyright © 2018 Ron Lisle. All rights reserved.
//

import Foundation

class MQTTEncoder {
    
    var mqtt: MQTTSending?

    func setCondition(name: String, isOn: Bool) {
        Log.text("Encoder setCondition \(name) = " + (isOn ? "on" : "off"), type: .debug)
        mqtt?.sendMessage(topic: "patriot", message: name + ":" + (isOn ? "100" : "0"))
    }
    
    func setLight(name: String, isOn: Bool) {   // Patriot on/off light
        Log.text("Encoder setLight \(name) = " + (isOn ? "on" : "off"), type: .debug)
        mqtt?.sendMessage(topic: "patriot", message: name + ":" + (isOn ? "100" : "0"))
    }
    
    func setLamp(name: String, percent: Int) {   // SmartThings lightbulb
        Log.text("Encoder setLamp \(name) = \(percent)", type: .debug)
        let topic = "smartthings/\(name)/switch"
        if percent == 0 {
            mqtt?.sendMessage(topic: topic, message: "off")
        } else {
            mqtt?.sendMessage(topic: topic, message: "on")
            let levelTopic = "smartthings/\(name)/level"
            mqtt?.sendMessage(topic: levelTopic, message: "\(percent)")
        }
    }
}
