//
//  VideoWriter.swift
//  FakeInjection
//
//  Created by Kohei Oyama on 2017/07/20.
//  Copyright © 2017年 Kohei Oyama. All rights reserved.
//

import Foundation
import AVFoundation
import AssetsLibrary

class VideoWriter : NSObject{
    var fileWriter: AVAssetWriter!
    var videoInput: AVAssetWriterInput!

    init(fileUrl:URL!, height:Int, width:Int){
        fileWriter = try? AVAssetWriter(outputURL: fileUrl, fileType: AVFileTypeQuickTimeMovie)

        let videoOutputSettings: Dictionary<String, AnyObject> = [
            AVVideoCodecKey : AVVideoCodecH264 as AnyObject,
            AVVideoWidthKey : width as AnyObject,
            AVVideoHeightKey : height as AnyObject
        ];

        videoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoOutputSettings)
        videoInput.expectsMediaDataInRealTime = false
        fileWriter.add(videoInput)
    }

    func write(_ sample: CMSampleBuffer, isVideo: Bool){
        if CMSampleBufferDataIsReady(sample) {
            if fileWriter.status == AVAssetWriterStatus.unknown {
                let startTime = CMSampleBufferGetPresentationTimeStamp(sample)
                fileWriter.startWriting()
                fileWriter.startSession(atSourceTime: startTime)
            }
            if isVideo {
                if videoInput.isReadyForMoreMediaData {
                    videoInput.append(sample)
                }
            }
        }
    }

    func finish(_ callback: @escaping (Void) -> Void){
        fileWriter.finishWriting(completionHandler: callback)
    }
}
