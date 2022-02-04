//
//  TimerView.swift
//  test-220129-ujjayi
//
//  Created by Aleksandr Borisov on 29.01.2022.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
        
        ZStack {
            
            Circle()
                .fill(RadialGradient(gradient: Gradient(colors: [.red, .mint, .blue]),
                                     center: .center,
                                     startRadius: 0,
                                     endRadius: 350))
                .padding(50)
                .hueRotation(.degrees(vm.hueAnimationValue))
                .scaleEffect(vm.scaleAnimationValue)
                .animation(.linear(duration: vm.animationDuration), value: vm.phaseIndex)
            
            VStack {
                HStack {
                    VStack(alignment: .center) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("\(vm.count)")
                                .font(.system(size: 56))
                                .frame(width: 70, alignment: .trailing)
                            
                            ZStack {
                                Circle()
                                    .fill(.tertiary)
                                    .frame(width: 35, height: 35, alignment: .bottom)
                                Text("\(vm.maxCounts)")
                                    .font(.title3)
                            }
                        }
                        Text(Const.count)
                            .font(.caption)
                    }
//                    .padding()
                    .blendMode(.difference)
                    
                    Spacer()
                    
                    VStack(alignment: .center) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("\(vm.cycle)")
                                .font(.system(size: 56))
                                .frame(width: 70, alignment: .trailing)
                            
                            ZStack {
                                Circle()
                                    .fill(.tertiary)
                                    .frame(width: 35, height: 35, alignment: .bottom)
                                Text("\(vm.maxCycles)")
                                    .font(.title3)
                            }
                            
                            
//                            Text("\(vm.maxCycles)")
//                                .font(.title3)
//                                .padding(8)
//                                .background(Circle().fill(.tertiary))
                        }
                        Text(Const.cycles)
                            .font(.caption)
                    }
                    .padding(.trailing)
                    .blendMode(.difference)
                    
                }
//                .padding(.horizontal)
                
                Spacer()
                
                ZStack {
                    Circle()
                    .fill(.clear)

                    Text(vm.phaseTitle)
                        .font(.system(size: 56))
                        .blendMode(.difference)
                }

                Spacer()
                
                VStack(alignment: .leading) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(vm.timeString)
                            .font(.system(size: 56))
                    }
                    Text("time")
                        .font(.caption)
                }
//                .padding()
                .blendMode(.difference)
                
                
            }
        }
        
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
            .environmentObject(ViewModel())
            .preferredColorScheme(.dark)
    }
}
