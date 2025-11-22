Add more statuses as required
    }

    struct Item {
        uint256 id;
        string description;
        address creator;
        Status currentStatus;
        uint256 timestamp;
        bool exists;
    }

    Mapping from item ID to Item details
    mapping(uint256 => Item) private items;

    Authorized participants who can update status
    mapping(address => bool) public authorizedParticipants;

    Owner authorized by default
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

        End
End
End
End
End
End
End
End
// 
// 
End
// 
