// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {IERC165Upgradeable as IERC165} from
    "openzeppelin-contracts-upgradeable/contracts/utils/introspection/IERC165Upgradeable.sol";
import {ITierV2, TierV2} from "src/abstract/TierV2.sol";
// import {
//     RainterpreterExpressionDeployerNPE2,
//     RainterpreterExpressionDeployerNPE2ConstructionConfigV2
// } from "src/concrete/RainterpreterExpressionDeployerNPE2.sol";
// import {IParserPragmaV1} from "rain.interpreter.interface/interface/unstable/IParserPragmaV1.sol";
// import {IParserV2} from "rain.interpreter.interface/interface/unstable/IParserV2.sol";
// import {IExpressionDeployerV4} from "rain.interpreter.interface/interface/unstable/IExpressionDeployerV4.sol";
// import {IDescribedByMetaV1} from "rain.metadata/interface/unstable/IDescribedByMetaV1.sol";
// import {RainterpreterNPE2} from "src/concrete/RainterpreterNPE2.sol";
// import {RainterpreterParserNPE2} from "src/concrete/RainterpreterParserNPE2.sol";
// import {RainterpreterStoreNPE2} from "src/concrete/RainterpreterStoreNPE2.sol";

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
