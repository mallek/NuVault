pragma solidity ^0.5.2;

contract NuVault {
  event Synced(address indexed user, string ipfsHash);

  mapping(address => string) public hashes;

  function saveHash(string calldata _ipfsHash) external {
    hashes[msg.sender] = _ipfsHash;
  }

  function getHash() public view returns (string memory) {
    return hashes[msg.sender];
  }
}
