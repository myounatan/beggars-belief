// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/common/ERC2981Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

/**
 * @title BeggarsBelief
 * @author Created by Mitchell F Chan @mitchellfchan
 * @author Written by Matthew Younatan @matyounatan
 * @notice Allows for out-of-order token minting and collector acknlowdgement. No upper limit.
 */
contract BeggarsBeliefV2 is
    OwnableUpgradeable,
    ERC2981Upgradeable,
    ERC721Upgradeable
{
    // variables

    struct State {
        address admin; // developer address, or address(0) for onlyOwner access
        /// @notice The URI of the token.
        mapping(uint256 => string) tokenURIs;
        /// @notice The collector's acknowledgement of the token.
        mapping(uint256 => string) collectorAcknowledgement;
        /// @notice Additional information about the token.
        mapping(uint256 => string) additionalInformation;
    }

    /// @notice The state of the contract.
    State private state;

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

    /// @notice Emitted when calling a function the requires the caller to be the owner or admin.
    error OnlyOwnerOrAdmin();

    /// @notice Emitted when calling a function the requires the caller to be the owner.
    error OnlyOwner();

    /// @notice Emitted when calling a function the requires the token to exist.
    error TokenDoesNotExist();

    /// @notice Emitted when calling a function the requires the token to not exist.
    error TokenAlreadyExists();

    /// @notice Emitted when calling a function the requires the caller to be the token owner.
    error OnlyTokenOwner();

    // modifiers

    modifier onlyOwnerOrAdmin() {
        if (state.admin != address(0)) {
            if (_msgSender() != owner() && _msgSender() != state.admin)
                revert OnlyOwnerOrAdmin();
        } else {
            if (_msgSender() != owner()) revert OnlyOwner();
        }
        _;
    }

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
        if (ownerOf(_tokenId) != msg.sender) revert OnlyTokenOwner();
        _;
    }

    // initializer

    function initialize(
        address _royaltyCollector,
        address _admin
    ) public onlyOwnerOrAdmin initializer {
        __Ownable_init_unchained();
        __ERC2981_init_unchained();
        __ERC721_init_unchained("Mitchell F. Chan, Beggars Belief", "BB");

        _setDefaultRoyalty(_royaltyCollector, 750); // 750 (out of 10,000) = 7.5%

        state.admin = _admin;
    }

    // onlyOwner functions

    function setAdmin(address _admin) external onlyOwner {
        state.admin = _admin;
    }

    function revokeAdmin() external onlyOwnerOrAdmin {
        state.admin = address(0);
    }

    function mint(
        address _to,
        uint256 _tokenId,
        string memory _tokenURI
    ) external onlyOwner tokenDoesNotExist(_tokenId) {
        _mint(_to, _tokenId);

        state.tokenURIs[_tokenId] = _tokenURI;
    }

    // function burn(uint256 _tokenId) external onlyOwner tokenExists(_tokenId) {
    //   _burn(_tokenId);
    // }

    function setTokenURI(
        uint256 _tokenId,
        string memory _tokenURI
    ) external onlyOwner tokenExists(_tokenId) {
        state.tokenURIs[_tokenId] = _tokenURI;
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
        state.collectorAcknowledgement[_tokenId] = _collectorAcknowledgement;

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
        state.additionalInformation[_tokenId] = _additionalInformation;

        emit SetAdditionalInformation(
            _tokenId,
            ownerOf(_tokenId),
            _additionalInformation
        );
    }

    // public functions

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721Upgradeable, ERC2981Upgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function getAdmin() public view returns (address) {
        return state.admin;
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override tokenExists(_tokenId) returns (string memory) {
        return state.tokenURIs[_tokenId];
    }

    function getCollectorAcknowledgement(
        uint256 _tokenId
    ) public view tokenExists(_tokenId) returns (string memory) {
        return state.collectorAcknowledgement[_tokenId];
    }

    function getAdditionalInformation(
        uint256 _tokenId
    ) public view tokenExists(_tokenId) returns (string memory) {
        return state.additionalInformation[_tokenId];
    }

    ////////////////////////
    // V2
    ////////////////////////

    struct NewState {
        mapping(uint256 => string) someMapping;
    }

    NewState private newState;

    function initializeV2() public onlyOwnerOrAdmin reinitializer(2) {
        NewState storage _newState = newState;
        _newState.someMapping[0] = "hello";
    }

    function getSomeMapping(
        uint256 _tokenId
    ) public view returns (string memory) {
        return newState.someMapping[_tokenId];
    }

    function burn(uint256 _tokenId) external onlyOwner tokenExists(_tokenId) {
        _burn(_tokenId);
    }
}
