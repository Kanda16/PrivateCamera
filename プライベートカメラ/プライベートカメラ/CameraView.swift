//
//  CameraView.swift
//  PrivateCamera
//
//  Created by cmStudent on 2023/01/13.
//

import SwiftUI
//カメラ機能を使う為のライブラリ
import Photos

class CameraView:UIView{
    fileprivate var cameraViewModel:CameraViewModel!
    
    //MARK: -- Layerの設定
    
    //プレビュー用のレイヤー
    var cameraPreviewLayer:AVCaptureVideoPreviewLayer?
    
    //レイヤーの設定
    func setupLayer(){
        cameraPreviewLayer=AVCaptureVideoPreviewLayer(session: cameraViewModel.captureSession)
        cameraPreviewLayer?.videoGravity = .resizeAspect

        cameraPreviewLayer?.connection?.videoOrientation = .portrait
        //画面の向きによってカメラが変な向きになる
        
        //大きさどれぐらい?
        self.frame=CGRect(origin: CGPoint(x:0,y:-90), size: UIScreen.main.bounds.size)
        
        //LayerもViewと同じ大きさにする
        cameraPreviewLayer?.frame=self.frame
        
        if let cameraPreviewLayer = cameraPreviewLayer {
            self.layer.addSublayer(cameraPreviewLayer)
        }
    }
    
    
}

//SwiftUIで使う為のRepresebtable
struct CameraViewRepresent: UIViewRepresentable{
    typealias UIViewType = CameraView
    let viewModel:CameraViewModel
    
    init(viewModel:CameraViewModel){
        self.viewModel=viewModel
    }
    
    func makeUIView(context: Context) -> CameraView {
        let view=CameraView()
        view.cameraViewModel=viewModel
        view.cameraViewModel.setupDevice()
        view.setupLayer()
        view.cameraViewModel.run()
        return view
    }
    
    func updateUIView(_ uiView: CameraView, context: Context) {

    }
}
