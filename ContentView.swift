//
//  ContentView.swift
//  multiplication
//
//  Created by Олексій Якимчук on 23.05.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var multiNumber: Int = 2
    @State private var numOfQuestions: Int = 5
    @State private var answeredQuestions: Int = 0
    
    @State private var answer: Int = 0
    @State private var endAnswer: Int = 0
    
    @State private var usedNumbers: [Int] = Array(1...25).shuffled()
    var randomNumber: Int { usedNumbers[0] }
    
    @State private var showWrongAlert = false
    @State private var showWinAlert = false
    @State private var showLoseAlert = false
    
    @State private var skipDegrees: Double = 0
    @State private var isWrongTilted = false
    @State private var isRightScaled = false
    
    let questionsAmount = [5, 10, 20]
    
    var body: some View {
        NavigationView {
            ZStack {
                RadialGradient(colors: [.mint, .cyan, .blue], center: .center, startRadius: 100, endRadius: 350)
                
                VStack {
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    VStack { // Stepper
                        Section {
                            Stepper("Chosen number: \(multiNumber)", value: $multiNumber, in: 2...12, step: 1)
                                .frame(width: 310, height: 20)
                                .padding(10)
                                .background()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } header: {
                            Text("Choose the multiplication number:")
                                .foregroundColor(.white)
                                .font(.callout).bold()
                                .frame(width: 320, alignment: .leading)
                        }
                    }
                    
                    
                    VStack { // Picker
                        Section {
                            Picker("Questions", selection: $numOfQuestions) {
                                ForEach(questionsAmount, id: \.self) {
                                    Text($0, format: .number)
                                }
                            } .pickerStyle(.segmented)
                                .frame(width: 330)
                                .background()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } header: {
                            Text("Choose the number of questions:")
                                .foregroundColor(.white)
                                .font(.callout).bold()
                                .frame(width: 320, alignment: .leading)
                        }
                    }
                    
                    Spacer()
                    
                    VStack { // TextField
                        Text("What is \(multiNumber) × \(randomNumber) ?")
                            .font(.title).bold()
                        TextField("Answer", value: $answer, format: .number)
                            .keyboardType(.numberPad)
                            .foregroundColor(.white)
                            .font(.title2).bold()
                            .padding(15)
                            .frame(width: 230, height: 45)
                            .background(.teal)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        
                        HStack {
                            Button("Submit") {
                                endAnswer = Int(answer)
                                
                                if usedNumbers.count > 1 {
                                    endAnswer == (multiNumber * randomNumber) ? answeredRight() : answeredWrong()
                                } else {
                                    showLoseAlert = true
                                }
                            }
                            .padding(.horizontal, 17).padding(.vertical, 10)
                            .foregroundColor(.green)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .alert("Wrong answer", isPresented: $showWrongAlert) {}
                            .alert("You won", isPresented: $showWinAlert) {
                                Button("OK") {
                                    answeredQuestions = 0
                                    usedNumbers = Array(1...25).shuffled()
                                    multiNumber = Int.random(in: 2...12)
                                    switch numOfQuestions {
                                    case 5:
                                        numOfQuestions = 10
                                    case 10:
                                        numOfQuestions = 20
                                    default:
                                        numOfQuestions = 5
                                    }
                                }
                            }
                            .alert("You lost", isPresented: $showLoseAlert) {
                                Button("OK") {
                                    answeredQuestions = 0
                                    usedNumbers = Array(1...25).shuffled()
                                }
                            }
                            
                            Button("Skip", role: .destructive) {
                                withAnimation {
                                    skipDegrees += 360.0
                                }
                                
                                if usedNumbers.count > 1 {
                                    skip()
                                } else {
                                    showLoseAlert = true
                                }
                            }
                            .padding(.horizontal, 28).padding(.vertical, 10)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            
                            
                            .alert("You lost", isPresented: $showLoseAlert) {
                                Button("OK") {
                                    answeredQuestions = 0
                                    usedNumbers = Array(1...25).shuffled()
                                }
                            }
                        }
                    }
                    .frame(width: 330, height: 225)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .rotation3DEffect(.degrees(skipDegrees), axis: (x: 0, y: 1, z: 0)) // skipped
                    .animation(.spring(), value: skipDegrees)
                    .rotation3DEffect(.degrees(isWrongTilted ? 10 : 0), axis: (x: 0, y: 0, z: 1)) // wrong answer
                    .scaleEffect(isRightScaled ? 1.15 : 1)
                    
                    Spacer()
                    Spacer()
                    
                    VStack {
                        Text("\(answeredQuestions)/\(numOfQuestions)")
                            .font(.title3).bold()
                            .foregroundColor(.white)
                            .padding(10)
                    }
                }
            }
            .navigationTitle("Multiplication🧮")
            .ignoresSafeArea()
        }
    }
    
    func answeredRight() {
        answeredQuestions += 1
        (answeredQuestions == numOfQuestions) ? showWinAlert = true : ()
        usedNumbers.remove(at: 0)
        usedNumbers.shuffle()
        
        withAnimation(.interpolatingSpring(stiffness: 10, damping: 4)) {
            isRightScaled.toggle()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.interpolatingSpring(stiffness: 10, damping: 4)) {
                isRightScaled = false
            }
        }
    }
    
    func answeredWrong() {
        showWrongAlert = true
        usedNumbers.shuffle()
        
        // Tilting Animation
        withAnimation(.easeInOut(duration: 0.3)) {
            isWrongTilted.toggle()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isWrongTilted = false
            }
        }
    }
    
    func skip() {
        usedNumbers.remove(at: 0)
        usedNumbers.shuffle()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
