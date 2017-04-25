//
//  HotelSortController.swift
//  Hotelzzz
//
//  Created by Eric on 4/24/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import UIKit

class Filter: NSObject{
    var displayName: String
    var sortId: String
    
    init(displayName: String, sortId: String){
        self.displayName = displayName
        self.sortId = sortId
    }
}

protocol HotelSortViewControllerDelegate: class{
    func updateHotelSort(viewController: HotelSortController, didUpdateSort sort: String)
}

class HotelSortController: UITableViewController{
    weak var delegate: HotelSortViewControllerDelegate?
    var initialFilter: String?
    
    @IBOutlet var optionsTable: UITableView!
    private var data: [Filter] = [Filter(displayName: "Name", sortId: "name"),
                                  Filter(displayName: "Ascending Price", sortId: "priceAscend"),
                                  Filter(displayName: "Descending Price", sortId: "priceDescend")
                                  ]
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath)
        
        let text = data[indexPath.row]
        
        cell.textLabel?.text = text.displayName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sortId = data[indexPath.row].sortId
        self.delegate?.updateHotelSort(viewController: self, didUpdateSort: sortId)
        self.dismiss(animated: true, completion: nil)
    }


}
