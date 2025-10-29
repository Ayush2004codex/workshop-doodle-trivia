# workshop-doodle-trivia
# 🎮 Doodle Trivia
<img width="2105" height="1326" alt="image" src="https://github.com/user-attachments/assets/a19ad530-7ccf-4f06-b321-367db922cdcd" />

> A decentralized quiz platform built on blockchain where questions and scores are immutably stored forever!

[![Solidity](https://img.shields.io/badge/Solidity-0.8.0-blue.svg)](https://soliditylang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Celo](https://img.shields.io/badge/Network-Celo%20Sepolia-green.svg)](https://celo.org/)

## 📖 Project Description

**Doodle Trivia** is a blockchain-based quiz application that leverages the immutability and transparency of smart contracts to create a fair and permanent trivia game. Built with Solidity, this dApp ensures that all quiz questions and player scores are stored on-chain, making them tamper-proof and verifiable by anyone.

Perfect for developers learning Web3, educators creating decentralized learning platforms, or anyone interested in blockchain gaming!

---

## 🎯 What It Does

Doodle Trivia allows:

- **Quiz Creators** to add multiple-choice questions with correct answers stored securely on-chain
- **Players** to participate in quizzes and have their scores permanently recorded on the blockchain
- **Everyone** to view leaderboards and verify scores transparently without any central authority

All interactions happen through smart contract functions, making the entire system trustless and decentralized.

---

## ✨ Features

### 🔐 **Immutable Question Storage**
- Questions are stored permanently on the blockchain
- Once added, they cannot be modified or deleted
- Ensures fairness and prevents cheating

### 📝 **Multiple Choice Questions**
- Support for any number of answer options
- Flexible question format
- Owner-controlled question management

### 🏆 **Automated Scoring System**
- Instant score calculation upon quiz submission
- Scores automatically recorded on-chain
- Timestamp tracking for each submission

### 📊 **Public Leaderboard**
- View all players and their scores
- Transparent and verifiable rankings
- Community-driven competition

### 👤 **Player Score History**
- Each player's performance is permanently recorded
- Includes score, total questions answered, and timestamp
- Retrievable by anyone at any time

### 🔒 **Owner-Only Question Management**
- Only the contract deployer can add questions
- Prevents unauthorized modifications
- Maintains quiz integrity

---

## 🚀 Deployed Smart Contract

**Network:** Celo Sepolia Testnet  
**Contract Address:** `0x545663B9F0E06F0c0fBCf77A69675dd1F4283353`

🔗 **[View on BlockScout](https://celo-sepolia.blockscout.com/address/0x545663B9F0E06F0c0fBCf77A69675dd1F4283353)**

---

## 📋 Smart Contract Functions

### For Quiz Owners:
```solidity
addQuestion(string _questionText, string[] _options, uint256 _correctAnswerIndex)
```
Add a new question to the quiz with multiple choice options.

### For Players:
```solidity
submitQuiz(uint256[] _answers)
```
Submit your answers and get your score recorded on-chain.

### View Functions:
```solidity
getQuestion(uint256 _questionId) // View question and options
getPlayerScore(address _player)  // Check a player's score
getLeaderboard(uint256 _limit)   // View top players
getPlayerCount()                 // Total number of players
```

---

## 🛠️ Tech Stack

- **Smart Contract:** Solidity ^0.8.0
- **Blockchain:** Celo (Sepolia Testnet)
- **Development Tools:** Remix IDE / Hardhat / Truffle
- **Testing Network:** Celo Sepolia Testnet

---

## 📦 Installation & Setup

### Prerequisites
- MetaMask or any Web3 wallet
- Celo Sepolia testnet tokens (get from [Celo Faucet](https://faucet.celo.org/alfajores))
- Basic understanding of Solidity and smart contracts

### Step 1: Clone the Repository
```bash
git clone https://github.com/XXX/doodle-trivia.git
cd doodle-trivia
```

### Step 2: Smart Contract Code
Create a file named `DoodleTrivia.sol` and paste the code:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DoodleTrivia {
    
    // Struct to store quiz questions
    struct Question {
        string questionText;
        string[] options;
        uint256 correctAnswerIndex;
        bool exists;
    }
    
    // Struct to store player scores
    struct PlayerScore {
        address player;
        uint256 score;
        uint256 totalQuestions;
        uint256 timestamp;
    }
    
    // State variables
    address public owner;
    uint256 public questionCount;
    
    // Mappings
    mapping(uint256 => Question) public questions;
    mapping(address => PlayerScore) public playerScores;
    address[] public players;
    
    // Events
    event QuestionAdded(uint256 indexed questionId, string questionText);
    event QuizCompleted(address indexed player, uint256 score, uint256 totalQuestions);
    
    // Modifier to restrict access to owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    // Add a new question (only owner can add)
    function addQuestion(
        string memory _questionText,
        string[] memory _options,
        uint256 _correctAnswerIndex
    ) public onlyOwner {
        require(_options.length > 0, "Must have at least one option");
        require(_correctAnswerIndex < _options.length, "Invalid correct answer index");
        
        questions[questionCount] = Question({
            questionText: _questionText,
            options: _options,
            correctAnswerIndex: _correctAnswerIndex,
            exists: true
        });
        
        emit QuestionAdded(questionCount, _questionText);
        questionCount++;
    }
    
    // Submit answers and record score
    function submitQuiz(uint256[] memory _answers) public {
        require(_answers.length <= questionCount, "Too many answers submitted");
        require(_answers.length > 0, "Must answer at least one question");
        
        uint256 score = 0;
        
        // Calculate score
        for (uint256 i = 0; i < _answers.length; i++) {
            if (questions[i].exists && _answers[i] == questions[i].correctAnswerIndex) {
                score++;
            }
        }
        
        // Check if player is new
        if (playerScores[msg.sender].timestamp == 0) {
            players.push(msg.sender);
        }
        
        // Record score (immutable - each new submission overwrites)
        playerScores[msg.sender] = PlayerScore({
            player: msg.sender,
            score: score,
            totalQuestions: _answers.length,
            timestamp: block.timestamp
        });
        
        emit QuizCompleted(msg.sender, score, _answers.length);
    }
    
    // Get question details
    function getQuestion(uint256 _questionId) public view returns (
        string memory questionText,
        string[] memory options
    ) {
        require(questions[_questionId].exists, "Question does not exist");
        Question memory q = questions[_questionId];
        return (q.questionText, q.options);
    }
    
    // Get player's score
    function getPlayerScore(address _player) public view returns (
        uint256 score,
        uint256 totalQuestions,
        uint256 timestamp
    ) {
        PlayerScore memory ps = playerScores[_player];
        return (ps.score, ps.totalQuestions, ps.timestamp);
    }
    
    // Get total number of players
    function getPlayerCount() public view returns (uint256) {
        return players.length;
    }
    
    // Get leaderboard (returns top players)
    function getLeaderboard(uint256 _limit) public view returns (
        address[] memory topPlayers,
        uint256[] memory scores
    ) {
        uint256 limit = _limit > players.length ? players.length : _limit;
        topPlayers = new address[](limit);
        scores = new uint256[](limit);
        
        for (uint256 i = 0; i < limit && i < players.length; i++) {
            topPlayers[i] = players[i];
            scores[i] = playerScores[players[i]].score;
        }
        
        return (topPlayers, scores);
    }
}
```

### Step 3: Deploy the Contract
You can deploy using:
- **Remix IDE:** Copy the contract code and deploy via Remix
- **Hardhat:** Configure and deploy using deployment scripts
- **Truffle:** Use Truffle migrations for deployment

### Step 4: Interact with the Contract
Use the deployed contract address to interact via:
- Web3.js
- Ethers.js
- Remix IDE
- BlockScout contract interface

---

## 💡 Usage Examples

### Adding a Question (Owner Only)
```javascript
await contract.addQuestion(
  "What is the capital of France?",
  ["London", "Berlin", "Paris", "Madrid"],
  2 // Index of correct answer (Paris)
);
```

### Submitting Quiz Answers
```javascript
// Player submits answers: [0, 2, 1] representing their choices
await contract.submitQuiz([0, 2, 1]);
```

### Viewing Your Score
```javascript
const score = await contract.getPlayerScore("YOUR_WALLET_ADDRESS");
console.log(`Score: ${score.score}/${score.totalQuestions}`);
```

---

## 🎮 How to Play

1. **Connect Your Wallet** to Celo Sepolia Testnet
2. **Get Test Tokens** from the Celo faucet
3. **View Available Questions** using `getQuestion(id)`
4. **Submit Your Answers** using `submitQuiz([answer1, answer2, ...])`
5. **Check the Leaderboard** to see how you rank!

---

## 🗺️ Roadmap

- [ ] Add question categories and difficulty levels
- [ ] Implement time-limited quizzes
- [ ] Token rewards for top scorers
- [ ] Multiple quiz support (different quiz IDs)
- [ ] Frontend web interface
- [ ] Mobile app integration
- [ ] NFT badges for achievements

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author
Ayush Upadhyay

---

## 🙏 Acknowledgments

- Built with ❤️ on the Celo blockchain
- Inspired by the decentralized learning movement
- Thanks to the Solidity and Web3 community

---

- Open an [Issue](https://github.com/XXX/doodle-trivia/issues)
- Join our community discussions
- Check the [Celo Documentation](https://docs.celo.org/)

---

<div align="center">

### ⭐ Star this repo if you found it helpful!

Made with 🎮 and blockchain magic

</div>
