//
//  mqttManager.swift
//  Patriot
//
//  Created by Ron Lisle on 6/10/18.
//  Copyright © 2018 Rons iMac. All rights reserved.
//

import Foundation
import CocoaMQTT

// This protocol is used to send MQTT events
protocol MQTTSending
{
    func sendMessage(topic: String, message: String)
    func sendCommand(activity: String, isActive: Bool)
    func sendCommand(device: String, percent: Int)
}

// This protocol provides notifications of MQTT events to a delegate
protocol MQTTReceiving
{
    func connectionDidChange(isConnected: Bool)
    func didReceiveMessage(topic: String, message: String)
}

class MQTTManager {

    let mqttURL = "192.168.10.184" // was "rons-mac-mini"
    let mqttPort: UInt16 = 1883
    let mqttTopic = "#"             // For now we're receiving everything
    
    let mqtt: CocoaMQTT!
    
    var isConnected: Bool = false
    
    var delegate: MQTTReceiving?
    
    init() {
        let clientID = "Patriot" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: mqttURL, port: mqttPort)
        mqtt.delegate = self
        isConnected = mqtt.connect()
        print("MQTT init connected: \(isConnected)")
    }
}

extension MQTTManager: MQTTSending
{
    func sendMessage(topic: String, message: String) {
        print("MQTT sendMessage \(topic) \(message)")
        mqtt.publish(topic, withString: message)
    }
    
    func sendCommand(activity: String, isActive: Bool)
    {
        let event = activity + ":" + (isActive ? "100" : "0")
        sendMessage(topic: "patriot", message: event)
    }

    func sendCommand(device: String, percent: Int)
    {
        let event = device + ":" + String(percent)
        sendMessage(topic: "patriot", message: event)
    }
}

extension MQTTManager: CocoaMQTTDelegate {
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        if let payload: String = message.string {
            let topic = message.topic
            print("MQTT didReceiveMessage: \(topic), \(payload)")
            delegate?.didReceiveMessage(topic: topic, message: payload)
        }
    }
    
    // Other required methods for CocoaMQTTDelegate
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        print("MQTT didReceive trust: \(trust)")
        completionHandler(true)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("MQTT didConnectAck")
        delegate?.connectionDidChange(isConnected: true)
        mqtt.subscribe(mqttTopic)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("MQTT didPublishMessage: \(message), id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("MQTT didPublishAck id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
        for topic in topics {
            print("MQTT didSubscribeTopic: \(topic)")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("MQTT didUnsubscribeTopic: \(topic)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("MQTT ping")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("MQTT pong")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("MQTT didDisconnect withError: \(String(describing: err))")
        isConnected = false
        delegate?.connectionDidChange(isConnected: false)
    }
    
    func _console(_ info: String) {
        //AdLog.text("MQTT console: \(info)", type: .debug)
    }
}
