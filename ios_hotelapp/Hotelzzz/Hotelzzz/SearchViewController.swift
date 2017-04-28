//
//  SearchViewController.swift
//  Hotelzzz
//
//  Created by Steve Johnson on 3/22/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import Foundation
import WebKit
import UIKit


private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-mm-dd"
    return formatter
}()

private func jsonStringify(_ obj: [AnyHashable: Any]) -> String {
    let data = try! JSONSerialization.data(withJSONObject: obj, options: [])
    return String(data: data, encoding: .utf8)!
}


class SearchViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, HotelSortViewControllerDelegate, HotelFilterControllerDelegate{
    
    struct Search {
        let location: String
        let dateStart: Date
        let dateEnd: Date

        var asJSONString: String {
            return jsonStringify([
                "location": location,
                "dateStart": dateFormatter.string(from: dateStart),
                "dateEnd": dateFormatter.string(from: dateEnd)
            ])
        }
    }
    
    struct PriceFilter{
        let minPrice: String
        let maxPrice: String
        
        var asJSONString: String{
            return jsonStringify([
                "priceMin": minPrice == "" ? "null" : minPrice,
                "priceMax": maxPrice == "" ? "null" : maxPrice
            ])
        }
    }
    
    @IBOutlet weak var navigationTitle: UINavigationItem!
    private var _searchToRun: Search?
    private var _selectedHotel: AnyObject?
    private var _minPrice: String?
    private var _maxPrice: String?
    
    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: CGRect.zero, configuration: {
            let config = WKWebViewConfiguration()
            config.userContentController = {
                let userContentController = WKUserContentController()

                // DECLARE YOUR MESSAGE HANDLERS HERE
                userContentController.add(self, name: "API_READY")
                userContentController.add(self, name: "HOTEL_API_HOTEL_SELECTED")
                userContentController.add(self, name: "HOTEL_API_RESULTS_READY")
                
                return userContentController
            }()
            return config
        }())
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self

        self.view.addSubview(webView)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: [], metrics: nil, views: ["webView": webView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: [], metrics: nil, views: ["webView": webView]))
        return webView
    }()

    func search(location: String, dateStart: Date, dateEnd: Date) {
        _searchToRun = Search(location: location, dateStart: dateStart, dateEnd: dateEnd)
        self.webView.load(URLRequest(url: URL(string: "http://hipmunk.github.io/hipproblems/ios_hotelapp/")!))
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let alertController = UIAlertController(title: NSLocalizedString("Could not load page", comment: ""), message: NSLocalizedString("Looks like the server isn't running.", comment: ""), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Bummer", comment: ""), style: .default, handler: nil))
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
    

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "API_READY":
            guard let searchToRun = _searchToRun else { fatalError("Tried to load the page without having a search to run") }
            self.webView.evaluateJavaScript(
                "window.JSAPI.runHotelSearch(\(searchToRun.asJSONString))",
                completionHandler: nil)
        case "HOTEL_API_HOTEL_SELECTED":
            let dict = message.body as! [String:AnyObject]
            _selectedHotel = dict["result"]
            self.performSegue(withIdentifier: "hotel_details", sender: nil)
        case "HOTEL_API_RESULTS_READY":
            updateResultsCounter()
        default: break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "select_sort"){
            let destination = segue.destination
            guard let navVC = destination as? UINavigationController,
                let HotelSortController = navVC.topViewController as? HotelSortController else {
                    fatalError("Segue destination has unexpected type")
            }
            HotelSortController.delegate = self
        }
        if(segue.identifier == "hotel_details"){
            let nextScene =  segue.destination as! HotelViewController
            nextScene.hotelInfo = _selectedHotel
        }
        
        if(segue.identifier == "select_filters"){
            let destination = segue.destination
            guard let navVC = destination as? UINavigationController,
                let HotelFilterController = navVC.topViewController as? HotelFilterController else {
                    fatalError("Segue destination has unexpected type")
            }
            HotelFilterController.delegate = self
            HotelFilterController.defaultMaxPrice = _maxPrice
            HotelFilterController.defaultMinPrice = _minPrice
            
        }
    }
    
    func updateHotelSort(viewController: HotelSortController, didUpdateSort sort: String) {
        self.webView.evaluateJavaScript(
            "window.JSAPI.setHotelSort(\"\(sort)\")",
            completionHandler: nil)
    }
    
    func updateHotelFilter(minPrice: String, maxPrice: String) {
        _minPrice = minPrice
        _maxPrice = maxPrice
        
        let minPrice = minPrice == "" ? "null" : minPrice
        let maxPrice = maxPrice == "" ? "null" : maxPrice
        
        let priceFilter = PriceFilter(minPrice: minPrice, maxPrice: maxPrice)
        
        self.webView.evaluateJavaScript(
            "window.JSAPI.setHotelFilters(\(priceFilter.asJSONString))",
            completionHandler: nil)
        
        updateResultsCounter()
    }
    
    func updateResultsCounter(){
        let jsString = "document.getElementsByTagName(\"li\").length"
        
        self.webView.evaluateJavaScript(
            jsString, completionHandler:{(data, err) in
                let count = data as! Int
                self.navigationTitle.title = "\(count) Hotel(s) Found"
        })
    }
}
