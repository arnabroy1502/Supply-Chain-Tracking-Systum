// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Supply Chain Tracking System
 * @dev Tracks products through the supply chain with ownership transfers and status updates
 */
contract SupplyChainTracker {
    // Enum for product status
    enum ProductStatus {
        Manufactured,
        InTransit,
        Delivered,
        Sold
    }

    // Product structure
    struct Product {
        uint256 id;
        string name;
        address manufacturer;
        address currentOwner;
        uint256 timestamp;
        ProductStatus status;
        string metadata; // Additional product information (could be IPFS hash)
    }

    // Mapping from product ID to Product
    mapping(uint256 => Product) public products;
    
    // Mapping from product ID to its history (addresses of previous owners)
    mapping(uint256 => address[]) public productHistory;
    
    // Events
    event ProductCreated(uint256 indexed productId, string name, address indexed manufacturer);
    event OwnershipTransferred(uint256 indexed productId, address indexed previousOwner, address indexed newOwner);
    event StatusUpdated(uint256 indexed productId, ProductStatus newStatus);

    // Product counter
    uint256 private productCount = 0;

    /**
     * @dev Register a new product in the supply chain
     * @param _name Name of the product
     * @param _metadata Additional product information
     * @return productId The ID of the newly created product
     */
    function createProduct(string memory _name, string memory _metadata) public returns (uint256) {
        productCount++;
        uint256 productId = productCount;
        
        products[productId] = Product({
            id: productId,
            name: _name,
            manufacturer: msg.sender,
            currentOwner: msg.sender,
            timestamp: block.timestamp,
            status: ProductStatus.Manufactured,
            metadata: _metadata
        });
        
        // Initialize product history with manufacturer
        productHistory[productId].push(msg.sender);
        
        emit ProductCreated(productId, _name, msg.sender);
        
        return productId;
    }

    /**
     * @dev Transfer ownership of a product to a new owner
     * @param _productId ID of the product
     * @param _newOwner Address of the new owner
     */
    function transferOwnership(uint256 _productId, address _newOwner) public {
        Product storage product = products[_productId];
        
        // Check if product exists and sender is current owner
        require(product.id != 0, "Product does not exist");
        require(product.currentOwner == msg.sender, "Only the current owner can transfer ownership");
        require(_newOwner != address(0), "New owner cannot be zero address");
        
        address previousOwner = product.currentOwner;
        product.currentOwner = _newOwner;
        product.timestamp = block.timestamp;
        
        // Add to product history
        productHistory[_productId].push(_newOwner);
        
        emit OwnershipTransferred(_productId, previousOwner, _newOwner);
    }

    /**
     * @dev Update the status of a product
     * @param _productId ID of the product
     * @param _newStatus New status to set
     */
    function updateProductStatus(uint256 _productId, ProductStatus _newStatus) public {
        Product storage product = products[_productId];
        
        // Check if product exists and sender is current owner
        require(product.id != 0, "Product does not exist");
        require(product.currentOwner == msg.sender, "Only the current owner can update status");
        
        product.status = _newStatus;
        product.timestamp = block.timestamp;
        
        emit StatusUpdated(_productId, _newStatus);
    }

    /**
     * @dev Get complete ownership history of a product
     * @param _productId ID of the product
     * @return Array of addresses representing previous owners
     */
    function getProductHistory(uint256 _productId) public view returns (address[] memory) {
        require(products[_productId].id != 0, "Product does not exist");
        return productHistory[_productId];
    }

    /**
     * @dev Get product details
     * @param _productId ID of the product
     * @return id Product ID
     * @return name Product name
     * @return manufacturer Address of the manufacturer
     * @return currentOwner Address of the current owner
     * @return timestamp Time of the last update
     * @return status Current status of the product
     * @return metadata Additional product information
     */
    function getProduct(uint256 _productId) public view returns (
        uint256 id,
        string memory name,
        address manufacturer,
        address currentOwner,
        uint256 timestamp,
        ProductStatus status,
        string memory metadata
    ) {
        Product memory product = products[_productId];
        require(product.id != 0, "Product does not exist");
        
        return (
            product.id,
            product.name,
            product.manufacturer,
            product.currentOwner,
            product.timestamp,
            product.status,
            product.metadata
        );
    }
}
