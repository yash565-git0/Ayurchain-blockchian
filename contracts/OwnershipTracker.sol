// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract OwnershipTracker {
    struct OwnershipRecord {
        string productId;
        address previousOwner;
        address currentOwner;
        string previousOwnerName;
        string currentOwnerName;
        uint256 transferDate;
        string transferReason;
        uint256 transferPrice; // in wei
    }
    
    mapping(string => OwnershipRecord[]) public ownershipHistory;
    mapping(string => address) public currentOwner;
    mapping(address => bool) public authorizedParties;
    mapping(address => string) public partyNames;
    
    address public contractOwner;
    
    event OwnershipTransferred(
        string indexed productId, 
        address indexed from, 
        address indexed to,
        string reason,
        uint256 timestamp
    );
    event PartyAuthorized(address indexed party, string name);
    
    modifier onlyContractOwner() {
        require(msg.sender == contractOwner, "Only contract owner can call this function");
        _;
    }
    
    modifier onlyAuthorizedParty() {
        require(authorizedParties[msg.sender], "Not an authorized party");
        _;
    }
    
    modifier onlyCurrentOwner(string memory _productId) {
        require(currentOwner[_productId] == msg.sender, "Not the current owner");
        _;
    }
    
    constructor() {
        contractOwner = msg.sender;
    }
    
    function authorizeParty(address _party, string memory _name) 
        external onlyContractOwner {
        authorizedParties[_party] = true;
        partyNames[_party] = _name;
        emit PartyAuthorized(_party, _name);
    }
    
    function initializeOwnership(string memory _productId, address _initialOwner) 
        external onlyContractOwner {
        require(currentOwner[_productId] == address(0), "Ownership already initialized");
        currentOwner[_productId] = _initialOwner;
        
        OwnershipRecord memory initialRecord = OwnershipRecord({
            productId: _productId,
            previousOwner: address(0),
            currentOwner: _initialOwner,
            previousOwnerName: "",
            currentOwnerName: partyNames[_initialOwner],
            transferDate: block.timestamp,
            transferReason: "Initial ownership",
            transferPrice: 0
        });
        
        ownershipHistory[_productId].push(initialRecord);
    }
    
    function transferOwnership(
        string memory _productId,
        address _newOwner,
        string memory _reason,
        uint256 _price
    ) external onlyCurrentOwner(_productId) {
        require(authorizedParties[_newOwner], "New owner is not authorized");
        
        OwnershipRecord memory newRecord = OwnershipRecord({
            productId: _productId,
            previousOwner: currentOwner[_productId],
            currentOwner: _newOwner,
            previousOwnerName: partyNames[currentOwner[_productId]],
            currentOwnerName: partyNames[_newOwner],
            transferDate: block.timestamp,
            transferReason: _reason,
            transferPrice: _price
        });
        
        ownershipHistory[_productId].push(newRecord);
        currentOwner[_productId] = _newOwner;
        
        emit OwnershipTransferred(
            _productId, 
            newRecord.previousOwner, 
            _newOwner, 
            _reason, 
            block.timestamp
        );
    }
    
    function getOwnershipHistory(string memory _productId) 
        external view returns (OwnershipRecord[] memory) {
        return ownershipHistory[_productId];
    }
    
    function getCurrentOwner(string memory _productId) 
        external view returns (address) {
        return currentOwner[_productId];
    }
}
