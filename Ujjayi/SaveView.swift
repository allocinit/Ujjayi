//
//  SaveView.swift
//  test-220129-ujjayi
//
//  Created by Aleksandr Borisov on 31.01.2022.
//

import SwiftUI

struct SaveView: View {
    @EnvironmentObject var vm: ViewModel
    @Environment(\.presentationMode) var presentation
    
    let colors: [Color] = [Color(uiColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)), Color(uiColor: #colorLiteral(red: 0.04627646506, green: 0.03154562786, blue: 0.09289806336, alpha: 1))]
    
    var body: some View {
        NavigationView {
            ZStack {
                
                LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack {
                    TextField(Const.enterName, text: $vm.saveName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .foregroundColor(vm.saveNameNotUnique ? .red : .white)
                    
                    Text(Const.exist)
                        .foregroundColor(.red)
                        .opacity(vm.saveNameNotUnique ? 1 : 0)
                }
                
            }
            
            .navigationTitle(Const.savePreset)
            
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        self.presentation.wrappedValue.dismiss()
                        vm.clearSaveTextfield()
                    } label: {
                        Text(Const.cancel)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        vm.savePreset()
                        self.presentation.wrappedValue.dismiss()
                    } label: {
                        Text(Const.save)
                    }
                    .disabled(vm.saveNameNotUnique || vm.saveName.isEmpty)
                }
                
            }
            
        }
        .accentColor(.white)
    }
}

struct SaveView_Previews: PreviewProvider {
    static var previews: some View {
        SaveView()
            .environmentObject(ViewModel())
            .preferredColorScheme(.dark)
    }
}
