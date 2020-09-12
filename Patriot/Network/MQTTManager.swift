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
}

// This protocol provides notifications of MQTT events to a delegate
protocol MQTTReceiving
{
    func connectionDidChange(isConnected: Bool)
    func didReceiveMessage(topic: String, message: String)
}

class MQTTManager {

    let mqttURL = "rons-mac-mini" //192.168.10.148"
    let mqttPort: UInt16 = 1883
    let mqttTopic = "#"             // For now we're receiving everything
    
    let mqtt: CocoaMQTT!
    
    var delegate: MQTTReceiving?
    
    init() {
        let clientID = "Patriot" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: mqttURL, port: mqttPort)
        mqtt.delegate = self
        mqtt.connect()
    }
    
}

extension MQTTManager: MQTTSending
{
    func sendMessage(topic: String, message: String) {
        //Log.text("MQTT sendMessage \(topic) \(message)", type: .debug)
        mqtt.publish(topic, withString: message)
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
        //Log.text("MQTT didReceive trust: \(trust)", type: .debug)
        completionHandler(true)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        delegate?.connectionDidChange(isConnected: true)
        mqtt.subscribe(mqttTopic)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        //Log.text("MQTT didPublishMessage: \(message), id: \(id)", type: .debug)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        //Log.text("MQTT didPublishAck id: \(id)", type: .debug)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
        //for topic in topics {
        //Log.text("MQTT didSubscribeTopic: \(topic)", type: .debug)
        //}
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        //Log.text("MQTT didUnsubscribeTopic: \(topic)", type: .debug)
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        //Log.text("MQTT ping", type: .debug)   // Too much noise
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        //Log.text("MQTT pong", type: .debug)   // Too much noise
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        //Log.text("MQTT didDisconnect withError: \(String(describing: err))", type: .debug)
        delegate?.connectionDidChange(isConnected: false)
    }
    
    func _console(_ info: String) {
        //AdLog.text("MQTT console: \(info)", type: .debug)
    }
}
