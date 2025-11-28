// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title SupplyChainTrackingSystem
 * @dev Simple supply-chain tracker for items moving through multiple checkpoints
 * @notice Manufacturer registers items; actors append status updates along the chain
 */
contract SupplyChainTrackingSystem {
    address public owner;

    enum Status {
        Created,
        InTransit,
        AtWarehouse,
        Delivered,
        Rejected,
        Cancelled
    }

    struct Checkpoint {
        uint256 timestamp;
        string  location;
        string  note;
        Status  status;
        address actor;
    }

    struct Item {
        bytes32 id;            // unique item id (e.g. hash or serial)
        string  description;
        address manufacturer;
        bool    active;
        uint256 createdAt;
    }

    // itemId => Item
    mapping(bytes32 => Item) public items;

    // itemId => list of checkpoints
    mapping(bytes32 => Checkpoint[]) public historyOf;

    // manufacturer => itemIds
    mapping(address => bytes32[]) public itemsOf;

    event ItemRegistered(
        bytes32 indexed id,
        address indexed manufacturer,
        string description,
        uint256 timestamp
    );

    event StatusUpdated(
        bytes32 indexed id,
        Status status,
        string location,
        string note,
        address actor,
        uint256 timestamp
    );

    event ItemDeactivated(bytes32 indexed id, uint256 timestamp);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier itemExists(bytes32 id) {
        require(items[id].manufacturer != address(0), "Item not found");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Register a new item at the start of the supply chain
     * @param id Unique identifier (e.g. keccak of serial)
     * @param description Human-readable description
     */
    function registerItem(bytes32 id, string calldata description) external {
        require(id != 0, "Invalid id");
        require(items[id].manufacturer == address(0), "Already exists");

        items[id] = Item({
            id: id,
            description: description,
            manufacturer: msg.sender,
            active: true,
            createdAt: block.timestamp
        });

        itemsOf[msg.sender].push(id);

        // initial checkpoint: Created
        historyOf[id].push(
            Checkpoint({
                timestamp: block.timestamp,
                location: "ORIGIN",
                note: "Item created",
                status: Status.Created,
                actor: msg.sender
            })
        );

        emit ItemRegistered(id, msg.sender, description, block.timestamp);
        emit StatusUpdated(id, Status.Created, "ORIGIN", "Item created", msg.sender, block.timestamp);
    }

    /**
     * @dev Append a new status checkpoint to an item
     * @param id Item identifier
     * @param status New status
     * @param location Location string
     * @param note Optional note
     */
    function addCheckpoint(
        bytes32 id,
        Status status,
        string calldata location,
        string calldata note
    )
        external
        itemExists(id)
    {
        require(items[id].active, "Item inactive");

        historyOf[id].push(
            Checkpoint({
                timestamp: block.timestamp,
                location: location,
                note: note,
                status: status,
                actor: msg.sender
            })
        );

        emit StatusUpdated(id, status, location, note, msg.sender, block.timestamp);
    }

    /**
     * @dev Deactivate an item (manufacturer or owner)
     */
    function deactivateItem(bytes32 id)
        external
        itemExists(id)
    {
        require(
            msg.sender == items[id].manufacturer || msg.sender == owner,
            "Not authorized"
        );
        require(items[id].active, "Already inactive");

        items[id].active = false;
        emit ItemDeactivated(id, block.timestamp);
    }

    /**
     * @dev Get all itemIds registered by a manufacturer
     */
    function getItemsOf(address manufacturer)
        external
        view
        returns (bytes32[] memory)
    {
        return itemsOf[manufacturer];
    }

    /**
     * @dev Get full history (checkpoints) for an item
     */
    function getHistory(bytes32 id)
        external
        view
        itemExists(id)
        returns (Checkpoint[] memory)
    {
        return historyOf[id];
    }

    /**
     * @dev Transfer contract ownership
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        address prev = owner;
        owner = newOwner;
        emit OwnershipTransferred(prev, newOwner);
    }
}
