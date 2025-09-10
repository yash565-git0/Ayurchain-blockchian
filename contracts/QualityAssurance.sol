// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract QualityAssurance {
    struct QualityCheck {
        string productId;
        address inspector;
        string inspectorName;
        uint256 timestamp;
        bool passed;
        uint8 score; // 0-100 quality score
        string testResults;
        string[] certifications;
        string ipfsHash; // For storing test documents/photos
    }
    
    mapping(string => QualityCheck[]) public qualityHistory;
    mapping(address => bool) public authorizedInspectors;
    mapping(address => string) public inspectorNames;
    
    address public owner;
    
    event QualityCheckCompleted(
        string indexed productId, 
        address indexed inspector,
        bool passed,
        uint8 score,
        uint256 timestamp
    );
    event InspectorAuthorized(address indexed inspector, string name);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier onlyAuthorizedInspector() {
        require(authorizedInspectors[msg.sender], "Not an authorized inspector");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function authorizeInspector(address _inspector, string memory _name) 
        external onlyOwner {
        authorizedInspectors[_inspector] = true;
        inspectorNames[_inspector] = _name;
        emit InspectorAuthorized(_inspector, _name);
    }
    
    function recordQualityCheck(
        string memory _productId,
        bool _passed,
        uint8 _score,
        string memory _testResults,
        string[] memory _certifications,
        string memory _ipfsHash
    ) external onlyAuthorizedInspector {
        require(_score <= 100, "Score must be between 0 and 100");
        
        QualityCheck memory newCheck = QualityCheck({
            productId: _productId,
            inspector: msg.sender,
            inspectorName: inspectorNames[msg.sender],
            timestamp: block.timestamp,
            passed: _passed,
            score: _score,
            testResults: _testResults,
            certifications: _certifications,
            ipfsHash: _ipfsHash
        });
        
        qualityHistory[_productId].push(newCheck);
        
        emit QualityCheckCompleted(_productId, msg.sender, _passed, _score, block.timestamp);
    }
    
    function getQualityHistory(string memory _productId) 
        external view returns (QualityCheck[] memory) {
        return qualityHistory[_productId];
    }
    
    function getLatestQualityCheck(string memory _productId) 
        external view returns (QualityCheck memory) {
        require(qualityHistory[_productId].length > 0, "No quality checks found");
        return qualityHistory[_productId][qualityHistory[_productId].length - 1];
    }
    
    function getAverageScore(string memory _productId) 
        external view returns (uint8) {
        QualityCheck[] memory checks = qualityHistory[_productId];
        require(checks.length > 0, "No quality checks found");
        
        uint256 totalScore = 0;
        for (uint i = 0; i < checks.length; i++) {
            totalScore += checks[i].score;
        }
        
        return uint8(totalScore / checks.length);
    }
}
