// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {LibTierConstants} from "./LibTierConstants.sol";

/// @title LibTierReport
/// @notice `LibTierReport` implements several pure functions that can be
/// used to interface with reports.
/// - `tierAtTimeFromReport`: Returns the highest status achieved relative to
/// a block timestamp and report. Statuses gained after that block are ignored.
/// - `tierTime`: Returns the timestamp that a given tier has been held
/// since according to a report.
/// - `truncateTiersAbove`: Resets all the tiers above the reference tier.
/// - `updateTimesForTierRange`: Updates a report with a timestamp for every
///    tier in a range.
/// - `updateReportWithTierAtTime`: Updates a report to a new tier.
/// @dev Utilities to consistently read, write and manipulate tiers in reports.
/// The low-level bit shifting can be difficult to get right so this
/// factors that out.
library LibTierReport {
    /// Enforce upper limit on tiers so we can do unchecked math.
    /// @param tier The tier to enforce bounds on.
    modifier maxTier(uint256 tier) {
        require(tier <= LibTierConstants.MAX_TIER, "MAX_TIER");
        _;
    }

    /// Returns the highest tier achieved relative to a block timestamp
    /// and report.
    ///
    /// Note that typically the report will be from the _current_ contract
    /// state, i.e. `block.timestamp` but not always. Tiers gained after the
    /// reference time are ignored.
    ///
    /// When the `report` comes from a later block than the `timestamp` this
    /// means the user must have held the tier continuously from `timestamp`
    /// _through_ to the report time.
    /// I.e. NOT a snapshot.
    ///
    /// @param report A report as per `ITierV2`.
    /// @param timestamp The timestamp to check the tiers against.
    /// @return tier The highest tier held since `timestamp` as per `report`.
    function tierAtTimeFromReport(uint256 report, uint256 timestamp) internal pure returns (uint256 tier) {
        unchecked {
            for (tier = 0; tier < 8; tier++) {
                if (uint32(uint256(report >> (tier * 32))) > timestamp) {
                    break;
                }
            }
        }
    }

    /// Returns the timestamp that a given tier has been held since from a
    /// report.
    ///
    /// The report MUST encode "never" as 0xFFFFFFFF. This ensures
    /// compatibility with `tierAtTimeFromReport`.
    ///
    /// @param report_ The report to read a timestamp from.
    /// @param tier The Tier to read the timestamp for.
    /// @return The timestamp the tier has been held since.
    function reportTimeForTier(uint256 report_, uint256 tier) internal pure maxTier(tier) returns (uint256) {
        unchecked {
            // ZERO is a special case. Everyone has always been at least ZERO,
            // since block 0.
            if (tier == 0) {
                return 0;
            }

            uint256 offset_ = (tier - 1) * 32;
            return uint256(uint32(uint256(report_ >> offset_)));
        }
    }

    /// Resets all the tiers above the reference tier to 0xFFFFFFFF.
    ///
    /// @param report_ Report to truncate with high bit 1s.
    /// @param tier Tier to truncate above (exclusive).
    /// @return Truncated report.
    function truncateTiersAbove(uint256 report_, uint256 tier) internal pure maxTier(tier) returns (uint256) {
        unchecked {
            uint256 offset_ = tier * 32;
            uint256 mask_ = (LibTierConstants.NEVER_REPORT >> offset_) << offset_;
            return report_ | mask_;
        }
    }

    /// Updates a report with a timestamp for a given tier.
    /// More gas efficient than `updateTimesForTierRange` if only a single
    /// tier is being modified.
    /// The tier at/above the given tier is updated. E.g. tier `0` will update
    /// the time for tier `1`.
    /// @param report_ Report to use as the baseline for the updated report.
    /// @param tier The tier level to update.
    /// @param timestamp The new block number for `tier`.
    /// @return The newly updated `report_`.
    function updateTimeAtTier(uint256 report_, uint256 tier, uint256 timestamp)
        internal
        pure
        maxTier(tier)
        returns (uint256)
    {
        unchecked {
            uint256 offset_ = tier * 32;
            return (report_ & ~uint256(uint256(LibTierConstants.NEVER_TIME) << offset_)) | uint256(timestamp << offset_);
        }
    }

    /// Updates a report with a block number for every tier in a range.
    ///
    /// Does nothing if the end status is equal or less than the start tier.
    /// @param report_ The report to update.
    /// @param startTier The tier at the start of the range (exclusive).
    /// @param endTier The tier at the end of the range (inclusive).
    /// @param timestamp The timestamp to set for every tier in the range.
    /// @return The updated report.
    function updateTimesForTierRange(uint256 report_, uint256 startTier, uint256 endTier, uint256 timestamp)
        internal
        pure
        maxTier(endTier)
        returns (uint256)
    {
        unchecked {
            uint256 offset_;
            for (uint256 i_ = startTier; i_ < endTier; i_++) {
                offset_ = i_ * 32;
                report_ = (report_ & ~uint256(uint256(LibTierConstants.NEVER_TIME) << offset_))
                    | uint256(timestamp << offset_);
            }
            return report_;
        }
    }

    /// Updates a report to a new status.
    ///
    /// Internally dispatches to `truncateTiersAbove` and
    /// `updateBlocksForTierRange`.
    /// The dispatch is based on whether the new tier is above or below the
    /// current tier.
    /// The `startTier` MUST match the result of `tierAtBlockFromReport`.
    /// It is expected the caller will know the current tier when
    /// calling this function and need to do other things in the calling scope
    /// with it.
    ///
    /// @param report_ The report to update.
    /// @param startTier The tier to start updating relative to. Data above
    /// this tier WILL BE LOST so probably should be the current tier.
    /// @param endTier The new highest tier held, at the given timestamp.
    /// @param timestamp The timestamp to update the highest tier to, and
    /// intermediate tiers from `startTier`.
    /// @return The updated report.
    function updateReportWithTierAtTime(uint256 report_, uint256 startTier, uint256 endTier, uint256 timestamp)
        internal
        pure
        returns (uint256)
    {
        return endTier < startTier
            ? truncateTiersAbove(report_, endTier)
            : updateTimesForTierRange(report_, startTier, endTier, timestamp);
    }
}
