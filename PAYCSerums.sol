// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// Import $Sheesh contract
import "./ERC20Token.sol";

/// @custom:security-contact alex@bearified.xyz
contract PAYCSerums is Initializable, ERC1155Upgradeable, OwnableUpgradeable, ERC1155PausableUpgradeable, ERC1155BurnableUpgradeable, ERC1155SupplyUpgradeable, UUPSUpgradeable {
    uint256 public costPerSerum = 420000000 * (10**18);  // This represents 420,000,000 Sheesh tokens assuming 18 decimal places.
    string private _contractURI;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) initializer public {
        __ERC1155_init("ipfs://Qmc8sNMCXZoTQJ2hjBpnEb8TUSD6L9NFhPQq1BMgHtprxH/1.json");
        __Ownable_init(initialOwner);
        __ERC1155Pausable_init();
        __ERC1155Burnable_init();
        __ERC1155Supply_init();
        __UUPSUpgradeable_init();
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function updateCostPerSerum(uint256 newCostPerSerum) public onlyOwner {
        costPerSerum = newCostPerSerum;
    }

    function purchaseSerum(uint256 serumAmount) public {
        require(serumAmount > 0 && serumAmount <= 200, "Invalid serum amount");
        uint256 price = serumAmount * costPerSerum;
        AuraDropERC20 sheeshToken = AuraDropERC20(0xbB4f3aD7a2cf75d8EfFc4f6D7BD21d95F06165ca);
        require(sheeshToken.transferFrom(msg.sender, address(this), price), "Transfer failed");
        _mint(msg.sender, 1, serumAmount, "");  // Assume serum id is 1
    }

    function burnMutantsAndGetSerum(uint256[] memory mutantIds) public {
        require(mutantIds.length == 5, "Exactly 5 mutants required");
        IERC721 PAYCMutants = IERC721(0x06F832645dc8D1069727C5FA28fFEf651f4d2120);
        for (uint256 i = 0; i < mutantIds.length; i++) {
            // Ensure the caller owns the mutant they wish to burn
            require(PAYCMutants.ownerOf(mutantIds[i]) == msg.sender, "Caller does not own this mutant");
            // Transfer the mutant to the burn address
            PAYCMutants.safeTransferFrom(msg.sender, address(0x000000000000000000000000000000000000dEaD), mutantIds[i]);
        }
        _mint(msg.sender, 1, 1, "");  // Assume serum id is 1
    }

    function withdrawTokens(address to, uint256 amount) public onlyOwner {
        AuraDropERC20 sheeshToken = AuraDropERC20(0x64C061c5BcA63f017Cd6bA3B26101965b6b0c0aC);
        require(sheeshToken.transfer(to, amount), "Transfer failed");
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function setContractURI(string memory newContractURI) public onlyOwner {
        _contractURI = newContractURI;
    }

    function contractURI() external view returns (string memory) {
        return _contractURI;
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155Upgradeable, ERC1155PausableUpgradeable, ERC1155SupplyUpgradeable)
    {
        super._update(from, to, ids, values);
    }
}
