// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {IERC165Upgradeable as IERC165} from
    "openzeppelin-contracts-upgradeable/contracts/utils/introspection/IERC165Upgradeable.sol";
import {ITierV2, TierV2} from "src/abstract/TierV2.sol";

contract TestTierV2 is TierV2 {
    function report(address, uint256[] memory) public view virtual override returns (uint256) {
        return 0;
    }

    function reportTimeForTier(address, uint256, uint256[] memory) external pure returns (uint256) {
        return 0;
    }
}

contract RainterpreterExpressionDeployerNPE2IERC165Test is Test {
    /// Test that ERC165 is implemented for all interfaces.
    function testTierV22IERC165(bytes4 badInterfaceId) external {
        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(ITierV2).interfaceId);

        TestTierV2 tier = new TestTierV2();
        assertTrue(tier.supportsInterface(type(IERC165).interfaceId));
        assertTrue(tier.supportsInterface(type(ITierV2).interfaceId));
        assertFalse(tier.supportsInterface(badInterfaceId));
    }
}
