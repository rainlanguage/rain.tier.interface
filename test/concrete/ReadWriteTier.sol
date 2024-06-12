// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {TierV2} from "src/abstract/TierV2.sol";
import {LibTierConstants} from "src/lib/LibTierConstants.sol";
import {LibTierReport} from "src/lib/LibTierReport.sol";

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
        return reports[account] > 0 ? reports[account] : TierConstants.NEVER_REPORT;
    }

    /// @inheritdoc ITierV2
    function reportTimeForTier(address account, uint256 tier, uint256[] memory) external view returns (uint256) {
        return TierReport.reportTimeForTier(report(account, new uint256[](0)), tier);
    }

    /// Errors if the user attempts to return to the ZERO tier.
    /// Updates the report from `report` using default `TierReport` logic.
    /// Emits `TierChange` event.
    function setTier(address account, uint256 endTier) external {
        // The user must move to at least tier 1.
        // The tier 0 status is reserved for users that have never
        // interacted with the contract.
        require(endTier > 0, "SET_ZERO_TIER");

        uint256 report = report(account, new uint256[](0));

        uint256 startTier = TierReport.tierAtTimeFromReport(report, block.timestamp);

        reports[account] = TierReport.updateReportWithTierAtTime(report, startTier, endTier, block.timestamp);

        emit TierChange(msg.sender, account, startTier, endTier);
    }

    /// Re-export TierReport utilities

    function tierAtTimeFromReport(uint256 report, uint256 timestamp) external pure returns (uint256 tier_) {
        return TierReport.tierAtTimeFromReport(report, timestamp);
    }

    function reportTimeForTier(uint256 report, uint256 tier) external pure returns (uint256 timestamp_) {
        return TierReport.reportTimeForTier(report, tier);
    }

    function truncateTiersAbove(uint256 report, uint256 tier) external pure returns (uint256) {
        return TierReport.truncateTiersAbove(report, tier);
    }

    function updateTimeAtTier(uint256 report, uint256 tier, uint256 timestamp)
        external
        pure
        returns (uint256 updatedReport)
    {
        return TierReport.updateTimeAtTier(report, tier, timestamp);
    }

    function updateTimesForTierRange(uint256 report, uint256 startTier, uint256 endTier, uint256 timestamp)
        external
        pure
        returns (uint256 updatedReport)
    {
        return TierReport.updateTimesForTierRange(report, startTier, endTier, timestamp);
    }

    function updateReportWithTierAtTime(uint256 report_, uint256 startTier_, uint256 endTier_, uint256 timestamp_)
        external
        pure
        returns (uint256 updatedReport)
    {
        return TierReport.updateReportWithTierAtTime(report_, startTier_, endTier_, timestamp_);
    }
}
