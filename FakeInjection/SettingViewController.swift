//
//  SettingViewController.swift
//  FakeInjection
//
//  Created by Kohei Oyama on 2017/07/19.
//  Copyright © 2017年 Kohei Oyama. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var placeSettingPicker: UIPickerView!
    
    @IBOutlet weak var timeSettingPicker: UIPickerView!

    @IBOutlet weak var modeButton: UIButton!

    var isModeReverse: Bool = true

    let placeSettingArray: [String] = ["lab", "home", "uTokyo", "manual mode"]
    var place: String = ""
    var placeURL: PlaceURL = .lab

    let timeSettingArray: [Int] = [1,3,5,10,15,20,25,30]
    var time: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        placeSettingPicker.delegate = self
        placeSettingPicker.dataSource = self

        timeSettingPicker.delegate = self
        timeSettingPicker.dataSource = self

        performSegue(withIdentifier: "showViewController", sender: time)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapModeButton(_ sender: UIButton) {
        isModeReverse = !isModeReverse
        if isModeReverse {
            modeButton.setTitle("R", for: .normal)
        } else {
            modeButton.setTitle("N", for: .normal)
        }
    }

    @IBAction func tapOKButton(_ sender: UIButton) {
        performSegue(withIdentifier: "showViewController", sender: time)
    }
}

extension SettingViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var res: String?
        if pickerView == placeSettingPicker {
            res =  String(placeSettingArray[row])
        } else if pickerView == timeSettingPicker {
            res =  String(timeSettingArray[row])
        }
        return res
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == placeSettingPicker {
            place = placeSettingArray[row]
        } else if pickerView == timeSettingPicker {
            time = timeSettingArray[row]
        }
    }

    // 遷移先のViewに値の受け渡し
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showViewController" {
            let secondViewController = segue.destination as! ViewController
            /*switch place {
            case "lab":
                placeURL = .lab
            case "home":
                placeURL = .home
            case "uTokyo":
                placeURL = .uTokyo
            case "manual mode":
                placeURL = .manual
            default:
                placeURL = .lab
            }
            secondViewController.placeURL = placeURL
            secondViewController.reverseTime = time
            secondViewController.isModeReverse = isModeReverse*/

            // Xcodeのビルドで実験するならXcode側で決め打つ
            secondViewController.reverseTime = 15
            secondViewController.isModeReverse = true
            //secondViewController.isModeReverse = false
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
        if pickerView == placeSettingPicker {
            count = placeSettingArray.count
        } else if pickerView == timeSettingPicker {
            count = timeSettingArray.count
        }
        return count
    }
}

