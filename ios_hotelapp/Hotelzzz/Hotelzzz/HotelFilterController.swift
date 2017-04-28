//
//  HotelFilterController.swift
//  Hotelzzz
//
//  Created by Eric on 4/24/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import UIKit

protocol HotelFilterControllerDelegate: class {
    func updateHotelFilter(minPrice: String, maxPrice: String)
}

class HotelFilterController: UIViewController {
    weak var delegate: HotelFilterControllerDelegate?
    var defaultMinPrice:String? = ""
    var defaultMaxPrice:String? = ""
    
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
        
        if numberValidation(min: minPriceStr, max: maxPriceStr) {
            self.delegate?.updateHotelFilter(minPrice: minPriceStr, maxPrice: maxPriceStr)
            self.dismiss(sender: nil)
        }else{
            let alert = UIAlertController(title: "Invalid Input(s)", message: "Please make sure you've entered valid min and max prices", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func numberValidation(min:String, max: String) -> Bool{
        if min == nil || max == nil {
            return false
        }else{
            if let min = Int(min){
                if let max = Int(max) {
                    return min >= 0 && max > min
                }else{
                    return false
                }
            }else{
                return false
            }
        }
    }

}
