//
//  SettingViewController.swift
//  FakeInjection
//
//  Created by Kohei Oyama on 2017/07/19.
//  Copyright © 2017年 Kohei Oyama. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var timeSettingPicker: UIPickerView!

    @IBOutlet weak var personSettingPicker: UIPickerView!

    let timeSettingArray: [Int] = [1,3,5,10,15,20,25,30]
    var time: Int = 0

    let personSettingArray: [String] = ["Oyama","Omata","Kuwabara","Takahashi","Yoshida","Mikami","Sugiyama"]
    var person: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        timeSettingPicker.delegate = self
        timeSettingPicker.dataSource = self

        personSettingPicker.delegate = self
        personSettingPicker.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapOKButton(_ sender: UIButton) {
        performSegue(withIdentifier: "showViewController", sender: time)
    }
}

extension SettingViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var res: String?
        if pickerView == timeSettingPicker {
            res =  String(timeSettingArray[row])
        } else {
            res =  String(personSettingArray[row])
        }
        return res
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == timeSettingPicker {
            time = timeSettingArray[row]
        } else {
            person = personSettingArray[row]
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showViewController" {
            let secondViewController = segue.destination as! ViewController
            secondViewController.time = time
            secondViewController.person = person
        }
    }

}

extension SettingViewController: UIPickerViewDataSource {
    // 列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // 行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count: Int = 0
        if pickerView == timeSettingPicker {
            count = timeSettingArray.count
        } else {
            count = personSettingArray.count
        }
        return count
    }
}

