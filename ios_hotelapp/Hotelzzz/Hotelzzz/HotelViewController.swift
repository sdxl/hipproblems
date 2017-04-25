//
//  HotelViewController.swift
//  Hotelzzz
//
//  Created by Steve Johnson on 3/22/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import Foundation
import UIKit


class HotelViewController: UIViewController {
    var hotelInfo: AnyObject?
    var hotelName: String = ""
    @IBOutlet var hotelNameLabel: UILabel!
    @IBOutlet weak var hotelImageContainer: UIImageView!
    
    @IBOutlet weak var hotelPriceLabel: UILabel!
    @IBOutlet weak var hotelAddressLabel: UILabel!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let hotel = hotelInfo?["hotel"] as! [String:AnyObject]
        let hotelPrice = hotelInfo?["price"] as! NSNumber
        let hotelImageURL = hotel["imageURL"] as! String
        
        let imageURL = URL(string: hotelImageURL)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: imageURL!)
            DispatchQueue.main.async{
                self.hotelImageContainer.image = UIImage(data: data!)
            }
        }
        
        hotelNameLabel.text = hotel["name"] as? String
        hotelAddressLabel.text = hotel["address"] as? String
        hotelPriceLabel.text = "$\(hotelPrice)"
    }
}
