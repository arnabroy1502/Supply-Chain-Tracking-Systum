// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Supply Chain Tracking Syste
 * @dev Tracks products through the supply chain with ownership transfers and status updates
 */
contract SupplyChainTracker {
    // Enum for product status
    enum ProductStatus {
        Manufactured,
        InTransit,
        Delivered,

    // Product structure
    struct Product {
        uint256 id;
        string name
        address manufacturer;
        address currentOwner;
        uint256
        ProductStatus status;
        string metadata; // IPFS hash or additional info
        
    }
 }

    // Product structure
    struct Product {
        uint256 id;
        string name;
        address manufacturer;
        address currentOwner;
        uint256 timestamp;
        ProductStatus status;
        string metadata; // IPFS hash or additional info
        bool deleted; // Soft delete
    }

    // Mapping from product ID to Product
    mapping(uint256 => Product) public products;
    
    // Mapping from product ID to ownership history
    mapping(uint256 => address[]) public productHistory;

    // Mapping from address to product IDs owned (latest)
    mapping(address => uint256[]) private ownerToProducts;

    // Product counter
    uint256 private productCount = 0;
    // Events
    event ProductCreated(uint256 indexed productId, string name, address indexed manufacturer);
    event OwnershipTransferred(uint256 indexed productId, address indexed from, address indexed to);
    event StatusUpdated(uint256 indexed productId, ProductStatus newStatus);
    event MetadataUpdated(uint256 indexed productId, string newMetadata);
    event ProductDeleted(uint256 indexed productId);

    /**
     * @dev Register a new product in the supply chain
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
            metadata: _metadata,
            deleted: false
        });

        productHistory[productId].push(msg.sender);
        ownerToProducts[msg.sender].push(productId);

        emit ProductCreated(productId, _name, msg.sender);
        return productId;
    }

    /**
     * @dev Transfer ownership of a product
     */
    function transferOwnership(uint256 _productId, address _newOwner) public {
        Product storage product = products[_productId];
        require(product.id != 0 && !product.deleted, "Product not found");
        require(product.currentOwner == msg.sender, "Not product owner");
        require(_newOwner != address(0), "Invalid address");

        address oldOwner = product.currentOwner;
        product.currentOwner = _newOwner;
        product.timestamp = block.timestamp;

        productHistory[_productId].push(_newOwner);
        ownerToProducts[_newOwner].push(_productId);

        emit OwnershipTransferred(_productId, oldOwner, _newOwner);
    }

    /**
     * @dev Update product status
     */
    function updateProductStatus(uint256 _productId, ProductStatus _status) public {
        Product storage product = products[_productId];
        require(product.id != 0 && !product.deleted, "Product not found");
        require(product.currentOwner == msg.sender, "Not product owner");

        product.status = _status;
        product.timestamp = block.timestamp;

        emit StatusUpdated(_productId, _status);
    }

    /**
     * @dev Update product metadata
     */
    function updateMetadata(uint256 _productId, string memory _newMetadata) public {
        Product storage product = products[_productId];
        require(product.id != 0 && !product.deleted, "Product not found");
        require(product.currentOwner == msg.sender, "Not product owner");

        product.metadata = _newMetadata;
        product.timestamp = block.timestamp;

        emit MetadataUpdated(_productId, _newMetadata);
    }

    /**
     * @dev Get product details
     */
    function getProduct(uint256 _productId) public view returns (
        uint256, string memory, address, address, uint256, ProductStatus, string memory, bool
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
            product.metadata,
            product.deleted
        );
    }

    /**
     * @dev Get ownership history of a product
     */
    function getProductHistory(uint256 _productId) public view returns (address[] memory) {
        require(products[_productId].id != 0, "Product not found");
        return productHistory[_productId];
    }

    /**
     * @dev Get all product IDs owned by a user
     */
    function getAllProductIdsByOwner(address _owner) public view returns (uint256[] memory) {
        return ownerToProducts[_owner];
    }

    /**
     * @dev Get current status of a product
     */
    function getProductStatus(uint256 _productId) public view returns (ProductStatus) {
        Product memory product = products[_productId];
        require(product.id != 0 && !product.deleted, "Product not found");
        return product.status;
    }

    /**
     * @dev Soft delete a product (only manufacturer)
     */
    function deleteProduct(uint256 _productId) public {
        Product storage product = products[_productId];
        require(product.id != 0, "Product not found");
        require(product.manufacturer == msg.sender, "Only manufacturer can delete");

        product.deleted = true;
        product.timestamp = block.timestamp;

        emit ProductDeleted(_productId);
    }
}
