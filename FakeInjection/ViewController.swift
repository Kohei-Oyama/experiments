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

    @IBOutlet weak var imageViewLeft: UIImageView!
    
    @IBOutlet weak var imageViewRight: UIImageView!

    @IBOutlet weak var startButton: UIButton!

    var mySession : AVCaptureSession! // セッション
    var myDevice : AVCaptureDevice! // カメラデバイス
    var myFileOutput: AVCaptureVideoDataOutput! // 保存先
    var filePathBefore: String! // 録画ファイルパス
    var fileURLBefore: URL!
    var filePathAfter: String! // 編集ファイルパス
    var fileURLAfter: URL!
    var time: Int = 0 //折り返す秒数
    var flagReverse:Bool = false
    var flagRecord:Bool = false
    var videoWriter : VideoWriter?

    override func viewDidLoad() {
        super.viewDidLoad()

        filePathBefore = NSHomeDirectory() + "/Documents/test.mp4"
        filePathAfter = NSHomeDirectory() + "/Documents/out.mp4"
        fileURLBefore = URL(fileURLWithPath: filePathBefore)
        fileURLAfter = URL(fileURLWithPath: filePathAfter)

        initCamera()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapStart(_ sender: UIButton) {
        startButton.isHidden = true
        flagRecord = true

        // データ削除
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURLBefore.path) {
            try! fileManager.removeItem(atPath: filePathBefore)
        }
        if fileManager.fileExists(atPath: fileURLAfter.path) {
            try! fileManager.removeItem(atPath: filePathAfter)
        }

        // 録画終了
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(time)) {
            self.flagReverse = true
            self.videoWriter?.finish { () -> Void in
                self.videoWriter = nil
                self.playReverse()
            }
        }
    }

    // カメラの準備
    func initCamera() {
        // セッション作成とクオリティ設定
        let session: AVCaptureSession = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetiFrame960x540
        // デバイスの取得とFPS設定
        let device: AVCaptureDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
        device.activeVideoMinFrameDuration = CMTimeMake(1, 30)
        // VideoInputを取得、出力先を設定
        let videoInput: AVCaptureDeviceInput = try! AVCaptureDeviceInput.init(device: device)
        myFileOutput = AVCaptureVideoDataOutput()
        // ピクセルフォーマットを 32bit BGR + A とする
        myFileOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : Int(kCVPixelFormatType_32BGRA)]
        // フレームをキャプチャするためのサブスレッド用のシリアルキューを用意
        myFileOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        myFileOutput.alwaysDiscardsLateVideoFrames = true

        // セッションに追加.
        session.addInput(videoInput)
        session.addOutput(myFileOutput)

        myDevice = device
        mySession = session
        mySession.startRunning()

        self.videoWriter = VideoWriter(
            fileUrl: self.fileURLBefore,
            height: Int(self.view.frame.height), width: Int(self.view.frame.width)
        )
    }

    // 逆再生
    func playReverse() {
        let avAsset = AVAsset(url: fileURLBefore)
        AVUtilities.reverse(avAsset, outputURL: fileURLAfter, completion: { [unowned self] (reversedAsset: AVAsset) in
            let playerItem = AVPlayerItem(asset: reversedAsset)
            let videoPlayer = AVPlayer(playerItem: playerItem)
            let playerLayer = AVPlayerLayer(player: videoPlayer)
            let playerLayer2 = AVPlayerLayer(player: videoPlayer)
            let playerLayer3 = AVPlayerLayer(player: videoPlayer)
            NotificationCenter.default.addObserver(self, selector: #selector(ViewController.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            DispatchQueue.main.async(execute: {
                playerLayer.frame = CGRect(x: 0, y: 0, width: self.imageViewLeft.frame.width, height: self.imageViewLeft.frame.height)
                playerLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat.pi/2))
                playerLayer.videoGravity = AVLayerVideoGravityResize
                playerLayer2.frame = playerLayer.frame
                playerLayer2.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat.pi/2))
                playerLayer2.videoGravity = AVLayerVideoGravityResize
                self.imageViewLeft.layer.addSublayer(playerLayer2)
                playerLayer3.frame = playerLayer.frame
                playerLayer3.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat.pi/2))
                playerLayer3.videoGravity = AVLayerVideoGravityResize
                self.imageViewRight.layer.addSublayer(playerLayer3)
                self.mySession.stopRunning()
                videoPlayer.play()
            })
        })
    }

    // 逆再生終了
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
        flagReverse = false
        flagRecord = false
        initCamera()
    }

    func captureImage(_ sampleBuffer:CMSampleBuffer) -> UIImage{
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        // イメージバッファのロック
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        // 画像情報を取得
        let base = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)!
        let bytesPerRow = UInt(CVPixelBufferGetBytesPerRow(imageBuffer))
        let width = UInt(CVPixelBufferGetWidth(imageBuffer))
        let height = UInt(CVPixelBufferGetHeight(imageBuffer))
        // ビットマップコンテキスト作成
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitsPerCompornent = 8
        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue) as UInt32)
        let newContext = CGContext(data: base, width: Int(width), height: Int(height), bitsPerComponent: Int(bitsPerCompornent), bytesPerRow: Int(bytesPerRow), space: colorSpace, bitmapInfo: bitmapInfo.rawValue)! as CGContext
        // 画像作成
        let imageRef = newContext.makeImage()!
        let image = UIImage(cgImage: imageRef, scale: 1.0, orientation: UIImageOrientation.right)
        // イメージバッファのアンロック
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return image
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if flagReverse == false {
            let image:UIImage = self.captureImage(sampleBuffer)
            DispatchQueue.main.async {
                self.imageViewRight.image = image
                self.imageViewLeft.image = image
            }
            // 録画
            if flagRecord == true {
                let isVideo = captureOutput is AVCaptureVideoDataOutput
                self.videoWriter?.write(sampleBuffer, isVideo: isVideo)
            }
        }
    }
}

