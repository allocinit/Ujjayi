//
//  MainView.swift
//  test-220123-ujjayi-state2
//
//  Created by Aleksandr Borisov on 26.01.2022.
//

import SwiftUI

struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: ViewModel
    
    let colors: [Color] = [Color(uiColor: #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)), Color(uiColor: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1))]
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                    
                    VStack {
                        switch vm.timerState {
                        case .stopped:
                            
                            VStack {
                                
                                Spacer()
                                
                                HStack {
                                    
                                    VStack(alignment: .leading) {
                                        
                                        HStack {
                                            ParamView(value: $vm.pranayama.inhale, minValue: 1, pickerIsVisible: $vm.pickersAreVisible[0])
                                            Text(Const.colon)
                                            ParamView(value: $vm.pranayama.innerHold, minValue: 0, pickerIsVisible: $vm.pickersAreVisible[1])
                                            Text(Const.colon)
                                            ParamView(value: $vm.pranayama.exhale, minValue: 1, pickerIsVisible: $vm.pickersAreVisible[2])
                                            Text(Const.colon)
                                            ParamView(value: $vm.pranayama.outerHold, minValue: 0, pickerIsVisible: $vm.pickersAreVisible[3])
                                        }
                                        .frame(height: geometry.size.height * 0.25)
                                        .blendMode(.difference)
                                        
                                        Text(Const.proportion)
                                            .font(.body)
                                            .blendMode(.difference)
                                            .padding(.top)
                                    }
                                    .padding(.leading, 24)
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .center) {
                                        
                                        ParamView(value: $vm.pranayama.cycles, minValue: 1, pickerIsVisible: $vm.pickersAreVisible[4])
                                            .blendMode(.difference)
                                            .frame(height: geometry.size.height * 0.25)
                                        
                                        Text(Const.cycles)
                                            .font(.body)
                                            .blendMode(.difference)
                                            .padding(.top)
                                        
                                    }
                                    .padding(.trailing, 24)
                                    
                                }
                                .padding(.vertical)
                                .background(colorScheme == .dark ? .ultraThinMaterial : .thinMaterial)
                                
                                Spacer()
                                
                                VStack(alignment: .leading) {
                                    HStack(alignment: .firstTextBaseline) {
                                        Text(vm.totalTimeString)
//                                            .font(.system(size: 56))
//                                            .font(.largeTitle)
                                    }
                                    Text(Const.time)
                                        .font(.body)
                                }
                                .padding()
                                .blendMode(.difference)
                                
                                Spacer()
                                
                            }
                            .font(.largeTitle)
                            
                        case .paused, .started:
                            TimerView()
                                .onAppear {
                                    vm.bang()
                                }
                            
                        }
                        
                        HStack(alignment: .top) {
                            
                            Spacer()
                            Button {
                                vm.resetPickersVisibility()
                                vm.stop()
                            } label: {
                                Text(Const.stop)
                            }
                            .frame(width: 108, height: 108, alignment: .center)
                            .background(Circle().stroke())
                            .disabled(vm.timerState == .stopped)
                            
                            Spacer()
                            
                            Button {
                                vm.resetPickersVisibility()
                                vm.startPause()
                            } label: {
                                Text(vm.startPauseTitle)
                            }
                            .frame(width: 108, height: 108, alignment: .center)
                            .background(Circle().stroke())
                            
                            Spacer()
                        }
                        .blendMode(.difference)
                        .frame(height: geometry.size.height * 0.25)
                    }
                    .font(.title)
                    
                }
                .foregroundColor(.white)
                
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(vm.timerState != .stopped)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        
                        Button {
                            vm.resetPickersVisibility()
                            vm.showOpenView = true
                        } label: {
                            Image(Const.openIcon)
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                        }
                        .padding(.leading, 8)
                        
                        Button {
                            vm.resetPickersVisibility()
                            withAnimation() {
                                vm.showSaveView = true
                            }
                        } label: {
                            Image(Const.saveIcon)
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 21, height: 21)
                        }
                        
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {

                        Button {
                            vm.resetPickersVisibility()
                        } label: {
                            Image(systemName: Const.settingsIcon)
                        }
                        .padding(.trailing, 8)

                    }
                    
                }
                .accentColor(.brown)
                .sheet(isPresented: $vm.showOpenView) {
                    OpenView()
                }
                .sheet(isPresented: $vm.showSaveView) {
                    SaveView()
                }
                
            }
        }
    }
    
}

struct UI_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(ViewModel())
            .preferredColorScheme(.dark)
    }
}
