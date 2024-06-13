// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {ITierV2, TierV2} from "../../src/abstract/TierV2.sol";
import {LibTierConstants} from "../../src/lib/LibTierConstants.sol";
import {LibTierReport} from "../../src/lib/LibTierReport.sol";

/// @title ReadWriteTier
///
/// Very simple TierV2 implementation for testing.
contract ReadWriteTier is TierV2 {
    /// Every time a tier changes we log start and end tier against the
    /// account.
    /// This MAY NOT be emitted if reports are being read from the state of an
    /// external contract.
    /// The start tier MAY be lower than the current tier as at the block this
    /// event is emitted in.
    /// @param sender The `msg.sender` that authorized the tier change.
    /// @param account The account changing tier.
    /// @param startTier The previous tier the account held.
    /// @param endTier The newly acquired tier the account now holds.
    event TierChange(address sender, address account, uint256 startTier, uint256 endTier);

    /// account => reports
    mapping(address => uint256) private sReports;

    constructor() {
        _disableInitializers();
    }

    /// Either fetch the report from storage or return UNINITIALIZED.
    /// @inheritdoc ITierV2
    function report(address account, uint256[] memory) public view virtual override returns (uint256) {
        // Inequality here to silence slither warnings.
        return sReports[account] > 0 ? sReports[account] : LibTierConstants.NEVER_REPORT;
    }

    /// @inheritdoc ITierV2
    function reportTimeForTier(address account, uint256 tier, uint256[] memory) external view returns (uint256) {
        return LibTierReport.reportTimeForTier(report(account, new uint256[](0)), tier);
    }

    /// Errors if the user attempts to return to the ZERO tier.
    /// Updates the report from `report` using default `TierReport` logic.
    /// Emits `TierChange` event.
    function setTier(address account, uint256 endTier) external {
        // The user must move to at least tier 1.
        // The tier 0 status is reserved for users that have never
        // interacted with the contract.
        require(endTier > 0, "SET_ZERO_TIER");

        uint256 oldReport = report(account, new uint256[](0));

        uint256 startTier = LibTierReport.tierAtTimeFromReport(oldReport, block.timestamp);

        sReports[account] = LibTierReport.updateReportWithTierAtTime(oldReport, startTier, endTier, block.timestamp);

        emit TierChange(msg.sender, account, startTier, endTier);
    }

    /// Re-export TierReport utilities

    function tierAtTimeFromReport(uint256 inputReport, uint256 timestamp) external pure returns (uint256) {
        return LibTierReport.tierAtTimeFromReport(inputReport, timestamp);
    }

    function reportTimeForTier(uint256 inputReport, uint256 tier) external pure returns (uint256) {
        return LibTierReport.reportTimeForTier(inputReport, tier);
    }

    function truncateTiersAbove(uint256 inputReport, uint256 tier) external pure returns (uint256) {
        return LibTierReport.truncateTiersAbove(inputReport, tier);
    }

    function updateTimeAtTier(uint256 inputReport, uint256 tier, uint256 timestamp) external pure returns (uint256) {
        return LibTierReport.updateTimeAtTier(inputReport, tier, timestamp);
    }

    function updateTimesForTierRange(uint256 inputReport, uint256 startTier, uint256 endTier, uint256 timestamp)
        external
        pure
        returns (uint256)
    {
        return LibTierReport.updateTimesForTierRange(inputReport, startTier, endTier, timestamp);
    }

    function updateReportWithTierAtTime(uint256 inputReport, uint256 startTier, uint256 endTier, uint256 timestamp)
        external
        pure
        returns (uint256)
    {
        return LibTierReport.updateReportWithTierAtTime(inputReport, startTier, endTier, timestamp);
    }
}
