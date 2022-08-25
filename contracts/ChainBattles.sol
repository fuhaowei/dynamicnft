// deployed to 0x7Ee9E6fB6F81A3948A4bd0A8bB64BB4E960f1684
//dynamic nft at 0x7bcd1961f0eb599114b8a8ee4bf0d3f164f52d9ba0989959c94616f6d06e557d 


//updated contract deployed to  0xAfAc884Ee63844B951BdACc214A8285e86DAa94c
//see on opensea test networks 0xafac884ee63844b951bdacc214a8285e86daa94c


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

    //store the level of an NFT associated with the tokenid


    struct CardData {
        uint256 levels;
        uint256 strength;
        uint256 life;
    }

    mapping(uint256 => CardData) public tokenIdtoData;

    //constructor takes in 2 variables, name and something else. rmbr
    constructor() ERC721("Chain Battles", "CBTLS"){
        
    }

    //generate a SVG, update the nft's one
    function generateCharacter(uint256 tokenId) public returns (string memory){
        bytes memory svg = abi.encodePacked('<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
        '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
        '<rect width="100%" height="100%" fill="black" />',
        '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Warrior",'</text>',
        '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",getLevels(tokenId),'</text>',
        '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Strength: ",getStrength(tokenId),'</text>',
        '<text x="50%" y="90%" class="base" dominant-baseline="middle" text-anchor="middle">', "Life: ",getLife(tokenId),'</text>',
        '</svg>');

        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg))
        );
    }
    

    //getting the current possible level of an nft
    function getLevels(uint256 tokenId) public view returns (string memory){
        CardData memory tempdata = tokenIdtoData[tokenId];
        // we nede string, because abi.encodePacked must resolve to strings!
        return tempdata.levels.toString();
    }
    function getStrength(uint256 tokenId) public view returns (string memory){
        CardData memory tempdata = tokenIdtoData[tokenId];
        // we nede string, because abi.encodePacked must resolve to strings!
        return tempdata.strength.toString();
    }
    function getLife(uint256 tokenId) public view returns (string memory){
        CardData memory tempdata = tokenIdtoData[tokenId];
        // we nede string, because abi.encodePacked must resolve to strings!
        return tempdata.life.toString();
    }

    //this allows opensea to get that token uri of the nft
    function getTokenURI(uint256 tokenId) public returns (string memory){

        // using abi encode pack to create json object this time tho!
        bytes memory dataURI = abi.encodePacked(
        '{',
            '"name": "Chain Battles #', tokenId.toString(), '",',
            '"description": "Battles on chain",',
            '"image": "', generateCharacter(tokenId), '"',
        '}');

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(dataURI)));
    }

    function random(uint number) public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
    }

    //mint just to mint
    function mint() public {
        //create new nft

        //increment value of tokenid variable, 
        //store its current value in new uint256 variable
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        //called from openzep library, pass msg sender and current id
        _safeMint(msg.sender,newItemId);

        //make new item, assign value to 0!
        CardData memory newcard;
        newcard.levels = random(30);
        newcard.strength = random(30);
        newcard.life = random(30);

        tokenIdtoData[newItemId] = newcard;

        //set d token uri, from ERC standard
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }


    //train just to train nft, raise the level possible
    function train(uint256 tokenId) public {
        // _exists is from erc721 standard
        require(_exists(tokenId), "please use existing token.");
        //ownerOf is from lirbary as well
        require(ownerOf(tokenId) == msg.sender, "you must own this token to train it");

        uint256 currentLevel = tokenIdtoData[tokenId].levels;
        tokenIdtoData[tokenId].levels = currentLevel + 1;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }


}