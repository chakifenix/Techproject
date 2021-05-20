//
//  UploaderItem+UIImagePickerController.swift
//  StreamChat
//
//  Created by Alexey Bukhtin on 23/07/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import StreamChatCore
import Photos.PHPhotoLibrary

extension UploaderItem {
    convenience init?(channel: Channel, pickedImage: PickedImage) {
        guard let fileURL = pickedImage.fileURL else {
            return nil
        }
        
        let fileName = pickedImage.fileName
        let ext = fileURL.pathExtension.lowercased()
        var fileType = AttachmentFileType(ext: ext)
        
        if fileType == .generic, let dot = fileName.lastIndex(of: ".") {
            let ext = String(fileName.suffix(from: dot))
                .trimmingCharacters(in: .init(charactersIn: ".")).lowercased()
            
            fileType = AttachmentFileType(ext: ext)
        }
        
        self.init(channel: channel,
                  url: fileURL,
                  type: pickedImage.isVideo ? .video : .image,
                  image: pickedImage.image,
                  fileName: fileName,
                  fileType: fileType)
    }
}

struct PickedImage {
    let image: UIImage?
    let fileURL: URL?
    let fileName: String
    let isVideo: Bool
    
    init?(info: [UIImagePickerController.InfoKey : Any]) {
        if let videoURL = info[.mediaURL] as? URL, (info[.mediaType] as? String) == .movieFileType {
            isVideo = true
            fileURL = videoURL
            fileName = videoURL.lastPathComponent.lowercased()
            image = videoURL.videoFrame(at: .middle)
            return
        }
        
        guard let image = info[.originalImage] as? UIImage else {
            return nil
        }
        
        isVideo = false
        self.image = image
        let fileURL = info[.imageURL] as? URL
        self.fileURL = fileURL
        
        if let asset = info[.phAsset] as? PHAsset,
            let assetResources = PHAssetResource.assetResources(for: asset).first {
            fileName = assetResources.originalFilename
        } else {
            fileName = fileURL?.lastPathComponent ?? "photo_\(Date().fileName).jpg"
        }
    }
}
