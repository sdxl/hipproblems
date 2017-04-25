//
//  HotelFilterController.swift
//  Hotelzzz
//
//  Created by Eric on 4/24/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import UIKit

protocol HotelFilterControllerDelegate: class {
    func updateHotelFilter(minPrice: Int, maxPrice: Int)
}

class HotelFilterController: UIViewController {
    weak var delegate: HotelFilterControllerDelegate?
    var defaultMinPrice:Int?
    var defaultMaxPrice:Int?
    
    @IBOutlet weak var minPriceInput: UITextField!
    @IBOutlet weak var maxPriceInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let defaultMinPrice = defaultMinPrice {
            minPriceInput.text = String(defaultMinPrice)
        }
        
        if let defaultMaxPrice = defaultMaxPrice{
            maxPriceInput.text = String(defaultMaxPrice)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitFilters(_ sender: Any) {
        let minPriceStr = self.minPriceInput.text!
        let maxPriceStr = self.maxPriceInput.text!
        
        if let minPriceInt = Int(minPriceStr){
            if let maxPriceInt = Int(maxPriceStr) {
                if numberValidation(min: minPriceInt, max: maxPriceInt) {
                    self.delegate?.updateHotelFilter(minPrice: minPriceInt, maxPrice: maxPriceInt)
                }
            }
        }
        
        self.dismiss(sender: nil)
    }
    
    func numberValidation(min:Int, max: Int) -> Bool{
        return min >= 0 && max > min
    }

}
