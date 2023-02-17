//
//  CameraViewModel.swift
//  PrivateCamera
//
//  Created by cmStudent on 2023/01/13.
//

import Foundation
import Photos
import UIKit

class CameraViewModel:NSObject{
    var saveAlbum=""
    
    //入力と出力を管理する
    //
    let captureSession=AVCaptureSession()
    
    //デバイス、背面カメラ
    var mainCamera:AVCaptureDevice?
    //インナーカメラ
    var innerCamera:AVCaptureDevice?
    
    //実際に使うものはどっち？使う方を入れる
    var device:AVCaptureDevice?
    
    //キャプチャーした画面をアウトプットする為の入れ物
    var photoOutput=AVCapturePhotoOutput()
    
    //キャプチャーしたイメージデータを保存する場所
    var imageData:Data?
    
    //カメラのセッティング
    func setupDevice(){
        //設定を開始
        captureSession.beginConfiguration()
        //画面の解像度（大きさ）
        captureSession.sessionPreset = .photo   //端末に依存する
        
        //MARK: --カメラの設定
        //組み込みのカメラを使う
        //カメラはフロント（インナー）とバックがある
        //広角カメラ
        let deviceDiscoverySession=AVCaptureDevice.DiscoverySession(deviceTypes:[.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        
        //条件を満たしたデバイスを取得する
        let devices=deviceDiscoverySession.devices
        //取得したデバイスを振り分ける
        for device in devices{
            if device.position == .back{
                mainCamera=device
            }else if device.position == .front{
                innerCamera=device
            }
        }
        
        //実際に起動するカメラは、背面が優先
        device=mainCamera == nil ? innerCamera:mainCamera
        
        //MARK: -- 出力の設定
        guard captureSession.canAddOutput(photoOutput) else {
            captureSession.commitConfiguration()
            return
        }
        //ここから先実行されないかもしれない
        //セッションが使うアウトプットの設定
        captureSession.addOutput(photoOutput)
        
        //MARK: -- 入力の設定
        if let device = device{
            guard let captureDeviceInput = try? AVCaptureDeviceInput(device:device),
                  captureSession.canAddInput(captureDeviceInput) else{
                captureSession.commitConfiguration()
                return
            }
            captureSession.addInput(captureDeviceInput)
        }
        
        //設定を終える。設定をコミットする
        captureSession.commitConfiguration()
    }
    
    func run(){
        DispatchQueue(label: "Background",qos: .background).async {
            self.captureSession.startRunning()
        }
    }
}

//クラスの継承をextensionに書けない
extension CameraViewModel:AVCapturePhotoCaptureDelegate{
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        self.imageData=photo.fileDataRepresentation()
        //撮影した写真をディスプレイに表示する
        //Image()→直接はimageDataをImage()に出来ない
        _ = UIImage(data:imageData!)
        saveImage(imageData!, toAlbum: saveAlbum)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        //シャッター音を消す
        AudioServicesDisposeSystemSoundID(1108)
        //あるいは、シャッター音を他の音に変える
        AudioServicesPlaySystemSound(1109)
    }

    func saveImage(_ imageData: Data, toAlbum albumName: String) {
        let TempFilePath = "\(NSTemporaryDirectory())temp.jpg"
//        var imageID: String? = nil
        

        findOrCreatePhotoAlbum(name: albumName) { (album, error) in
            // 画像データを一時ファイルとして保存
            let fileURL = URL(fileURLWithPath: TempFilePath)
            try? imageData.write(to: fileURL, options: .atomic)

            if let album = album, FileManager.default.fileExists(atPath: TempFilePath) {
                PHPhotoLibrary.shared().performChanges({
                    let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileURL)!
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                    let placeHolder = assetRequest.placeholderForCreatedAsset
                    albumChangeRequest?.addAssets([placeHolder!] as NSArray)
//                    imageID = assetRequest.placeholderForCreatedAsset?.localIdentifier
                }) { (isSuccess, error) in
                    if isSuccess {
                        // 保存した画像にアクセスする為のimageIDを返却
//                        completionBlock(imageID)
                    } else {
//                        failureBlock(error)
                    }
                    _ = try? FileManager.default.removeItem(atPath: TempFilePath)
                }
            } else {
//                failureBlock(error)
                _ = try? FileManager.default.removeItem(atPath: TempFilePath)
            }
        }
    }

    private func findOrCreatePhotoAlbum(name: String, completion: @escaping (PHAssetCollection?, Error?) -> Void) {
        var assetCollection: PHAssetCollection?
        var assetCollectionPlaceholder: PHObjectPlaceholder?

        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", name)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: fetchOptions)
        if collection.firstObject != nil {
            assetCollection = collection.firstObject
            completion(assetCollection, nil)
        } else {
            //アルバム作る
            PHPhotoLibrary.shared().performChanges({
                let createRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
                assetCollectionPlaceholder = createRequest.placeholderForCreatedAssetCollection
            }) { (isSuccess, error) in
                if isSuccess {
                    let refetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [assetCollectionPlaceholder!.localIdentifier], options: nil)
                    assetCollection = refetchResult.firstObject
                    completion(assetCollection, nil)
                } else {
                    completion(nil, error)
                }
            }
        }
    }
    
    func takePhoto(){
        let settings=AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}
