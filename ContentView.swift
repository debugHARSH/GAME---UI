import SwiftUI

struct ContentView: View {
    // Values for the cards (multiple pairs of matching emojis)
    @State private var cardValues = ["🧠", "🧠", "💡", "💡", "🔒", "🔒", "🔋", "🔋", "📱", "📱", "🍎", "🍎", "🌟", "🌟", "🚀", "🚀"]
    
    // The shuffled card values and their states (question mark initially)
    @State private var shuffledValues: [String] = []
    @State private var flippedCards: [Bool] = []  // Tracks if a card is flipped
    @State private var firstCardIndex: Int? = nil
    @State private var secondCardIndex: Int? = nil
    @State private var matchedPairs = 0
    @State private var gameOver = false
    @State private var gameSubmitted = false
    @State private var isGameStarted = false
    @State private var gameStateSaved = false
    @State private var showRules = false  // Controls whether the rules sheet is displayed

    var body: some View {
        VStack {
            if !isGameStarted {
                // Initial screen with options to start or resume the game
                Text("BrainMatch Game")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.purple)
                    .cornerRadius(10)
                    .padding(.bottom)
                
                Text("Do you want to start a new game or resume the previous one?")
                    .font(.title)
                    .padding()
                    .foregroundColor(.white)
                
                HStack {
                    Button(action: startNewGame) {
                        Text("Start New Game")
                            .font(.title)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    Button(action: resumeGame) {
                        Text("Resume Game")
                            .font(.title)
                            .padding()
                            .background(gameStateSaved ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(!gameStateSaved)
                    }
                    .padding()
                }
                
                Button(action: { showRules = true }) {
                    Text("Game Rules")
                        .font(.title2)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)

            } else {
                // Title and score
                Text("BrainMatch Game")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.purple)
                    .cornerRadius(10)
                    .padding(.bottom)
                
                Text("Matched Pairs: \(matchedPairs)/\(cardValues.count / 2)")
                    .font(.title2)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.orange)
                    .cornerRadius(10)
                    .padding(.bottom)

                if gameSubmitted {
                    // Show result after game is submitted
                    if gameOver {
                        Text(matchedPairs == cardValues.count / 2 ? "You Won!" : "Better Luck Next Time!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                            .foregroundColor(.green)
                    } else {
                        Text("Game not yet finished!")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                            .foregroundColor(.yellow)
                    }
                    
                    Button(action: restartGame) {
                        Text("Restart Game")
                            .font(.title)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                } else {
                    // Display the cards in a grid
                    LazyVGrid(columns: [GridItem(), GridItem(), GridItem(), GridItem()]) {
                        ForEach(0..<shuffledValues.count, id: \.self) { index in
                            CardView(
                                cardValue: shuffledValues[index],
                                isFlipped: flippedCards[index]
                            )
                            .onTapGesture {
                                flipCard(at: index)
                            }
                            .padding(10)
                        }
                    }
                    
                    // Submit Button
                    Button(action: submitGame) {
                        Text("Submit")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(gameSubmitted)
                    }
                    .padding()
                }
                
                Spacer()
            }
        }
        .onAppear {
            if !isGameStarted {
                shuffleCards()
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showRules) {
            // Rules pop-up sheet
            RulesView()
        }
    }
    
    // Function to shuffle the cards' values
    func shuffleCards() {
        shuffledValues = cardValues.shuffled()
        flippedCards = Array(repeating: false, count: shuffledValues.count)
    }
    
    // Start a new game
    func startNewGame() {
        isGameStarted = true
        gameStateSaved = false
        resetGameState()
        shuffleCards()
    }

    // Resume the game if a previous state exists
    func resumeGame() {
        if gameStateSaved {
            isGameStarted = true
            shuffleCards() // Reshuffle if needed
        }
    }
    
    // Reset game state to initial values
    func resetGameState() {
        matchedPairs = 0
        gameOver = false
        gameSubmitted = false
        firstCardIndex = nil
        secondCardIndex = nil
    }
    
    // Function to flip the card at a specific index
    func flipCard(at index: Int) {
        if flippedCards[index] || gameOver || gameSubmitted {
            return
        }
        
        flippedCards[index] = true
        
        if firstCardIndex == nil {
            firstCardIndex = index
        } else {
            secondCardIndex = index
            checkForMatch()
        }
    }
    
    // Check if the two flipped cards match
    func checkForMatch() {
        if let firstIndex = firstCardIndex, let secondIndex = secondCardIndex {
            if shuffledValues[firstIndex] == shuffledValues[secondIndex] {
                matchedPairs += 1
                resetCards()
                checkGameOver()
            } else {
                // If they don't match, flip them back after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    flippedCards[firstIndex] = false
                    flippedCards[secondIndex] = false
                    resetCards()
                }
            }
        }
    }
    
    // Reset the flipped cards' indexes
    func resetCards() {
        firstCardIndex = nil
        secondCardIndex = nil
    }
    
    // Check if the game is over (all pairs matched)
    func checkGameOver() {
        if matchedPairs == cardValues.count / 2 {
            gameOver = true
            gameStateSaved = true
        }
    }
    
    // Submit the game, show results
    func submitGame() {
        gameSubmitted = true
        checkGameOver()
    }
    
    // Restart the game
    func restartGame() {
        matchedPairs = 0
        gameOver = false
        gameSubmitted = false
        shuffleCards()
    }
}

struct CardView: View {
    var cardValue: String
    var isFlipped: Bool
    
    var body: some View {
        ZStack {
            // Dynamic color change for unmatched cards
            Rectangle()
                .fill(isFlipped ? Color.green : Color.purple)
                .cornerRadius(10)
                .frame(width: 80, height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 2)
                )
            
            Text(isFlipped ? cardValue : "?")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
        .animation(.easeInOut(duration: 0.3), value: isFlipped)
    }
}

struct RulesView: View {
    @Environment(\.dismiss) var dismiss // To dismiss the sheet

    var body: some View {
        VStack {
            Text("Game Rules")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .foregroundColor(.white)
                .background(Color.purple)
                .cornerRadius(10)
            
            ScrollView {
                Text("""
                1. Match pairs of identical cards by flipping them over.
                2. You can only flip two cards at a time.
                3. If the cards match, they stay flipped; otherwise, they will flip back.
                4. Your goal is to match all pairs before the game ends.
                5. The game ends when all pairs are matched successfully.
                """)
                    .font(.title)
                    .padding()
                    .foregroundColor(.white)
            }
            
            Button(action: {
                dismiss() // Close the rules sheet
            }) {
                Text("Close")
                    .font(.title)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
