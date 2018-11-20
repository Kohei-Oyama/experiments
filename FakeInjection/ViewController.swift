//
//  ViewController.swift
//  FakeInjection
//
//  Created by Kohei Oyama on 2017/07/12.
//  Copyright © 2017年 Kohei Oyama. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos
import APIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var startButton: UIButton!

    var timer = Timer()
    var startTime: TimeInterval = 0     // Startボタンを押した時刻
    var timeCount : Double = 0.0             // ラベルに表示する時間
    var timerLabel: UILabel!     // タイムを表示するラベル

    var mySession : AVCaptureSession! // セッション
    var myDevice : AVCaptureDevice! // カメラデバイス
    var myFileOutput: AVCaptureMovieFileOutput! // 保存先
    var filePathBefore: String! // 録画ファイルパス
    var fileURLBefore: URL!
    var filePathAfter: String! // 編集ファイルパス
    var fileURLAfter: URL!
    var placeURL: PlaceURL! //場所URL
    var reverseTime: Int = 0 //折り返す秒数
    var isModeReverse: Bool = true // 逆再生するか否か

    var flag0 = true
    var flag1 = true
    var flag2 = true
    var flag3 = true
    var flag4 = true

    var requestConditions: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        filePathBefore = NSHomeDirectory() + "/Documents/test.mp4"
        filePathAfter = NSHomeDirectory() + "/Documents/out.mp4"
        fileURLBefore = URL(fileURLWithPath: filePathBefore)
        fileURLAfter = URL(fileURLWithPath: filePathAfter)

        // カメラ準備
        initCamera()

        // タイマーを画面右上にセット
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        view.backgroundColor = UIColor.black
        let item = UIBarButtonItem(customView: view)
        self.navigationItem.rightBarButtonItem = item
        timerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        timerLabel.font = UIFont.systemFont(ofSize: 30)
        timerLabel.textColor = UIColor.white
        view.addSubview(timerLabel)
    }

    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.startRecord()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapStart(_ sender: UIButton) {
        startRecord()
    }

    // 実験開始
    func startRecord() {
        self.requestConditions = false
        startButton.isHidden = true
        // タイマー開始
        startTime = Date().timeIntervalSince1970
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        if isModeReverse {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: fileURLAfter.path) {
                try! fileManager.removeItem(atPath: filePathAfter)
            }
            // 録画開始
            myFileOutput.startRecording(toOutputFileURL: fileURLBefore, recordingDelegate: self)
        }
    }

    func update() {
        timeCount = Date().timeIntervalSince1970 - startTime
        let sec = Int(timeCount)
        let msec = Int((timeCount - Double(sec)) * 100)
        let displayStr = NSString(format: "%02d", sec%60) as String
        timerLabel.text = displayStr

        if msec < 50 {
            // 逆再生前に赤くなる
            if sec == reverseTime - reverseTime/5 && flag0 {
                flag0 = false
                imageView.layer.borderColor = UIColor.red.cgColor
                imageView.layer.borderWidth = 8.0
            }

            // ブラックアウト前に赤くなる
            if sec == 2*reverseTime-(reverseTime/5)+1 && flag1 {
                flag1 = false
                imageView.layer.borderColor = UIColor.red.cgColor
                imageView.layer.borderWidth = 8.0
            }

            // ブラックアウト後も赤くなる
            if sec == 2*reverseTime + reverseTime/3 && flag2 {
                flag2 = false
                imageView.layer.borderColor = UIColor.red.cgColor
                imageView.layer.borderWidth = 8.0
            }

            // 指定秒数で赤が消える (録画終了)
            if sec == reverseTime && flag3 {
                flag3 = false
                imageView.layer.borderWidth = 0
                if isModeReverse {
                    mySession.stopRunning()
                    myFileOutput.stopRecording()
                }
            }
            // 指定秒数の2倍時間で終了する
            if sec == 2*reverseTime && flag4 {
                flag4 = false
                imageView.layer.borderWidth = 0
                let view = UIView(frame: self.imageView.bounds)
                view.backgroundColor = UIColor.black
                self.imageView.addSubview(view)
                if isModeReverse {
                    self.mySession = nil
                    self.myDevice = nil
                }
            }
        }
        // 終了したらセッティング画面に戻る
        if sec > 2*reverseTime + 2*(reverseTime/3) {
            self.navigationController?.popViewController(animated: true)
            flag0 = true
            flag1 = true
            flag2 = true
            flag3 = true
            flag4 = true
        }
    }

    // カメラの準備処理
    func initCamera() {
        // セッション作成とクオリティ設定
        let session: AVCaptureSession = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetMedium
        // デバイスの取得とFPS設定
        let device: AVCaptureDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
        device.activeVideoMinFrameDuration = CMTimeMake(1, 30)

        // VideoInputを取得、出力先を設定
        let videoInput: AVCaptureDeviceInput = try! AVCaptureDeviceInput.init(device: device)
        myFileOutput = AVCaptureMovieFileOutput()
        // セッションに追加.
        session.addInput(videoInput)
        session.addOutput(myFileOutput)

        myDevice = device
        mySession = session

        // プレビュー
        if let videoLayer = AVCaptureVideoPreviewLayer.init(session: mySession) {
            videoLayer.frame = imageView.bounds
            imageView.layer.addSublayer(videoLayer)
        }
        mySession.startRunning()
    }

    func fetchStartRequest(callback: (() -> Void)? = nil){
        var request = GetConditionsRequest()
        // request.baseURL = URL(string: placeURL.rawValue)!
        Session.send(request) { result in
            switch result {
            case .success(let conditions):
                // サーバから取得した条件をセット
                self.reverseTime = conditions.time
                self.isModeReverse = conditions.isModeReverse
                if let callback = callback {
                    callback()
                }
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }
}

extension ViewController: AVCaptureFileOutputRecordingDelegate {
    // 録画完了
    public func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {

        DispatchQueue.global().async {
            let avAsset = AVAsset(url: self.fileURLBefore)
            AVUtilities.reverse(avAsset, outputURL: self.fileURLAfter, completion: { [unowned self] (reversedAsset: AVAsset) in
                let playerItem = AVPlayerItem(asset: reversedAsset)
                let videoPlayer = AVPlayer(playerItem: playerItem)
                let playerLayer = AVPlayerLayer(player: videoPlayer)
                DispatchQueue.main.async(execute: {
                    self.imageView.layer.borderWidth = 0
                    playerLayer.frame = self.imageView.bounds
                    self.imageView.layer.addSublayer(playerLayer)
                    videoPlayer.play()
                })
            })
        }

    }
}

