//
//  VideoViewModel.swift
//  PrivateCamera
//
//  Created by cmStudent on 2023/01/13.
//

import UniformTypeIdentifiers
import SwiftUI
import AVFoundation
import AssetsLibrary
import Photos

class VideoViewModel: NSObject{
    
    enum RecordingStatus: String {
        case ready
        case start
        case stop
    }

    

    public class UICameraView: UIView, AVCaptureFileOutputRecordingDelegate {
        @AppStorage("save_Album") var saveAlbum="アルバム１"
        public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
            delegate?.didFinishRecording(outputFileURL: outputFileURL)
            fileOutput2(movieUrl: outputFileURL,toAlbum: saveAlbum)
            
        }
        
        private var videoDevice: AVCaptureDevice?
        private let fileOutput = AVCaptureMovieFileOutput()
        private var videoLayer : AVCaptureVideoPreviewLayer!
        public weak var delegate: CameraViewDelegate?
            
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let captureSession: AVCaptureSession = AVCaptureSession()
            videoDevice = defaultCamera()
            let audioDevice: AVCaptureDevice? = AVCaptureDevice.default(for: AVMediaType.audio)

            // ビデオセッティング
            let videoInput: AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: videoDevice!)
            captureSession.addInput(videoInput)

            // オーディオセッティング
            let audioInput = try! AVCaptureDeviceInput(device: audioDevice!)
            captureSession.addInput(audioInput)

            
            fileOutput.maxRecordedDuration = CMTimeMake(value: 60, timescale: 1)

            captureSession.addOutput(fileOutput)

            
            captureSession.beginConfiguration()
            if captureSession.canSetSessionPreset(.photo) {
                captureSession.sessionPreset = .photo
            } else if captureSession.canSetSessionPreset(.high) {
                captureSession.sessionPreset = .high
            }
            captureSession.commitConfiguration()

            captureSession.startRunning()

            // ビデオレイヤー
            videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            layer.addSublayer(videoLayer)
        }
        
        public override func layoutSubviews() {
            videoLayer.frame = bounds
        }
        
        func startRecording() {
            // 撮影開始
            let tempDirectory: URL = URL(fileURLWithPath: NSTemporaryDirectory())
            let fileURL: URL = tempDirectory.appendingPathComponent("mytemp1.mov")
            fileOutput.startRecording(to: fileURL, recordingDelegate: self)
            AudioServicesPlaySystemSound(1109)
        }
        
        func stopRecording() {
            // 撮影停止
            fileOutput.stopRecording()
            AudioServicesPlaySystemSound(1109)
        }
        
        private func defaultCamera() -> AVCaptureDevice? {
            if let device = AVCaptureDevice.default(.builtInDualCamera, for: AVMediaType.video, position: .back) {
                return device
            } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
                return device
            } else {
                return nil
            }
        }
    }


        
    struct CameraView: UIViewRepresentable {
        @Binding var recordingStatus: RecordingStatus
        
        let didFinishRecording: (_ outputFileURL: URL) -> Void
        
        final public class Coordinator: NSObject, CameraViewDelegate {
            private var cameraView: CameraView
            let didFinishRecording: (_ outputFileURL: URL) -> Void
            init(_ cameraView: CameraView, didFinishRecording: @escaping (_ outputFileURL:URL) -> Void) {
                self.cameraView = cameraView
                self.didFinishRecording = didFinishRecording
            }
            
            func didFinishRecording(outputFileURL: URL) {
                didFinishRecording(outputFileURL)
            }
        }
        
        public func makeCoordinator() -> Coordinator {
            Coordinator(self, didFinishRecording: didFinishRecording)
        }
        
        func makeUIView(context: Context) -> UICameraView {
            let uiCameraView = UICameraView()
            uiCameraView.delegate = context.coordinator
            return uiCameraView
        }
        
        func updateUIView(_ uiView: UICameraView, context: Context) {
            switch recordingStatus {
            case .ready:
                return
            case .start:
                uiView.startRecording()
            case .stop:
                uiView.stopRecording()
            }
        }
    }
    struct VideoView: View {

        @State var recordingStatus: RecordingStatus = .ready
//        @AppStorage("save_Album") var saveAlbum="プライベート"
        var body: some View {
            VStack {
                CameraView(recordingStatus: $recordingStatus) { url in
                    recordingStatus = .ready
                    print(url)
                }
                    .frame(width: 400, height: 470)
                selectView()
                Button {
                    if(recordingStatus == .start){
                        recordingStatus = .stop
                    }else{
                        recordingStatus = .start
                    }
                } label: {
                    Image(systemName: "button.programmable")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60.0, height: 60.0)
                        .foregroundColor(.red)

                }
            }
        }
    }
}

public protocol CameraViewDelegate: AnyObject {
    func didFinishRecording(outputFileURL: URL)
}

func fileOutput2(movieUrl:URL,toAlbum albumName: String) {

    findOrCreatePhotoAlbum(name: albumName) { (album, error) in
        if let album{
            // ライブラリへ保存
            PHPhotoLibrary.shared().performChanges({
                let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: movieUrl)!
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                let placeHolder = assetRequest.placeholderForCreatedAsset
                albumChangeRequest?.addAssets([placeHolder!] as NSArray)
            }) { completed, error in
                if completed {
                    print("Video is saved!")
                }
            }
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
