//
//  ContentView.swift
//  PrivateCamera
//
//  Created by cmStudent on 2023/01/13.
//

import SwiftUI

struct ContentView: View {
    var cameraViewModel=CameraViewModel()
    var videoViewModel=VideoViewModel()
    @AppStorage("save_Album") var saveAlbum="アルバム１"
    @AppStorage("select_Camera") var selectCamera=0
    var body: some View {
        NavigationView(){
            VStack{
                if(selectCamera==0){
                    CameraViewRepresent(viewModel: cameraViewModel)
                    selectView()
                    
                    Button(action: {
                        cameraViewModel.saveAlbum=saveAlbum
                        cameraViewModel.takePhoto()
                    }, label: {
                        Image(systemName: "button.programmable")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60.0, height: 60.0)
                            .foregroundColor(.blue)
                    })
                }else if(selectCamera==1){
                    VideoViewModel.VideoView()
                    
                }
                HStack{
                    NavigationLink(destination:settingView()){
                        Image(systemName: "gearshape")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20.0, height: 20.0)
                            .foregroundColor(.blue)
                            .padding(.leading)
                    }
                    Spacer()
                }
                Spacer(minLength: 5)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
