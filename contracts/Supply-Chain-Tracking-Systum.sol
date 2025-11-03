// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SupplyChainTrackingSystem
 * @dev Allows authorized participants to add and update supply chain items with multiple status updates.
 */
contract SupplyChainTrackingSystem {
    address public owner;

    enum Status {
        Created,
        InTransit,
        Delivered,
        Verified,
        Rejected
        // Add more statuses as required
    }

    struct Item {
        uint256 id;
        string description;
        address creator;
        Status currentStatus;
        uint256 timestamp;
        bool exists;
    }

    // Status update history per item
    struct StatusUpdate {
        Status status;
        uint256 timestamp;
        address updatedBy;
        string remarks;
    }

    // Mapping from item ID to Item details
    mapping(uint256 => Item) private items;

    // Mapping from item ID to array of status updates
    mapping(uint256 => StatusUpdate[]) private itemStatusHistory;

    // Authorized participants who can update status
    mapping(address => bool) public authorizedParticipants;

    // Events
    event ItemCreated(uint256 indexed id, string description, address indexed creator, uint256 timestamp);
    event StatusUpdated(uint256 indexed id, Status status, address indexed updatedBy, string remarks, uint256 timestamp);
    event ParticipantAuthorized(address indexed participant);
    event ParticipantRevoked(address indexed participant);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    modifier onlyAuthorized() {
        require(authorizedParticipants[msg.sender], "Caller not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
        authorizedParticipants[msg.sender] = true; // Owner authorized by default
    }

    /**
     * @dev Authorize a participant to update item statuses
     */
    function authorizeParticipant(address participant) external onlyOwner {
        require(participant != address(0), "Invalid address");
        authorizedParticipants[participant] = true;
        emit ParticipantAuthorized(participant);
    }

    /**
     * @dev Revoke authorization from a participant
     */
    function revokeParticipant(address participant) external onlyOwner {
        require(authorizedParticipants[participant], "Participant not authorized");
        authorizedParticipants[participant] = false;
        emit ParticipantRevoked(participant);
    }

    /**
     * @dev Create a new supply chain item
     */
    function createItem(uint256 id, string memory description) external onlyAuthorized {
        require(!items[id].exists, "Item with given ID already exists");

        items[id] = Item({
            id: id,
            description: description,
            creator: msg.sender,
            currentStatus: Status.Created,
            timestamp: block.timestamp,
            exists: true
        });

        // Initial status update
        itemStatusHistory[id].push(StatusUpdate({
            status: Status.Created,
            timestamp: block.timestamp,
            updatedBy: msg.sender,
            remarks: "Item created"
        }));

        emit ItemCreated(id, description, msg.sender, block.timestamp);
    }

    /**
     * @dev Update the status of an existing item
     */
    function updateItemStatus(uint256 id, Status newStatus, string memory remarks) external onlyAuthorized {
        require(items[id].exists, "Item does not exist");
        require(newStatus != items[id].currentStatus, "Status unchanged");

        items[id].currentStatus = newStatus;
        items[id].timestamp = block.timestamp;

        itemStatusHistory[id].push(StatusUpdate({
            status: newStatus,
            timestamp: block.timestamp,
            updatedBy: msg.sender,
            remarks: remarks
        }));

        emit StatusUpdated(id, newStatus, msg.sender, remarks, block.timestamp);
    }

    /**
     * @dev Get current status and basic info of an item
     */
    function getItem(uint256 id) external view returns (
        uint256 itemId,
        string memory description,
        address creator,
        Status currentStatus,
        uint256 lastUpdated
    ) {
        require(items[id].exists, "Item does not exist");
        Item memory item = items[id];

        return (
            item.id,
            item.description,
            item.creator,
            item.currentStatus,
            item.timestamp
        );
    }

    /**
     * @dev Get full status update history of an item
     */
    function getStatusHistory(uint256 id) external view returns (StatusUpdate[] memory) {
        require(items[id].exists, "Item does not exist");
        return itemStatusHistory[id];
    }
}
