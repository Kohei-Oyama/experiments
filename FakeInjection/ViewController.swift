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
    var labelTimer: UILabel!     // タイムを表示するラベル

    var mySession : AVCaptureSession! // セッション
    var myDevice : AVCaptureDevice! // カメラデバイス
    var myFileOutput: AVCaptureMovieFileOutput! // 保存先
    var filePathBefore: String! // 録画ファイルパス
    var fileURLBefore: URL!
    var filePathAfter: String! // 編集ファイルパス
    var fileURLAfter: URL!
    var placeURL: PlaceURL = .lab //場所によるURL
    var time: Int = 0 //折り返す秒数
    var person: String = "" //被験者

    override func viewDidLoad() {
        super.viewDidLoad()

        filePathBefore = NSHomeDirectory() + "/Documents/test.mp4"
        filePathAfter = NSHomeDirectory() + "/Documents/out.mp4"
        fileURLBefore = URL(fileURLWithPath: filePathBefore)
        fileURLAfter = URL(fileURLWithPath: filePathAfter)
        // カメラ準備
        initCamera()

        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        view.backgroundColor = UIColor.black
        let item = UIBarButtonItem(customView: view)
        self.navigationItem.rightBarButtonItem = item

        labelTimer = UILabel(frame: CGRect(x: 5, y: 5, width: 100, height: 20))
        labelTimer.textColor = UIColor.white
        view.addSubview(labelTimer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapStart(_ sender: UIButton) {
        startButton.isHidden = true
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURLAfter.path) {
            try! fileManager.removeItem(atPath: filePathAfter)
        }
        // 録画開始
        fetchStartRequest()
        myFileOutput.startRecording(toOutputFileURL: fileURLBefore, recordingDelegate: self)

        // 逆再生前に赤くなる
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(time-(time/6))) {
            for layer in self.imageView.layer.sublayers! {
                layer.borderColor = UIColor.red.cgColor
                layer.borderWidth = 8.0
            }
        }

        // 指定秒数で録画終了する
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(time)) {
            self.mySession.stopRunning()
            self.myFileOutput.stopRecording()
        }


        // ブラックアウト前に赤くなる
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2*time-(time/6))) {
            for layer in self.imageView.layer.sublayers! {
                layer.borderColor = UIColor.red.cgColor
                layer.borderWidth = 8.0
            }
        }

        // タイマーの表示
        DispatchQueue.main.async(execute: {
            self.startTime = Date().timeIntervalSince1970
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        })
    }

    func update() {
        timeCount = Date().timeIntervalSince1970 - startTime
        let sec = Int(timeCount)
        let msec = Int((timeCount - Double(sec)) * 100)
        let displayStr = NSString(format: "%02d:%02d.%02d", sec/60, sec%60, msec) as String
        labelTimer.text = displayStr
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

    // 逆再生後
    func playerItemDidReachEnd() {
        for output in self.mySession.outputs {
            self.mySession.removeOutput(output as? AVCaptureOutput)
        }
        for input in self.mySession.inputs {
            self.mySession.removeInput(input as? AVCaptureInput)
        }
        self.mySession = nil
        self.myDevice = nil

        for layer in self.imageView.layer.sublayers! {
            layer.removeFromSuperlayer()
        }

        fetchEndRequest()
        // ブラックアウト後も赤くなる
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(time/6)) {
            self.imageView.layer.borderColor = UIColor.red.cgColor
            self.imageView.layer.borderWidth = 8.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(time/3)) {
            // 終了したらセッティング画面に戻る
            self.navigationController?.popViewController(animated: true)
        }
    }

    func nowTime() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss:SSS"
        let now = Date()
        return formatter.string(from: now)
    }

    func fetchStartRequest(callback: (() -> Void)? = nil){
        let startTime = nowTime()
        var request = PostStartRequest(person: person, reverseTime: time, startTime: startTime)
        request.baseURL = URL(string: placeURL.rawValue)!
        Session.send(request) { result in
            switch result {
            case .success( _):
                if let callback = callback {
                    callback()
                }
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }

    func fetchReverseRequest(callback: (() -> Void)? = nil){
        let reverseTime = nowTime()
        var request = PostReverseRequest(reverseTime: reverseTime)
        request.baseURL = URL(string: placeURL.rawValue)!
        Session.send(request) { result in
            switch result {
            case .success( _):
                if let callback = callback {
                    callback()
                }
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }


    func fetchEndRequest(callback: (() -> Void)? = nil){
        let endTime = nowTime()
        var request = PostEndRequest(endTime: endTime)
        request.baseURL = URL(string: placeURL.rawValue)!
        Session.send(request) { result in
            switch result {
            case .success( _):
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
                NotificationCenter.default.addObserver(self, selector: #selector(ViewController.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)

                DispatchQueue.main.async(execute: {
                    self.fetchReverseRequest()
                    for layer in self.imageView.layer.sublayers! {
                        layer.borderWidth = 0
                    }
                    playerLayer.frame = self.imageView.bounds
                    self.imageView.layer.addSublayer(playerLayer)
                    videoPlayer.play()
                })
            })
        }

    }
}

