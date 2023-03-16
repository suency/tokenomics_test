// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RBTToken {
    string public name = "RBT";
    string public symbol = "RBT";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000000 * (10 ** uint256(decimals));

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    mapping(address => uint256) public ecosystemDevelopmentAllocations;
    mapping(address => uint256) public projectDevelopmentAllocations;
    mapping(address => uint256) public privateSaleAllocations;

    uint256 public ecosystemDevelopmentTokensLocked = (totalSupply * 50) / 100;
    uint256 public ecosystemDevelopmentTokensUnlocked = 0;
    uint256 public ecosystemDevelopmentTokensUnlockingPerDay =
        ecosystemDevelopmentTokensLocked / (365 * 5);

    uint256 public projectDevelopmentTokensLocked = (totalSupply * 25) / 100;
    uint256 public projectDevelopmentTokensUnlocked = 0;
    uint256 public projectDevelopmentTokensUnlockingPerDay =
        projectDevelopmentTokensLocked / (365 * 2);

    uint256 public privateSaleTokensLocked = (totalSupply * 15) / 100;
    uint256 public privateSaleTokensUnlocked = 0;
    uint256 public privateSaleTokensUnlockingPerDay =
        privateSaleTokensLocked / 365;

    address public foundationReserve = 0xDD63D068f89ceAd467332170fB0DE790a5d26e15;
    address public publicSale = 0xA643969BCF5a3891f4E51c14F8Aa3491C2189918;

    bool public ecosystemDevelopmentTokensLockedChecked = false;
    bool public projectDevelopmentTokensLockedChecked = false;
    bool public privateSaleTokensLockedChecked = false;

    address public owner;

    constructor() {
        owner = msg.sender;
        balances[msg.sender] = totalSupply;
        balances[publicSale] =  (totalSupply * 5) / 100;
        balances[foundationReserve] =  (totalSupply * 5) / 100;
    }

    // Define function for unlocking ecosystem development tokens
    function unlockEcosystemDevelopmentTokens() external {
        require(
            msg.sender == owner,
            "Only owner can unlock ecosystem development tokens."
        );
        require(
            !ecosystemDevelopmentTokensLockedChecked,
            "Ecosystem development tokens have already been unlocked."
        );

        uint256 daysSinceContractCreation = (block.timestamp -
            (block.timestamp % 86400)) / 86400;
        ecosystemDevelopmentTokensUnlocked =
            ecosystemDevelopmentTokensUnlockingPerDay *
            daysSinceContractCreation;

        if (
            ecosystemDevelopmentTokensUnlocked >=
            ecosystemDevelopmentTokensLocked
        ) {
            ecosystemDevelopmentTokensUnlocked = ecosystemDevelopmentTokensLocked;
            ecosystemDevelopmentTokensLockedChecked = true;
        }

        balances[owner] -= ecosystemDevelopmentTokensUnlocked;
        ecosystemDevelopmentAllocations[
            owner
        ] += ecosystemDevelopmentTokensUnlocked;
    }

    // Define function for unlocking project development tokens
    function unlockProjectDevelopmentTokens() external {
        require(
            msg.sender == owner,
            "Only owner can unlock project development tokens."
        );
        require(
            !projectDevelopmentTokensLockedChecked,
            "Project development tokens have already been unlocked."
        );

        uint256 daysSinceContractCreation = (block.timestamp -
            (block.timestamp % 86400)) / 86400;
        projectDevelopmentTokensUnlocked =
            projectDevelopmentTokensUnlockingPerDay *
            daysSinceContractCreation;

        if (
            projectDevelopmentTokensUnlocked >= projectDevelopmentTokensLocked
        ) {
            projectDevelopmentTokensUnlocked = projectDevelopmentTokensLocked;
            projectDevelopmentTokensLockedChecked = true;
        }

        balances[owner] -= projectDevelopmentTokensUnlocked;
        projectDevelopmentAllocations[
            owner
        ] += projectDevelopmentTokensUnlocked;
    }

    // Define function for unlocking private sale
    function unlockPrivateSaleTokens() external {
        require(
            msg.sender == owner,
            "Only owner can unlock private sale tokens."
        );
        require(
            !privateSaleTokensLockedChecked,
            "Private sale tokens have already been unlocked."
        );

        // uint256 daysSinceContractCreation = (block.timestamp - (block.timestamp % 86400)) / 86400;
        privateSaleTokensUnlocked = privateSaleTokensLocked;

        balances[owner] -= privateSaleTokensUnlocked;
        privateSaleAllocations[owner] += privateSaleTokensUnlocked;

        privateSaleTokensLockedChecked = true;
    }

    // Define function for transferring tokens
    function transfer(
        address _to,
        uint256 _value
    ) external returns (bool success) {
        require(balances[msg.sender] >= _value, "Insufficient balance.");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Define function for approving another address to spend tokens on behalf of the sender
    function approve(
        address _spender,
        uint256 _value
    ) external returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Define function for transferring tokens on behalf of another address
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success) {
        require(balances[_from] >= _value, "Insufficient balance.");
        require(
            allowed[_from][msg.sender] >= _value,
            "Not allowed to spend this amount."
        );
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    // Define event for logging transfers
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Define event for logging approvals
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}
