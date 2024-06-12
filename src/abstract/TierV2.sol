// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {ERC165Upgradeable as ERC165} from
    "openzeppelin-contracts-upgradeable/contracts/utils/introspection/ERC165Upgradeable.sol";
import {ITierV2} from "../interface/ITierV2.sol";

abstract contract TierV2 is ITierV2, ERC165 {
    /// Initializer for TierV2 simply initializes the inherited ERC165.
    function tierV2Init() internal onlyInitializing {
        __ERC165_init();
    }

    // @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(ITierV2).interfaceId || super.supportsInterface(interfaceId);
    }
}
