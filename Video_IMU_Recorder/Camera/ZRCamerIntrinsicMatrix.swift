//
//  ZRCamerIntrinsicMatrix.swift
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/18.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class ZRCamerIntrinsicMatrix: NSObject {
    @objc static func getCameraIntrinsicMatrixFromSampleBuffer(sampleBuffer:CMSampleBuffer) -> String {
        if #available(iOS 11, *) {
            if let cameraData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) as? Data {
                let matrix: matrix_float3x3 = cameraData.withUnsafeBytes {$0.pointee}
                let x1 = matrix.columns.0.x
                let y2 = matrix.columns.1.y
                let x3 = matrix.columns.2.x
                let y3 = matrix.columns.2.y
                let matrixstr = String(format: "%f %f %f %f", x1,y2,x3,y3)
                return matrixstr
            }
            return ""
        } else {
            return ""
        }
    }
}
