// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title BeggarsBelief
 * @author Created by Mitchell F Chan @mitchellfchan
 * @author Written by Matthew Younatan @matyounatan
 * @notice Allows for out-of-order token minting and collector acknlowdgement. No upper limit.
 */
contract BeggarsBelief is Ownable, ERC2981, ERC721 {
    // variables

    /// @notice The base URI of the token.
    mapping(uint256 => string) public baseURIs;

    /// @notice The collector's acknowledgement of the token.
    mapping(uint256 => string) public collectorAcknowledgement;

    /// @notice Additional information about the token.
    mapping(uint256 => string) public additionalInformation;

    // events

    /// @notice Emitted when the collector sets the acknowledgement string.
    event SetCollectorAcknowledgement(
        uint256 indexed tokenId,
        address indexed collector,
        string text
    );

    /// @notice Emitted when the collector sets the additional information string.
    event SetAdditionalInformation(
        uint256 indexed tokenId,
        address indexed collector,
        string text
    );

    // errors

    /// @notice Emitted when calling a function the requires the token to exist.
    error TokenDoesNotExist();

    /// @notice Emitted when calling a function the requires the token to not exist.
    error TokenAlreadyExists();

    /// @notice Emitted when calling a function the requires the caller to be the token owner.
    error OnlyCallableByTokenOwner();

    // modifiers

    modifier tokenExists(uint256 _tokenId) {
        if (!_exists(_tokenId)) revert TokenDoesNotExist();
        _;
    }

    modifier tokenDoesNotExist(uint256 _tokenId) {
        if (_exists(_tokenId)) revert TokenAlreadyExists();
        _;
    }

    // TODO: maybe we should have delegate.cash here? most high-profile tokens are held in vaults right?
    modifier onlyTokenOwner(uint256 _tokenId) {
        if (ownerOf(_tokenId) != msg.sender) revert OnlyCallableByTokenOwner();
        _;
    }

    // constructor

    constructor(
        address _royaltyCollector
    ) ERC721("Mitchell F. Chan, Beggars Belief", "BB") {
        _setDefaultRoyalty(_royaltyCollector, 1000); // 1,000 = 10% (out of 10,000)
    }

    // onlyOwner functions

    function mint(
        address _to,
        uint256 _tokenId,
        string memory _baseURI
    ) external onlyOwner tokenDoesNotExist(_tokenId) {
        _mint(_to, _tokenId);

        baseURIs[_tokenId] = _baseURI;
    }

    // TODO: we don't need to include this in the final contract, but it's here for reference
    function burn(uint256 _tokenId) external onlyOwner tokenExists(_tokenId) {
        _burn(_tokenId);
    }

    function setBaseURI(
        uint256 _tokenId,
        string memory _baseURI
    ) external onlyOwner tokenExists(_tokenId) {
        baseURIs[_tokenId] = _baseURI;
    }

    function setDefaultRoyalty(
        address _royaltyCollector,
        uint96 _feeNumerator
    ) external onlyOwner {
        _setDefaultRoyalty(_royaltyCollector, _feeNumerator);
    }

    function setTokenRoyalty(
        uint256 _tokenId,
        address _royaltyCollector,
        uint96 _feeNumerator
    ) external onlyOwner tokenExists(_tokenId) {
        _setTokenRoyalty(_tokenId, _royaltyCollector, _feeNumerator);
    }

    // onlyTokenOwner functions

    function setCollectorAcknowledgement(
        uint256 _tokenId,
        string memory _collectorAcknowledgement
    ) external onlyTokenOwner(_tokenId) {
        collectorAcknowledgement[_tokenId] = _collectorAcknowledgement;

        emit SetCollectorAcknowledgement(
            _tokenId,
            ownerOf(_tokenId),
            _collectorAcknowledgement
        );
    }

    function setAdditionalInformation(
        uint256 _tokenId,
        string memory _additionalInformation
    ) external onlyTokenOwner(_tokenId) {
        additionalInformation[_tokenId] = _additionalInformation;

        emit SetAdditionalInformation(
            _tokenId,
            ownerOf(_tokenId),
            _additionalInformation
        );
    }

    // public functions

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override tokenExists(_tokenId) returns (string memory) {
        return baseURIs[_tokenId];
    }

    function getCollectorAcknowledgement(
        uint256 _tokenId
    ) public view tokenExists(_tokenId) returns (string memory) {
        return collectorAcknowledgement[_tokenId];
    }

    function getAdditionalInformation(
        uint256 _tokenId
    ) public view tokenExists(_tokenId) returns (string memory) {
        return additionalInformation[_tokenId];
    }
}
