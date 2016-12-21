//
//  AddWorldClockView.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/28.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import RealmSwift
import UIKit
import SwiftyTimer

class AddWorldClockViewController: UIViewController {
    
    var indexes: [String] = []
    var cities: [String: [City]] = [:]
    
    var searchList: [String: [(name: String, id: Int)]] = [:]
    var searchCityController: SearchCityViewController = SearchCityViewController()
    
    @IBOutlet weak var cityTableView: UITableView!
    
    fileprivate lazy var searchController: UISearchController = {
        $0.delegate = self
        $0.searchResultsUpdater = self;
        $0.searchBar.tintColor = UIColor.white
        $0.searchBar.barTintColor = UIColor.getGreyColor()
        $0.hidesNavigationBarDuringPresentation = false;
        return $0
    }(UISearchController(searchResultsController: self.searchCityController))
    
    fileprivate lazy var realm:Realm = {
        try! Realm()
    }()
    
    var currentCity: City?
    
    init() {
        super.init(nibName: "AddWorldClockViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeData()
        getLocation()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Timer.after(5) { 
            if let _ = self.currentCity {
                self.cityTableView.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
            } else {
                let cell = self.cityTableView.cellForRow(at: IndexPath.init(row: 0, section: 0))
                cell?.textLabel?.text = "Failure to locate..."
            }
        }
    }
}

extension AddWorldClockViewController {
    func initializeData() {
        for city in Array(realm.objects(City.self)) {
            let character:String = String(city.name[city.name.startIndex]).uppercased()
            if var list = cities[character] {
                list.append(city)
                cities[character] = list
            }else{
                cities[character] = [city]
            }
        }
        
        indexes = Array(cities.keys).sorted(by: { $0 < $1 })
    }
    
    
    func getLocation() {
        HomeClockUtil.shared.getLocation { (city) in
            if let city = city {
                self.currentCity = city
                self.cityTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
        }
    }
    
    func dismissController(){
        if let _ = HomeClockUtil.shared.getHomeCityWithSelectedFlag() {
            
        } else if let city = currentCity {
            didChooseCity(city)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func didChooseCity(_ city:City){
        if city.id > 0 {
            HomeClockUtil.shared.saveHomeCity(city: city)
        } else {
            HomeClockUtil.shared.saveHomeCityWithLocatingKey(city: city)
        }
        
        searchController.isActive = false
        
        dismissController()
    }
    
    func setupView() {
        self.navigationItem.title = NSLocalizedString("Choose_home_city", comment: "")
        definesPresentationContext = true
        cityTableView.separatorColor = UIColor.white
        cityTableView.sectionIndexBackgroundColor = UIColor.transparent()
        cityTableView.sectionIndexColor = UIColor.white
        cityTableView.backgroundColor = UIColor.getGreyColor()
        searchCityController.delegate = self

        let searchView:UIView = UIView(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: searchController.searchBar.frame.size.height))
        searchView.backgroundColor = UIColor.getTintColor()
        searchView.addSubview(searchController.searchBar)
        cityTableView.tableHeaderView = searchView
        
        let button: UIButton = UIButton(type: UIButtonType.custom)
        button.setImage(UIImage(named: "cancel_lunar")!, for: UIControlState())
        button.addTarget(self, action: #selector(dismissController), for: UIControlEvents.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
}

// MARK: - UISearchControllerDelegate
extension AddWorldClockViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        debugLog("willPresentSearchController")
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        debugLog("didPresentSearchController")
    }
    func willDismissSearchController(_ searchController: UISearchController) {
        searchCityController.setSearchList( [:])
        debugLog("willDismissSearchController")
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        debugLog("didDismissSearchController")
        if searchController.isActive {
            dismissController()
        }
    }
    
    func presentSearchController(_ searchController: UISearchController) {
        debugLog("presentSearchController")
    }
}

// MARK: - UISearchResultsUpdatin
extension AddWorldClockViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        debugLog("updateSearchResultsForSearchController")
        if self.searchController.searchBar.text != nil {
            let searchString:String = self.searchController.searchBar.text!
            searchList.removeAll()
            for cityWithIndex in self.cities {
                for city in cityWithIndex.1 {
                    
                    if (city.name.lowercased().range(of: searchString.lowercased()) != nil || city.country.lowercased().range(of: searchString.lowercased()) != nil) {
                        if var array = searchList[cityWithIndex.0]{
                            array.append(("\(city.name), \(city.country)",city.id))
                            searchList[cityWithIndex.0] = array
                        }else{
                            searchList[cityWithIndex.0] = [("\(city.name), \(city.country)",city.id)]
                        }
                    }
                }
            }
            if searchList.count > 0 {
                searchCityController.setSearchList(searchList)
                searchCityController.tableView.reloadData()
            }else{
                searchCityController.setSearchList([:])
                searchCityController.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension AddWorldClockViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        if indexPath.section == 0 {
            if let city = currentCity {
                didChooseCity(city)
            } else {
                dismissController()
            }
        } else {
            let city = cities[indexes[indexPath.section - 1]]![indexPath.row]
            didChooseCity(city)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if [0, 1].contains(section) {
            return 40
        } else {
            return 0
        }
    }
}

// MARK: - UITableViewDataSource
extension AddWorldClockViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return indexes.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if let unwrappedCities = cities[indexes[section - 1]]{
                return unwrappedCities.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        }
        
        cell?.textLabel?.font = UIFont(name: "Helvetica-Light", size: 15.0)
        cell?.textLabel?.textColor = UIColor.white
        cell?.backgroundColor = UIColor.getGreyColor()
        
        if indexPath.section == 0 {
            if let city = currentCity {
                cell?.textLabel?.text = "\(city.country), \(city.name)"
            } else {
                cell?.textLabel?.text = "Locating..."
            }
            
        } else {
            let sectionName: String = self.indexes[indexPath.section - 1]
            if let citiesForSection:[City] = self.cities[sectionName]{
                cell?.textLabel?.text = "\(citiesForSection[indexPath.row].name), \(citiesForSection[indexPath.row].country)"
            }
        }
        
        return cell!;
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexes
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return self.indexes.index(of: title)! + 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica-Light", size: 17.0)
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.getLightBaseColor()
        
        if section == 0 {
            label.text = "  " + NSLocalizedString("locating_city", comment: "")
        } else {
            label.text = "  " + NSLocalizedString("all_city", comment: "")
        }
        return label
    }
}

// MARK: HomeCityProtocol
extension AddWorldClockViewController: HomeCityDidSelectedProtocol {
    func didSelectedHomeCity(cityId: Int) {
        if let city = realm.objects(City.self).filter("id = \(cityId)").first {
            didChooseCity(city)
        }
    }
}
