//
//  AlarmViewController.swift
//  Alarmadillo
//
//  Created by Tanner Quesenberry on 3/26/19.
//  Copyright © 2019 Tanner Quesenberry. All rights reserved.
//

import UIKit

class AlarmViewController: UITableViewController {

    @IBOutlet var name: UITextField!
    @IBOutlet var caption: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var tapToSelectImage: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        
    }
    
    @IBAction func imageViewTapped(_ sender: Any) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
