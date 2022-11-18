const desuranceHandleAbi = require("./DesuranceHandle.abi.json")
const desuranceAbi = require("./Desurance.abi.json")
const contractAddress = require("./contractAddress.json")
const desuranceContractAddress = contractAddress.desuranceHandle
const currency = "MATIC"
module.exports = {
    desuranceHandleAbi,
    desuranceAbi,
    desuranceContractAddress,
    currency,
}
