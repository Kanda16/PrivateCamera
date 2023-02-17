//
//  selectView.swift
//  PrivateCamera
//
//  Created by cmStudent on 2023/01/13.
//

import SwiftUI

struct selectView:View{
    @AppStorage("select_Camera") var selectCamera=0
    @AppStorage("save_Album") var saveAlbum="アルバム１"
    
    @AppStorage("select_Album_1") var selectAlbum1="アルバム１"
    @AppStorage("select_Album_2") var selectAlbum2="アルバム２"
    @AppStorage("select_Album_3") var selectAlbum3="アルバム３"
    @AppStorage("select_Album_4") var selectAlbum4="アルバム４"
    var body:some View{
        HStack{
            Picker("", selection: self.$selectCamera) {
                        Text("写真")
                            .tag(0)
                        Text("ビデオ")
                            .tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
            Text("|")
            ScrollView(.horizontal){
                Picker("", selection: self.$saveAlbum) {
                    Text(selectAlbum1)
                        .tag(selectAlbum1)
                    Text(selectAlbum2)
                        .tag(selectAlbum2)
                    Text(selectAlbum3)
                        .tag(selectAlbum3)
                    Text(selectAlbum4)
                        .tag(selectAlbum4)
                }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame( height: 70)
            }
        }
    }
}

struct selectView_Previews: PreviewProvider {
    static var previews: some View {
        selectView()
    }
}
