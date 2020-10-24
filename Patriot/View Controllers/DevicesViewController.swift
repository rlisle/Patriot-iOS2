//
//  DevicesViewController.swift
//  Patriot
//
//  Created by Ron Lisle on 5/31/18.
//  Copyright © 2018 Ron Lisle. All rights reserved.
//

import UIKit

private let reuseIdentifier = "DeviceCell"

class DevicesViewController: UICollectionViewController {

    var dataManager: DevicesDataManager?
    var settings: Settings?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate
        {
            //TODO: inject factory into init
            appDelegate.appFactory?.configureDevices(viewController: self)
            print("Number of devices: \(dataManager!.devices.count)")
        }
    }

    @objc func tap(_ gestureRecognizer: UIGestureRecognizer)
    {
        if let index = gestureRecognizer.view?.tag
        {
            dataManager?.toggleDevice(at: index)
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfDevices = dataManager?.devices.count ?? 0
        print("Devices: number of items = \(numberOfDevices)")
        return numberOfDevices
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        styleCell(cell)

        if let devices = dataManager?.devices, devices.count > indexPath.row
        {
            let device = devices[indexPath.row];
            if let cell = cell as? DevicesCollectionViewCell
            {
                print("Cell device \(device.name) is \(device.percent)%")
                let isOn = device.percent > 0
                let image = isOn ? device.onImage : device.offImage
                cell.imageView.image = image
                
                let caption = device.name.capitalized
                cell.label.text = caption
                
                cell.tag = indexPath.row
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(_: )))
                cell.addGestureRecognizer(tapGesture)
            }
        }
        
        return cell
    }

    func styleCell(_ cell: UICollectionViewCell)
    {
        cell.layer.masksToBounds = false
        cell.layer.cornerRadius = 2
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 1.0
        cell.layer.shadowOpacity = 0.75
        cell.layer.shadowRadius = 10
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize.zero
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

// MARK: Flow Layout Delegate
extension DevicesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 150, height: 150)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        
        let verticalInsets: CGFloat = 30
        
        let itemWidth = 150
        let screenSize = UIScreen.main.bounds
        let displayWidth = Int(screenSize.width)
        let numberOfItemsPerRow = displayWidth / itemWidth
        let horizontalSpacing = CGFloat((displayWidth - (itemWidth * numberOfItemsPerRow)) / (numberOfItemsPerRow + 1))
        let inset = UIEdgeInsets.init(top: verticalInsets, left: horizontalSpacing-1, bottom: verticalInsets, right: horizontalSpacing-1)
        
        return inset
    }
}

extension DevicesViewController: DeviceNotifying {
    func deviceListChanged() {
        print("deviceListChanged")
        collectionView?.reloadData()
    }
    
    func deviceChanged(name: String, percent: Int) {
        print("deviceChanged: \(name), \(percent)")
        if let index = dataManager?.devices.firstIndex(where: {$0.name == name})
        {
            print("   index of deviceChanged = \(index)")
            collectionView?.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }
}
