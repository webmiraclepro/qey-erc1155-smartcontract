// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// @dev Implementation for different URIs for every token
contract TokenURI {
    // mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    function _tokenURI(uint256 tokenId) internal view returns (string memory) {
        return _tokenURIs[tokenId];
    }

    function _setTokenURI(uint256 tokenId, string memory tokenUri)
        internal
        virtual
    {
        _tokenURIs[tokenId] = tokenUri;
    }
}

contract Qey is ERC1155, Ownable, TokenURI {
    // Hashes of meme pictures on IPFS
    mapping(uint256 => string) public hashes;
    uint256 public hashesParcel1;
    uint256 public hashesParcel2;
    uint256 public hashesParcel3;
    uint256 public hashesParcel4;
    uint256 public hashesGenesis;

    // Mapping for tokentype
    mapping(uint256 => uint256) public tokenTypes;
    // Mapping for enforcing unique hashes
    mapping(string => bool) _hashExists;

    // Mapping from NFT token ID to owner
    mapping(uint256 => address) private _tokenOwner;

    // Mapping from hash to NFT token ID
    mapping(string => address) private _hashToken;
    mapping(address => bool) private _whitelist;
    bool publicSale;

    constructor(address[] memory whitelist)
        ERC1155("https://game.example/api/item/{id}.json")
    {
        for (uint256 i = 0; i < whitelist.length; i++) {
            _whitelist[whitelist[i]] = true;
        }
    }

    function publish() public onlyOwner {
        publicSale = true;
    }

    modifier isAuthorized() {
        require(
            (publicSale || _whitelist[_msgSender()]),
            "Only whitelist can mint token"
        );
        _;
    }

    function mint(string memory _hash, string memory _uri) public isAuthorized {
        require(!_hashExists[_hash], "Token is already minted");
        require(bytes(_uri).length > 0, "uri should be set");
        uint256 remainSupply = 3939 -
            hashesParcel1 -
            hashesParcel2 -
            hashesParcel3 -
            hashesParcel4;
        require(remainSupply > 0, "Exceed mint ammount");
        uint256 rand = uint256(keccak256(abi.encodePacked(_hash))) %
            remainSupply;
        uint256 idType;
        uint256 remainP1 = 1261 - hashesParcel1;
        uint256 remainP2 = 1261 - hashesParcel2;
        uint256 remainP3 = 1261 - hashesParcel3;
        uint256 remainP4 = 156 - hashesParcel4;
        if (rand < (remainP1 * 7) / 10)
            idType = 1; // parcel1 with one number    70%
        else if (rand < remainP1)
            idType = 2; // parcel1 with two numbers   30%
        else if (rand < remainP1 + (remainP2 * 7) / 10)
            idType = 3; // parcel2 with one number    70%
        else if (rand < remainP1 + remainP2)
            idType = 4; // parcel2 with two numbers   30%
        else if (rand < remainP1 + remainP2 + (remainP3 * 6) / 10)
            idType = 5; // parcel3 with one number    60%
        else if (rand < remainP1 + remainP2 + (remainP3 * 8) / 10)
            idType = 6; // parcel3 with two numbers   20%
        else if (rand < remainP1 + remainP2 + (remainP3 * 9) / 10)
            idType = 7; // parcel3 with three numbers 10%
        else if (rand < remainSupply - remainP4)
            idType = 8; // parcel3 with four numbers  10%
        else if (rand < remainSupply - (remainP4 * 3) / 10)
            idType = 9; // parcel4 with one number    70%
        else idType = 10; // parcel4 with two number    30%

        uint256 _id;
        if (idType < 3) {
            _id = hashesParcel1;
            hashesParcel1++;
        } else if (idType < 5) {
            _id = hashesParcel2 + 1261;
            hashesParcel2++;
        } else if (idType < 9) {
            _id = hashesParcel3 + 1261 * 2;
            hashesParcel3++;
        } else {
            _id = hashesParcel4 + 1261 * 3;
            hashesParcel4++;
        }

        _mint(msg.sender, _id, 1, "");
        hashes[_id] = _hash;
        tokenTypes[_id] = idType;
        _setTokenURI(_id, _uri);
        _hashExists[_hash] = true;
    }

    function burn(string memory _uri, uint256 token1) public {
        burn(_uri, token1, 10000, 10000);
    }

    function burn(
        string memory _uri,
        uint256 token1,
        uint256 token2,
        uint256 token3
    ) public {
        require(bytes(_uri).length > 0, "uri should be set");
        require(
            balanceOf(msg.sender, token1) >= 1,
            "Should be owner of first token"
        );
        string memory _hash;
        uint256 idType;
        if (tokenTypes[token1] == 1 || tokenTypes[token1] == 2) {
            require(
                balanceOf(msg.sender, token2) >= 1,
                "Should be owner of second token"
            );
            require(
                balanceOf(msg.sender, token3) >= 1,
                "Should be owner of third token"
            );
            require(
                tokenTypes[token2] == 3 ||
                    tokenTypes[token2] == 4 ||
                    tokenTypes[token3] > 4 ||
                    tokenTypes[token3] < 4,
                "Token 2 should be parcel2, token 3 should be parcel3"
            );
            _burn(msg.sender, token2, 1);
            _burn(msg.sender, token3, 1);
            _hash = string(
                abi.encodePacked(hashes[token1], hashes[token2], hashes[token3])
            );
            idType =
                tokenTypes[token1] +
                tokenTypes[token2] +
                tokenTypes[token3] +
                2;
        } else if (tokenTypes[token1] == 9 || tokenTypes[token1] == 10) {
            _hash = hashes[token1];
            idType = 16;
        } else require(false, "parcel 1,2,3 or parcel 4 can be burnt");
        _burn(msg.sender, token1, 1);

        // complete burn for blockchain
        hashes[token1] = "";
        tokenTypes[token1] = 20;
        _setTokenURI(token1, "");
        _hashExists[_hash] = false;

        hashes[token2] = "";
        tokenTypes[token2] = 20;
        _setTokenURI(token2, "");
        _hashExists[_hash] = false;

        hashes[token3] = "";
        tokenTypes[token3] = 20;
        _setTokenURI(token3, "");
        _hashExists[_hash] = false;
        // end of burnt

        uint256 _id = 3939 + hashesGenesis;
        hashesGenesis++;

        _mint(msg.sender, _id, 1, "");
        hashes[_id] = _hash;
        tokenTypes[_id] = idType;
        _setTokenURI(_id, _uri);
        _hashExists[_hash] = true;
    }

    function getQeyCount() public view returns (uint256 count) {
        return
            hashesParcel1 +
            hashesParcel2 +
            hashesParcel3 +
            hashesParcel4 +
            hashesGenesis;
    }

    function uri(uint256 _tokenId)
        public
        view
        override
        returns (string memory _uri)
    {
        return _tokenURI(_tokenId);
    }

    function setTokenUri(uint256 _tokenId, string memory _uri)
        public
        onlyOwner
    {
        _setTokenURI(_tokenId, _uri);
    }

    function safeTransferFromWithProvision(
        address payable from,
        address to,
        uint256 id,
        uint256 amount //,
    )
        public
        payable
        returns (
            //uint256 price
            bool approved
        )
    {
        setApprovalForAll(to, true);
        safeTransferFrom(from, to, id, amount, "0x0");
        return isApprovedForAll(from, to);
        // from.transfer(price);
    }
}
