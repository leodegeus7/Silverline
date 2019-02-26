//
//  ViewController.swift
//  CustomerApp
//
//  Created by Leonardo Geus on 22/02/19.
//  Copyright © 2019 Leonardo Geus. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    var db : Firestore!
    var areas = [Area]()
    var colors:[UIColor] = [UIColor.red,
                            UIColor.blue,
                            UIColor.purple,
                            UIColor.green,
                            UIColor.orange,
                            UIColor.magenta]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        tagsCollectionView.delegate = self
        tagsCollectionView.dataSource = self
        let layout = tagsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.estimatedItemSize = CGSize(width: 200, height: 80)
        // Do any additional setup after loading the view, typically from a nib.
        
        getAreas { (areas) in
            self.areas = areas
            self.areas.removeAll(where: {$0.name == "all"})
            self.tagsCollectionView.reloadData()

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
        if textField.text != "" {
            perfomedCustomer(name: textField.text!, area: areas[indexPath.row].name!)
        } else {
            let alert = UIAlertController(title: "Alert", message: "Insira um nome", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        tagsCollectionView.reloadData()
    }
    
    func perfomedCustomer(name:String,area:String) {
        let url = URL(string: "https://us-central1-silverline-c3342.cloudfunctions.net/addCustomer?name=\(name)&area=\(area)")!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
        }
        textField.text = ""
        task.resume()
    }
    
}
