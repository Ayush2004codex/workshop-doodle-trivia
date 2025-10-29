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
