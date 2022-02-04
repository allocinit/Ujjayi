//
//  ParamView.swift
//  test-220123-ujjayi-state2
//
//  Created by Aleksandr Borisov on 27.01.2022.
//

import SwiftUI

struct ParamView: View {
    @EnvironmentObject var vm: ViewModel
    @Binding var value: Int
    var minValue: Int
    var maxValue: Int { 99 }
    let white: Color = Color(uiColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) //for light mode
    
    @Binding var pickerIsVisible: Bool
    var name = ""
    
    var body: some View {
        
        Text(value.description)
            .opacity(pickerIsVisible ? 0 : 1)
            .frame(width: 44)
            .onTapGesture {
                if vm.pickersAreVisible.contains(true) {
                    vm.resetPickersVisibility()
                } else {
                    pickerIsVisible = true
                }
            }
            .background(
                Picker(name, selection: $value) {
                    ForEach(minValue...maxValue, id: \.self) {
                        Text($0.description).tag($0)
                            .font(.system(size: 35))
                            .foregroundColor(white)
                    }
                }
                    .background(.black)
                    .pickerStyle(.wheel)
                    .opacity(pickerIsVisible ? 1 : 0)
                    .frame(width: 5000)
                    .onChange(of: value) { _ in pickerIsVisible = false }
                    .onTapGesture { pickerIsVisible = false }
            )
        
    }
}

struct ParamView_Previews: PreviewProvider {
    static var previews: some View {
        ParamView(value: Binding.constant(8), minValue: 0, pickerIsVisible: Binding.constant(true))
            .environmentObject(ViewModel())
            .preferredColorScheme(.dark)
    }
}
