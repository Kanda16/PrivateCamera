//
//  settingView.swift
//  PrivateCamera
//
//  Created by cmStudent on 2023/01/13.
//

import SwiftUI

struct settingView: View {
    @AppStorage("select_Album_1") var selectAlbum1="アルバム１"
    @AppStorage("select_Album_2") var selectAlbum2="アルバム２"
    @AppStorage("select_Album_3") var selectAlbum3="アルバム３"
    @AppStorage("select_Album_4") var selectAlbum4="アルバム４"
    var body: some View {
        VStack{
            Spacer()
            Text("保存するアルバム名を4つ")
                .font(.title)
            Text("入力してください")
                .font(.title)
            Text("\n※存在しないアルバム名を入力した場合\n  その名前で新しくアルバムが作られます")
                .font(.caption2)
                
            Spacer()
            HStack{
                Text("アルバム名１")
                TextField("アルバム名を入力", text: $selectAlbum1)
                    .frame(width: 200)
                    .border(Color.gray,width:0.5)
            }
            HStack{
                Text("アルバム名２")
                TextField("アルバム名を入力", text: $selectAlbum2)
                    .frame(width: 200)
                    .border(Color.gray,width:0.5)
            }
            
            HStack{
                Text("アルバム名３")
                TextField("アルバム名を入力", text: $selectAlbum3)
                    .frame(width: 200)
                    .border(Color.gray,width:0.5)
            }
            HStack{
                Text("アルバム名４")
                TextField("アルバム名を入力", text: $selectAlbum4)
                    .frame(width: 200)
                    .border(Color.gray,width:0.5)
            }
            Spacer()
        }
    }
}

struct settingView_Previews: PreviewProvider {
    static var previews: some View {
        settingView()
    }
}
