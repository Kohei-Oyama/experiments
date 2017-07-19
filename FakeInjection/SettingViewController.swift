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


    let settingArray: [Int] = [1,3,5,10,15,20,25,30]
    var time: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        timeSettingPicker.delegate = self
        timeSettingPicker.dataSource = self
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
        return String(settingArray[row])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        time = settingArray[row]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showViewController" {
            let secondViewController = segue.destination as! ViewController
            secondViewController.time = time
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
        return settingArray.count
    }
}

