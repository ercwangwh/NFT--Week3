// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    struct Stats {
        uint256 Level;
        uint256 Speed;
        uint256 Strength;
        uint256 Life;
    }
    mapping(uint256 => Stats) public tokenIdToLevels;

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function generateCharacter(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            getStats(tokenId),
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getStats(uint256 tokenId) public view returns (string memory) {
        uint256 levels = tokenIdToLevels[tokenId].Level;
        uint256 strength = tokenIdToLevels[tokenId].Strength;
        uint256 speed = tokenIdToLevels[tokenId].Speed;
        uint256 life = tokenIdToLevels[tokenId].Life;
        return
            string(
                abi.encodePacked(
                    "Level: ",
                    levels.toString(),
                    "Strength: ",
                    strength.toString(),
                    "Speed: ",
                    speed.toString(),
                    "Life: ",
                    life.toString()
                )
            );
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdToLevels[newItemId].Level = 0;
        tokenIdToLevels[newItemId].Strength = 3;
        tokenIdToLevels[newItemId].Speed = 1;
        tokenIdToLevels[newItemId].Life = 5;
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId));
        require(
            ownerOf(tokenId) == msg.sender,
            "You must own this token to train it"
        );
        Stats memory currentStats = tokenIdToLevels[tokenId];
        tokenIdToLevels[tokenId].Level = currentStats.Level + 1;
        tokenIdToLevels[tokenId].Strength =
            currentStats.Strength +
            this.createRandom(10);
        tokenIdToLevels[tokenId].Speed =
            currentStats.Speed +
            this.createRandom(10);
        tokenIdToLevels[tokenId].Life =
            currentStats.Life +
            this.createRandom(10);
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    function createRandom(uint256 number) public view returns (uint) {
        return uint(blockhash(block.number - 1)) % number;
    }
}
