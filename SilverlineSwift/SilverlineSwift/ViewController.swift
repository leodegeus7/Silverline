//
//  ViewController.swift
//  SilverlineSwift
//
//  Created by Leonardo Geus on 21/02/19.
//  Copyright © 2019 Leonardo Geus. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ViewController: UIViewController {

    @IBOutlet weak var textFieldAttendant: UITextField!
    @IBOutlet weak var tableViewCustomers: UITableView!
    @IBOutlet weak var collectionViewTags: UICollectionView!
    
    @IBOutlet weak var callCustomerButton: UIButton!
    @IBOutlet weak var attendantLabel: UILabel!
    var db : Firestore!
    var filteredCustomers = [Customer]()
    var attendant: Attendant!
    var colors:[UIColor] = [UIColor.red,
                            UIColor.blue,
                            UIColor.purple,
                            UIColor.green,
                            UIColor.orange,
                            UIColor.magenta]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        tableViewCustomers.dataSource = self
        tableViewCustomers.delegate = self
        tableViewCustomers.estimatedRowHeight = 120
        tableViewCustomers.rowHeight = UITableView.automaticDimension
        collectionViewTags.delegate = self
        collectionViewTags.dataSource = self
        let layout = collectionViewTags.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.estimatedItemSize = CGSize(width: 200, height: 80)
        callCustomerButton.layer.cornerRadius = callCustomerButton.frame.height/2
        callCustomerButton.layer.masksToBounds = true
        
        attendantLabel.text = attendant.name
        getAreas { (areas) in
            self.areas = areas
            self.collectionViewTags.reloadData()
            self.getCustomers(areas: areas) { (customers) in
                self.customers = customers
                self.blockButton()
                self.tableViewCustomers.reloadData()
            }
        }

    }
    
    func blockButton() {
        let are = areas.filter({$0.isActive!})
        filteredCustomers = customers.filter { (customer) -> Bool in
            return are.contains(where: {$0.name == customer.area?.name})
        }
        let count =  filteredCustomers.count
        if count == 0 {
            callCustomerButton.isEnabled = false
            callCustomerButton.backgroundColor = UIColor.gray
        } else {
            callCustomerButton.isEnabled = true
            callCustomerButton.backgroundColor = UIColor.black.withAlphaComponent(1)
        }
    }
    @IBAction func initAttendantTap(_ sender: Any) {
    }
    
    var customers = [Customer]()
    var areas = [Area]()
    
    func getCustomers(areas:[Area],completion: @escaping (_ result: [Customer]) -> Void) {

        db.collection("customers").addSnapshotListener { (querySnapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                var customers = [Customer]()
                for document in querySnapshot!.documents {
                            customers.append(Customer.init(name: document.data()["name"] as? String, area: areas.first(where: {$0.name == document.data()["area"] as? String}), id: document.documentID,datetime:(document.data()["datetime"] as! Timestamp).dateValue()))
                }
                customers = customers.sorted(by: {($0.datetime?.timeIntervalSince1970)! < $1.datetime!.timeIntervalSince1970})
                completion(customers)
            }
        }
    }
    

    func getAreas(completion: @escaping (_ result: [Area]) -> Void) {
        db.collection("areas").addSnapshotListener { (querySnapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                var areas = [Area]()
                var strings = [String]()
                for document in querySnapshot!.documents {
                    strings.append((document.data()["name"] as? String)!)
                }
                
                strings = strings.sorted(by: {$0 < $1})
                strings.append("all")
                var count = 0
                for string in strings {
                    areas.append(Area.init(name: string, color: self.colors[count]))
                    count = count + 1
                }
                completion(areas)
            }
        }
    }
    @IBAction func callCustomer(_ sender: Any) {
        let url = URL(string: "https://us-central1-silverline-c3342.cloudfunctions.net/getCustomer?attendant=\(attendant.id ?? "")")!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
        }
        
        task.resume()
    }
    
    func perfomedWithId(customerId:String) {
        let url = URL(string: "https://us-central1-silverline-c3342.cloudfunctions.net/getCustomerWithId?attendant=\(attendant.id ?? "")&customerId=\(customerId)")!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
        }
        
        task.resume()
    }
    
    
}

extension ViewController:UITableViewDataSource,UITableViewDelegate {
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let are = areas.filter({$0.isActive!})
        filteredCustomers = customers.filter { (customer) -> Bool in
            return are.contains(where: {$0.name == customer.area?.name})
        }
        return filteredCustomers.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let customerId = customers[indexPath.row].id!
        perfomedWithId(customerId: customerId)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCell", for: indexPath) as? CustomerCellTableViewCell
        cell?.nameLabel.text = filteredCustomers[indexPath.row].name
        cell?.tagLabel.text = filteredCustomers[indexPath.row].area?.name
        cell?.tagLabel.textColor = UIColor.white
        cell?.tagLabel.layer.cornerRadius = (cell?.tagLabel.frame.height)!/2
        cell?.tagLabel.layer.masksToBounds = true
        cell?.tagLabel.backgroundColor = filteredCustomers[indexPath.row].area?.color
        cell?.countLabel.text = "\(indexPath.row + 1)"
        return cell!
    }
}

extension ViewController:UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return areas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as? TagCollectionViewCell
        cell?.label.text = areas[indexPath.row].name
        cell?.label.textColor = UIColor.white
        cell?.label.layer.cornerRadius = (cell?.label.frame.height)!/2
        cell?.label.layer.masksToBounds = true
        if areas[indexPath.row].isActive == true {
            cell?.label.backgroundColor = areas[indexPath.row].color
        } else {
            cell?.label.backgroundColor = UIColor.gray
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell else { return }
        if cell.label.text == "all" {
            if ((areas.first(where: {$0.name == "all"})?.isActive)!) {
                for area in areas {
                    area.isActive = false
                }
            } else {
                for area in areas {
                    area.isActive = true
                }
            }
           
        } else {
            if ((areas.first(where: {$0.name == cell.label.text})?.isActive)!) {
                areas.first(where: {$0.name == cell.label.text})?.isActive = false
                if ((areas.first(where: {$0.name == "all"})?.isActive)!) {
                    areas.first(where: {$0.name == "all"})?.isActive = false
                }
            } else {
                areas.first(where: {$0.name == cell.label.text})?.isActive = true
            }
        }
        
        attendant.areas = areas.filter({$0.isActive!})
        
        self.blockButton()
        
        db.collection("attendants").document(attendant.id!).setData(["areas":attendant.areas!.map({$0.name})], merge: true)
        
        tableViewCustomers.reloadData()
        collectionViewTags.reloadData()
    }
    
}
