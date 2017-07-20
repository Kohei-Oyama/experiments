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

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var startButton: UIButton!

    var mySession : AVCaptureSession! // セッション
    var myDevice : AVCaptureDevice! // カメラデバイス
    var myFileOutput: AVCaptureMovieFileOutput! // 保存先
    var filePathBefore: String! // 録画ファイルパス
    var fileURLBefore: URL!
    var filePathAfter: String! // 編集ファイルパス
    var fileURLAfter: URL!
    var time: Int = 0 //折り返す秒数

    override func viewDidLoad() {
        super.viewDidLoad()

        filePathBefore = NSHomeDirectory() + "/Documents/test.mp4"
        filePathAfter = NSHomeDirectory() + "/Documents/out.mp4"
        fileURLBefore = URL(fileURLWithPath: filePathBefore)
        fileURLAfter = URL(fileURLWithPath: filePathAfter)
        // カメラ準備
        initCamera()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapStart(_ sender: UIButton) {
        startButton.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURLAfter.path) {
            try! fileManager.removeItem(atPath: filePathAfter)
        }
        // 録画開始
        myFileOutput.startRecording(toOutputFileURL: fileURLBefore, recordingDelegate: self)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(time)) {
            self.mySession.stopRunning()
            self.myFileOutput.stopRecording()
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
            //videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
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

        startButton.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
        initCamera()
    }
}

extension ViewController: AVCaptureFileOutputRecordingDelegate {
    // 録画完了
    public func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {

        let avAsset = AVAsset(url: fileURLBefore)
        AVUtilities.reverse(avAsset, outputURL: fileURLAfter, completion: { [unowned self] (reversedAsset: AVAsset) in
            let playerItem = AVPlayerItem(asset: reversedAsset)
            let videoPlayer = AVPlayer(playerItem: playerItem)
            let playerLayer = AVPlayerLayer(player: videoPlayer)
            NotificationCenter.default.addObserver(self, selector: #selector(ViewController.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)

            DispatchQueue.main.async(execute: {
                playerLayer.frame = self.imageView.bounds
                //playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.imageView.layer.addSublayer(playerLayer)
                videoPlayer.play()
            })
        })
    }
}

