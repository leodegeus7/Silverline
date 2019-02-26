//
//  ChooseViewController.swift
//  SilverlineSwift
//
//  Created by Leonardo Geus on 21/02/19.
//  Copyright © 2019 Leonardo Geus. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ChooseViewController: UIViewController {
        var db : Firestore!
    @IBOutlet weak var attendantTableView: UITableView!
    var colors:[UIColor] = [UIColor.red,
                            UIColor.blue,
                            UIColor.purple,
                            UIColor.green,
                            UIColor.orange,
                            UIColor.magenta]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        attendantTableView.dataSource = self
        attendantTableView.delegate = self
        attendantTableView.estimatedRowHeight = 120
        attendantTableView.rowHeight = UITableView.automaticDimension
        // Do any additional setup after loading the view.

        self.getAttendants() { (attendants) in
            self.attendants = attendants
            self.attendantTableView.reloadData()
        }
    }
    
    var attendants = [Attendant]()
    var areas = [Area]()
    var selectedAttendant:Attendant!
    
    func getAttendants(completion: @escaping (_ result: [Attendant]) -> Void) {
        
        db.collection("attendants").addSnapshotListener { (querySnapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                var attendants = [Attendant]()
                for document in querySnapshot!.documents {
                    
                    if let areas = document.data()["areas"] as? [String] {
                        if let name = document.data()["name"] as? String {
                            attendants.append(Attendant.init(name: name, areas: areas.map({Area(name: $0, color: UIColor.clear)}), id: document.documentID))
                        }
                    }
                }
                completion(attendants)
            }
        }
    }
    
    @IBAction func chooseTap(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as? ViewController
        controller!.attendant = selectedAttendant
    }
}

extension ChooseViewController:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendants.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = attendants[indexPath.row].name
        return cell
    }
}

extension ChooseViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAttendant = attendants[indexPath.row]
        self.performSegue(withIdentifier: "segueToDetail", sender: self)
    }
}

