//
//  OpenView.swift
//  test-220129-ujjayi
//
//  Created by Aleksandr Borisov on 30.01.2022.
//

import SwiftUI

struct OpenView: View {
    @EnvironmentObject var vm: ViewModel
    @Environment(\.presentationMode) var presentation
    
    let colors: [Color] = [Color(uiColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)), Color(uiColor: #colorLiteral(red: 0.04627646506, green: 0.03154562786, blue: 0.09289806336, alpha: 1))]
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                List {
                    ForEach(vm.presets, id: \.name) { preset in
                        Text(preset.name)
                            .onTapGesture {
                                vm.pranayama = preset.pranayama
                                self.presentation.wrappedValue.dismiss()
                            }
                    }
                    .onDelete(perform: vm.deletePreset)
                }
                .blendMode(.difference)
            }
            
            .navigationTitle(Const.loadPreset)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        self.presentation.wrappedValue.dismiss()
                    } label: {
                        Text(Const.cancel)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            
            
        }
        .accentColor(.white)
        .listStyle(.grouped)
    }
}

struct OpenView_Previews: PreviewProvider {
    static var previews: some View {
        OpenView()
            .environmentObject(ViewModel())
            .preferredColorScheme(.dark)
    }
}
