//
//  CountryCollectionsController.swift
//  KOControlsExample
//
//  Created by Kuba Ostrowski on 25.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

class CountryCollectionsController: NSObject, UICollectionViewDataSource, UITableViewDataSource{
    //MARK: Variables
    private let countryTableViewCellKey = "countryTableViewCell"
    private let countryCollectionViewCellKey = "countryCollectionViewCell"
    
    private weak var collectionView : UICollectionView?
    private weak var tableView : UITableView?
    
     //public
    private(set) var currentVisibleCountries : [CountryModel] = []
    let countries : [CountryModel]
   
    var collectionViewSetupCell : ((CountryCollectionViewCell)->Void)? = nil
    var tableViewSetupCell : ((CountryTableViewCell)->Void)? = nil
    
    //MARK: - Methods
    //MARK: Initialize
    override init() {
        countries = AppSettings.countries
        currentVisibleCountries = countries
        super.init()
    }
    
    //MARK: Public
    func attach(collectionView : UICollectionView){
        collectionView.register(UINib(nibName: "CountryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: countryCollectionViewCellKey)
        collectionView.dataSource = self
        self.collectionView = collectionView
    }
    
    func attach(tableView : UITableView){
        tableView.register(UINib(nibName: "CountryTableViewCell", bundle: nil), forCellReuseIdentifier: countryTableViewCellKey)
        tableView.dataSource = self
        self.tableView = tableView
    }
    
    func searchForCountries(byName name: String){
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedName.isEmpty else{
            currentVisibleCountries = countries
            return
        }
        currentVisibleCountries = countries.filter({$0.name.lowercased().contains(trimmedName)})
        tableView?.reloadData()
        collectionView?.reloadData()
    }
    
    func startSearchedCountries(byName name: String){
        
    }
    
    func stopSearchedCountries(byName name : String){
        
    }
    
    func calculateCollectionSize(_ collectionView : UICollectionView, availableWidth : CGFloat, itemMaxWidth : Double){
        let inset : CGFloat = 4
        let itemMargin = 2.0
        let parentWidth = Double((availableWidth) - inset * 2)
        let divider = max(2.0,(Double(parentWidth)) / itemMaxWidth)
        let column = floor(divider)
        let allMargin = (itemMargin * (column - 1))
        let itemSize = (Double(parentWidth) / column) - allMargin
        let lineSpacing = max(4.0, ((Double(parentWidth) - allMargin) - (column * itemSize)) / column)
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.minimumInteritemSpacing = CGFloat(itemMargin) * 2
        flowLayout.minimumLineSpacing = CGFloat(lineSpacing)
        flowLayout.itemSize = CGSize(width: itemSize, height: itemSize)
        flowLayout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    //MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentVisibleCountries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: countryCollectionViewCellKey, for: indexPath) as! CountryCollectionViewCell
        guard indexPath.row < currentVisibleCountries.count else{return cell}
        cell.countryModel = currentVisibleCountries[indexPath.row]
        collectionViewSetupCell?(cell)
        return cell
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentVisibleCountries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: countryTableViewCellKey, for: indexPath) as! CountryTableViewCell
        guard indexPath.row < currentVisibleCountries.count else{return cell}
        cell.countryModel = currentVisibleCountries[indexPath.row]
        tableViewSetupCell?(cell)
        return cell
    }
}

