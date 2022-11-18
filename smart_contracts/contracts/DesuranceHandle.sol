// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./Desurance.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

// import "@tableland/evm/contracts/ITablelandTables.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";
// import "@tableland/evm/contracts/utils/TablelandDeployments.sol";

contract DesuranceHandle is AutomationCompatibleInterface, VRFConsumerBaseV2 {
    struct ContractInfo {
        address contractAddress;
        uint256 judgingStartTime;
        uint256 judgingEndTime;
    }

    // ITablelandTables private _tableland;
    // uint256 private _tableId;
    // string private _tableName;
    // string private _prefix = "desurance";

    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    mapping(uint256 => address) private s_requestIdToContractAddress;

    // address[] private s_insuranceContracts;
    ContractInfo[] private s_contractInfos;

    constructor(
        address vrfCoordinatorV2,
        uint64 subscriptionId,
        bytes32 gasLane, // keyH
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;

        // _tableland = TablelandDeployments.get();
        // _tableId = _tableland.createTable(
        //     address(this),
        //     /*
        //      *  CREATE TABLE {prefix}_{chainId} (
        //      *    id integer primary key,
        //      *    message text
        //      *  );
        //      */
        //     string.concat(
        //         "CREATE TABLE ",
        //         _prefix,
        //         "_",
        //         Strings.toString(block.chainid),
        //         " (id integer primary key, insuranceAddress text NOT NULL, baseUri text NOT NULL, minMembers integer NOT NULL, requestTime integer NOT NULL, validity integer NOT NULL, claimTime integer NOT NULL, judgingTime integer NOT NULL, judgesLength integer NOT NULL, amount integer NOT NULL, percentDivideIntoJudges integer NOT NULL);"
        //     )
        // );

        // _tableName = string.concat(
        //     _prefix,
        //     "_",
        //     Strings.toString(block.chainid),
        //     "_",
        //     Strings.toString(_tableId)
        // );
    }

    function createInsurance(
        string memory baseUri,
        uint256 minMembers,
        uint256 requestTime, // (in seconds) time before one can make a request
        uint256 validity, // (in seconds) insurance valid after startBefore seconds and user can claim insurance after validity
        uint256 claimTime, // (in seconds) time before use can make a insurance claim request, after this time judging will start.
        uint256 judgingTime, // (in seconds) time before judges should judge insurance claim requests.
        uint256 judgesLength, // number of judges
        uint256 amount, // amount everyone should put in the pool
        uint256 percentDivideIntoJudges, // percent of total pool amount that should be divided into judges (total pool amount = amount * members.length where members.length == s_memberNumber - 1) (only valid for judges who had judged every claim request)
        string memory groupId
    ) public payable returns (address) {
        Desurance newInsurance = new Desurance(
            baseUri,
            minMembers,
            requestTime,
            validity,
            claimTime,
            judgingTime,
            judgesLength,
            amount,
            percentDivideIntoJudges,
            groupId
        );

        uint256 judgingStartTime = block.timestamp + requestTime + validity + claimTime;

        // s_insuranceContracts.push(address(newInsurance));
        uint256 judgingEndTime = judgingStartTime + judgingTime;

        s_contractInfos.push(ContractInfo(address(newInsurance), judgingStartTime, judgingEndTime));

        // _tableland.runSQL(
        //     address(this),
        //     _tableId,
        //     string.concat(
        //         "INSERT INTO ",
        //         _tableName,
        //         " (insuranceAddress, baseUri, minMembers, requestTime, validity, claimTime, judgingTime, judgesLength, amount, percentDivideIntoJudges) VALUES (",
        //         "'",
        //         _addressToString(address(newInsurance)),
        //         "','",
        //         baseUri,
        //         "','",
        //         Strings.toString(minMembers),
        //         "','",
        //         Strings.toString(requestTime),
        //         "','",
        //         Strings.toString(validity),
        //         "','",
        //         Strings.toString(claimTime),
        //         "','",
        //         Strings.toString(judgingTime),
        //         "','",
        //         Strings.toString(judgesLength),
        //         "','",
        //         Strings.toString(amount),
        //         "','",
        //         Strings.toString(percentDivideIntoJudges),
        //         "');"
        //     )
        // );

        return address(newInsurance);
    }

    // Assumes the subscription is funded sufficiently.
    function getRandomNumbers(address contractAddress) public payable returns (uint256 requestId) {
        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        s_requestIdToContractAddress[requestId] = contractAddress;
    }

    function performUpkeep(bytes calldata performData) external override {
        (uint256 index, uint256 which) = abi.decode(performData, (uint256, uint256));
        address contractAddress = s_contractInfos[index].contractAddress;
        if (which == 0) {
            s_contractInfos[index].judgingStartTime = 0;
            getRandomNumbers(contractAddress);
            return;
        }
        s_contractInfos[index].judgingEndTime = 0;
        Desurance(contractAddress).fullfillRequests();
    }

    /**
     * @dev This is the function that Chainlink VRF node
     * calls.
     */
    function fulfillRandomWords(
        uint256 requestId, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        Desurance desurance = Desurance(s_requestIdToContractAddress[requestId]);
        desurance.selectJudges(randomWords[0]);
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    ) external view override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = false;
        for (uint256 i = 0; i < s_contractInfos.length; i++) {
            if (
                s_contractInfos[i].judgingStartTime != 0 &&
                s_contractInfos[i].judgingStartTime < block.timestamp &&
                s_contractInfos[i].judgingEndTime > block.timestamp
            ) {
                upkeepNeeded = true;
                performData = abi.encode(i, 0); // index, which (0 = getRandomNumbers for selecting judges, 1 = fullfillRequests for fullfilling insurance claim requests)
                break;
            }
            if (
                s_contractInfos[i].judgingEndTime != 0 &&
                s_contractInfos[i].judgingEndTime < block.timestamp
            ) {
                upkeepNeeded = true;
                performData = abi.encode(i, 1);
                break;
            }
        }
    }

    function _addressToString(address x) public pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint256(uint160(x)) / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string.concat("0x", string(s));
    }

    function char(bytes1 b) public pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function getContracts() public view returns (ContractInfo[] memory) {
        return s_contractInfos;
    }

    function getContract(uint256 index) public view returns (ContractInfo memory) {
        return s_contractInfos[index];
    }

    function getContractsLength() public view returns (uint256) {
        return s_contractInfos.length;
    }
}
