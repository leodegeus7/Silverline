//
//  ViewController.swift
//  WallApp
//
//  Created by Leonardo Geus on 22/02/19.
//  Copyright © 2019 Leonardo Geus. All rights reserved.
//

import UIKit
import FirebaseFirestore
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var attendantLabel: UILabel!
    
    var db : Firestore!
    
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        getPerfomed { (perfomed) in
            print(perfomed.last!)
            if perfomed.last!.attendant!.count == 20 {
            self.getAttendant(id: perfomed.last!.attendant!, completion: { (string) in
                self.nameLabel.text = "Nome: \(perfomed.last!.customer ?? "")"
                self.areaLabel.text = "Área: \(perfomed.last!.area ?? "")"
                self.attendantLabel.text = "Atendente: \(string)"
            })
            } else {
                self.nameLabel.text = "Nome: \(perfomed.last!.customer ?? "")"
                self.areaLabel.text = "Área: \(perfomed.last!.area ?? "")"
                self.attendantLabel.text = "Atendente: \(perfomed.last!.attendant ?? "")"
            }
            self.beepSound()
        }
    }
    
    func beepSound() {
        let alertSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "beep", ofType: "wav")!)
        
        // Removed deprecated use of AVAudioSessionDelegate protocol
        try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        try! AVAudioSession.sharedInstance().setActive(true, options: [])
        

        audioPlayer = try! AVAudioPlayer(contentsOf: alertSound as URL)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }


    func getPerfomed(completion: @escaping (_ result: [Perfomed]) -> Void) {
        db.collection("perfomed").order(by: "date").addSnapshotListener { (querySnapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                var perfomed = [Perfomed]()
                for document in querySnapshot!.documents {
                    let perfo = Perfomed.init(area: document.data()["area"] as? String, attendant: document.data()["attendant"] as? String, customer: document.data()["customer"] as? String, date: document.data()["date"] as? String)
                    perfomed.append(perfo)
                }
                if querySnapshot!.documents.count > 0 {
                    completion(perfomed)
                }
            }
        }
    }
    
    func getAttendant(id:String,completion: @escaping (_ result: String) -> Void) {
        db.collection("attendants").document(id).addSnapshotListener { (querySnapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                completion((querySnapshot?.data()!["name"] as? String)!)
            }
        }
    }
}
