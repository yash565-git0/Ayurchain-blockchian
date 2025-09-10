// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ProvenanceTracker {
    struct TrackingRecord {
        string productId;
        address actor;
        string actorName;
        string location;
        uint256 timestamp;
        string action; // "manufactured", "shipped", "received", "processed", "sold"
        string additionalData; // Temperature, quality notes, etc.
        string ipfsHash; // For storing photos/documents
    }
    
    mapping(string => TrackingRecord[]) public productJourney;
    mapping(address => bool) public authorizedActors;
    mapping(address => string) public actorNames;
    
    address public owner;
    
    event LocationUpdated(
        string indexed productId, 
        address indexed actor,
        string location,
        string action,
        uint256 timestamp
    );
    event ActorAuthorized(address indexed actor, string name);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier onlyAuthorizedActor() {
        require(authorizedActors[msg.sender], "Not an authorized actor");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function authorizeActor(address _actor, string memory _name) 
        external onlyOwner {
        authorizedActors[_actor] = true;
        actorNames[_actor] = _name;
        emit ActorAuthorized(_actor, _name);
    }
    
    function updateLocation(
        string memory _productId,
        string memory _location,
        string memory _action,
        string memory _additionalData,
        string memory _ipfsHash
    ) external onlyAuthorizedActor {
        TrackingRecord memory newRecord = TrackingRecord({
            productId: _productId,
            actor: msg.sender,
            actorName: actorNames[msg.sender],
            location: _location,
            timestamp: block.timestamp,
            action: _action,
            additionalData: _additionalData,
            ipfsHash: _ipfsHash
        });
        
        productJourney[_productId].push(newRecord);
        
        emit LocationUpdated(_productId, msg.sender, _location, _action, block.timestamp);
    }
    
    function getProductJourney(string memory _productId) 
        external view returns (TrackingRecord[] memory) {
        return productJourney[_productId];
    }
    
    function getJourneyLength(string memory _productId) 
        external view returns (uint256) {
        return productJourney[_productId].length;
    }
    
    function getLatestLocation(string memory _productId) 
        external view returns (TrackingRecord memory) {
        require(productJourney[_productId].length > 0, "No tracking records found");
        return productJourney[_productId][productJourney[_productId].length - 1];
    }
}
