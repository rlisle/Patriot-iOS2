//
//  DevicesCollectionViewCell.swift
//  Patriot
//
//  Created by Ron Lisle on 5/31/18.
//  Copyright © 2018 Ron Lisle. All rights reserved.
//

import UIKit

class FavoritesCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var favorite: UIImageView!
    weak var device: Device?
    weak var favoriteDelegate:  FavoriteNotifying?
    
    func configure(device: Device, delegate: FavoriteNotifying?) {
        self.device = device
        self.favoriteDelegate = delegate
        let isOn = device.percent > 0
        imageView.image = isOn ? device.onImage : device.offImage
        label.text = device.name.capitalized
        
        if #available(iOS 13.0, *) {
            let favoriteName = "star.fill"
            let notFavoriteName = "star"
            if let image = UIImage(systemName: device.isFavorite ? favoriteName : notFavoriteName) {
                favorite.image = image
            }
        }

        let favoriteTapGesture = UITapGestureRecognizer(target: self, action: #selector(favoriteTapped(_:)))
        favorite.isUserInteractionEnabled = true
        favorite.addGestureRecognizer(favoriteTapGesture)

    }
    
    @objc func favoriteTapped(_ gestureRecognizer: UIGestureRecognizer)
    {
        guard let device = self.device,
              let favoriteDelegate = self.favoriteDelegate else {
            print("Device or delegate is nil")
            return
        }
        device.isFavorite.toggle()
        favoriteDelegate.favoriteChanged(device: device)
    }
}
