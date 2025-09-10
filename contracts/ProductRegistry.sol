// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ProductRegistry {
    struct Product {
        string productId;
        string productName;
        string manufacturer;
        string category;
        uint256 manufacturingDate;
        string origin;
        string[] certifications;
        string ipfsHash; // For storing additional documents
        bool isAuthentic;
        bool exists;
    }
    
    mapping(string => Product) public products;
    mapping(address => bool) public authorizedManufacturers;
    mapping(address => string) public manufacturerNames;
    
    address public owner;
    
    event ProductRegistered(
        string indexed productId, 
        address indexed manufacturer,
        string productName,
        uint256 timestamp
    );
    event ManufacturerAuthorized(address indexed manufacturer, string name);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier onlyAuthorizedManufacturer() {
        require(authorizedManufacturers[msg.sender], "Not an authorized manufacturer");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function authorizeManufacturer(address _manufacturer, string memory _name) 
        external onlyOwner {
        authorizedManufacturers[_manufacturer] = true;
        manufacturerNames[_manufacturer] = _name;
        emit ManufacturerAuthorized(_manufacturer, _name);
    }
    
    function registerProduct(
        string memory _productId,
        string memory _productName,
        string memory _category,
        string memory _origin,
        string[] memory _certifications,
        string memory _ipfsHash
    ) external onlyAuthorizedManufacturer {
        require(!products[_productId].exists, "Product already exists");
        
        products[_productId] = Product({
            productId: _productId,
            productName: _productName,
            manufacturer: manufacturerNames[msg.sender],
            category: _category,
            manufacturingDate: block.timestamp,
            origin: _origin,
            certifications: _certifications,
            ipfsHash: _ipfsHash,
            isAuthentic: true,
            exists: true
        });
        
        emit ProductRegistered(_productId, msg.sender, _productName, block.timestamp);
    }
    
    function getProduct(string memory _productId) 
        external view returns (Product memory) {
        require(products[_productId].exists, "Product does not exist");
        return products[_productId];
    }
    
    function verifyProduct(string memory _productId) 
        external view returns (bool) {
        return products[_productId].exists && products[_productId].isAuthentic;
    }
}
