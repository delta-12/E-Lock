//
//  ELockViewModel.swift
//  E-Lock
//
//  Created by Esquieres, Benjamin T on 2/26/22.
//

import Foundation
import CoreBluetooth

class ELockViewModel : NSObject, ObservableObject, Identifiable {
    var id = UUID()

    // 1
    @Published var output = "Disconnected"  // current text to display in the output field
    
    // 2
    @Published var connected = false  // true when BLE connection is active
    
    @Published var armed = false
    
    private var stateCmd:[UInt8] = [0x00, 0x00]

    // 3
    func armingFunc(_ digit: Int) {
        stateCmd[0] = 0x00
        stateCmd[1] = UInt8(digit)
        send()
    }
    
    // 4
    func send() {
        guard let peripheral = connectedPeripheral,
              let inputChar = inputChar else {
            output = "Connection error"
            return
        }

        if stateCmd[1] == 0x00 {
            output = "Disarming..."
        }
        if stateCmd[1] == 0x01 {
            output = "Arming..."
        }
        
        peripheral.writeValue(Data(stateCmd), for: inputChar, type: .withoutResponse)
    }
    
    private var centralQueue: DispatchQueue?

    private let serviceUUID = CBUUID(string: "ef27b905-9bfc-41cd-9e6f-847165c6451e")
    
    private let inputCharUUID = CBUUID(string: "29bbc3ed-6faa-4011-b42e-823d518fa2e4")
    private var inputChar: CBCharacteristic?
    private let outputCharUUID = CBUUID(string: "54881514-684c-4457-8aee-b4e2a1acb6bf")
    private var outputChar: CBCharacteristic?
    
    // service and peripheral objects
    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    
    func connectELock() {
        output = "Connecting..."
        centralQueue = DispatchQueue(label: "test.discovery")
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
    func disconnectELock() {
        guard let manager = centralManager,
              let peripheral = connectedPeripheral else { return }
        
        manager.cancelPeripheralConnection(peripheral)
    }
}

extension ELockViewModel: CBCentralManagerDelegate {
    
    // This method monitors the Bluetooth radios state
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
            if central.state == .poweredOn {
                central.scanForPeripherals(withServices:
                                [serviceUUID], options: nil)
        }
    }
    
    // Called for each peripheral found that advertises the serviceUUID
    // This test program assumes only one peripheral will be powered up
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered \(peripheral.name ?? "UNKNOWN")")
        central.stopScan()
        
        connectedPeripheral = peripheral
        central.connect(peripheral, options: nil)
    }

    // After BLE connection to peripheral, enumerate its services
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "UNKNOWN")")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    // After BLE connection, cleanup
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "UNKNOWN")")
        
        centralManager = nil
        
        DispatchQueue.main.async {
            self.connected = false
            self.output = "Disconnected"
        }
    }
}

extension ELockViewModel: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discovered services for \(peripheral.name ?? "UNKNOWN")")
        
        guard let services = peripheral.services else {
            return
        }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Discovered characteristics for \(peripheral.name ?? "UNKNOWN")")
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        for ch in characteristics {
            switch ch.uuid {
                case inputCharUUID:
                    inputChar = ch
                case outputCharUUID:
                    outputChar = ch
                    // subscribe to notification events for the output characteristic
                    peripheral.setNotifyValue(true, for: ch)
                default:
                    break
            }
        }
        
        DispatchQueue.main.async {
            self.connected = true
            self.output = "Connected"
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("Notification state changed to \(characteristic.isNotifying)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Characteristic updated: \(characteristic.uuid)")
        if characteristic.uuid == outputCharUUID, let data = characteristic.value {
//            let bytes:[UInt8] = data.map {$0}
            
            if data[0] == 0x00 {
                if data[1] == 0x00 {
                    DispatchQueue.main.async {
                        self.armed = false
                        self.output = "Disarmed"
                    }
                } else if data[1] == 0x01 {
                    DispatchQueue.main.async {
                        self.armed = true
                        self.output = "Armed"
                    }
                }
            } else if data[0] == 0x01 && data[1] == 0x01 {
                DispatchQueue.main.async {
                    self.output = "ALARM!"
                }
            }
            
            
        }
    }
}
