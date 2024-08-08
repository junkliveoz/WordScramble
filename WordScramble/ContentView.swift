//
//  ContentView.swift
//  WordScramble
//
//  Created by Adam Sayer on 24/7/2024.
//

import SwiftUI

struct scores: View {
    let totalScore: Int
    
    var body: some View {
        VStack {
            Text("Total Score \(totalScore)")
            // Add more UI elements as needed
        }
    }
}

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State var totalScore = 0
    @State var wordScore = 0
    
    var body: some View {
        
        NavigationStack {
                List {
                    
                    Section {
                        scores(totalScore: totalScore)
                    }
                    
                    Section {
                        TextField("Enter your word", text: $newWord)
                            .textInputAutocapitalization(.never)
                    }


                    
                    Section {
                        ForEach(usedWords, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                        }
                    }
                   
                }
                .navigationTitle(rootWord)
                .onSubmit (addNewWord)
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError) {
                    Button("OK") { }
                } message: {
                    Text(errorMessage)
                }
                .toolbar {
                    Button("Start Over", action: startGame)
                }
            }
        
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let letterScore = answer.count
        
        
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that work from \(rootWord)!")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not recognised", message: "You can't just make them up")
            return
        }
        
        guard isMoreThanTwo(word: answer) else {
            wordError(title: "Word too small", message: "You can't just add small words")
            return
        }
        
        guard isOriginalWord(word: answer) else {
            wordError(title: "Duplicate", message: "This is the word you were given")
            return
        }
    
        wordScore += 1
        totalScore += totalScore + (letterScore * wordScore)
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
            newWord = ""
    }
    
    func startGame () {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: ".txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWorrds = startWords.components(separatedBy: "\n")
                rootWord = allWorrds.randomElement() ?? "silkworm"
                totalScore = 0
                usedWords.removeAll()
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isMoreThanTwo (word: String) -> Bool {
        if word.count > 2 {
            return true
        } else {
            return false
        }
    }
    
    func isOriginalWord (word: String) -> Bool {
        if word != rootWord {
            return true
        } else {
            return false
        }
    }
    
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

#Preview {
    ContentView()
}
