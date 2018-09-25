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
    
    let countries : [CountryModel]
    
    //public
    var collectionViewSetupCell : ((CountryCollectionViewCell)->Void)? = nil
    var tableViewSetupCell : ((CountryTableViewCell)->Void)? = nil
    
    //MARK: - Methods
    //MARK: Initialize
    override init() {
        countries = AppSettings.countries
        super.init()
    }
    
    //MARK: Public
    func attach(collectionView : UICollectionView){
        collectionView.register(UINib(nibName: "CountryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: countryCollectionViewCellKey)
        collectionView.dataSource = self
    }
    
    func attach(tableView : UITableView){
        tableView.register(UINib(nibName: "CountryTableViewCell", bundle: nil), forCellReuseIdentifier: countryTableViewCellKey)
        tableView.dataSource = self
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
        return countries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: countryCollectionViewCellKey, for: indexPath) as! CountryCollectionViewCell
        cell.countryModel = countries[indexPath.row]
        collectionViewSetupCell?(cell)
        return cell
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: countryTableViewCellKey, for: indexPath) as! CountryTableViewCell
        cell.countryModel = countries[indexPath.row]
        tableViewSetupCell?(cell)
        return cell
    }
}

