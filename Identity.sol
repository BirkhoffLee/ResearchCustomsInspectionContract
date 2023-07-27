// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// https://docs.soliditylang.org/en/v0.8.21/contracts.html#function-modifiers
contract owned {
    constructor() { owner = payable(msg.sender); }
    address payable owner;

    // This contract only defines a modifier but does not use
    // it: it will be used in derived contracts.
    // The function body is inserted where the special symbol
    // `_;` in the definition of a modifier appears.
    // This means that if the owner calls this function, the
    // function is executed and otherwise, an exception is
    // thrown.
    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
    }
}

contract Identity is owned {
    enum Gender {
        Male, // 0
        Female // 1
    }

    struct IdentityInfo {
        string nationalID; // required, primary key
        string name; // required
        bool isRestrictedPersonnel; // required
        Gender gender; // required
    }

    mapping(string => IdentityInfo) identities; // nationalID => single identity
    string[] nationalIDList;

    function newIdentity(
        string calldata nationalID,
        string calldata name,
        bool isRestrictedPersonnel,
        Gender gender
    ) external onlyOwner {
        require(bytes(identities[nationalID].nationalID).length == 0, "An identity with the same national ID already exists");

        // identity
        IdentityInfo storage i = identities[nationalID];

        i.nationalID = nationalID;
        i.name = name;
        i.isRestrictedPersonnel = isRestrictedPersonnel;
        i.gender = gender;

        nationalIDList.push(nationalID);
    }

    function destroyIdentityByNationalID(string calldata nationalID) public onlyOwner {
        delete identities[nationalID];

        for (uint i = 0; i < nationalIDList.length; i++) {
            if (keccak256(abi.encodePacked(nationalIDList[i])) == keccak256(abi.encodePacked(nationalID))) {
                // Move the last element to the deleted spot
                nationalIDList[i] = nationalIDList[nationalIDList.length - 1];
                // Remove the last element.
                nationalIDList.pop();
                // TODO: fire DELETE event
            }
        }
    }

    function setRestrictionStatusByNationalID(string memory nationalID, bool isRestrictedPersonnel) public onlyOwner {
        identities[nationalID].isRestrictedPersonnel = isRestrictedPersonnel;
    }

    function getNationalIDList() public view returns (string[] memory) {
        return nationalIDList;
    }

    function getAllDataByNationalID(string memory nationalID) public view returns (IdentityInfo memory) {
        return identities[nationalID];
    }

    function getNameByNationalID(string memory nationalID) public view returns (string memory) {
        return identities[nationalID].name;
    }

    function getRestrictionStatusByNationalID(string memory nationalID) public view returns (bool) {
        return identities[nationalID].isRestrictedPersonnel;
    }

    function getGenderByNationalID(string memory nationalID) public view returns (Gender) {
        return identities[nationalID].gender;
    }
}
