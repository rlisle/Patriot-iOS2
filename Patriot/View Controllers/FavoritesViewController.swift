//
//  FavoritesViewController.swift
//  Patriot
//
//  Created by Ron Lisle on 6/27/21
//  Copyright © 2021 Ron Lisle. All rights reserved.
//

import UIKit

private let reuseIdentifier = "DeviceCell"

class FavoritesViewController: UICollectionViewController {

    var deviceManager: DevicesManager?
    var settings: Settings?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate
        {
            //TODO: inject factory into init
            appDelegate.appFactory?.configureFavorites(viewController: self)
            print("Number of favorites: \(deviceManager!.favorites.count)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        // Since the favorites list can change while not displayed, update it each view
        print("viewWillAppear Reloading data")
        collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfFavorites = deviceManager?.favorites.count ?? 0
        print("Favorites: number of items = \(numberOfFavorites)")
        return numberOfFavorites
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        styleCell(cell)

        if let favorites = deviceManager?.favorites, favorites.count > indexPath.row
        {
            let favorite = favorites[indexPath.row];
            if let cell = cell as? FavoritesCollectionViewCell
            {
                cell.configure(device: favorite, delegate: self)
                cell.tag = indexPath.row
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deviceManager?.toggleFavorite(at: indexPath.row)
        collectionView.reloadData()
    }

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
extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    
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

extension FavoritesViewController: DeviceNotifying {
    func deviceListChanged() {
        print("Favorites deviceListChanged")
        collectionView?.reloadData()
    }
    
    func deviceChanged(name: String, percent: Int) {
        print("Favorites deviceChanged: \(name), \(percent)")
        if let index = deviceManager?.favorites.firstIndex(where: {$0.name == name})
        {
            print("   index of deviceChanged = \(index)")
            collectionView?.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }
}

extension FavoritesViewController: FavoriteNotifying {
    func favoriteChanged(device: Device) {
        deviceManager?.updateFavoritesList()
        collectionView?.reloadData()
    }
}
