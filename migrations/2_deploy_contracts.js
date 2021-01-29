const HodlFarm = artifacts.require("HodlFarm")
const HodlToken = artifacts.require("HodlToken")

//
//use correct dai address with corresponding network
//
//kovan dai address below
https://kovan.etherscan.io/token/0x4f96fe3b7a6cf9725f59d353f723c1bdb64ca6aa
//

daiAddress = "0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa";

module.exports = async (deployer, network, accounts) => {
  //Deploy Hodl Token
  await deployer.deploy(HodlToken, "21000000000000000000000000")
  const hodlToken = await HodlToken.deployed()

  //Deploy a single contract with constructor arguments
  await deployer.deploy(HodlFarm, hodlToken.address, daiAddress)
  const hodlFarm = await HodlFarm.deployed()

  //transfer hodlToken to hodlFarm
  await hodlToken.transfer(hodlFarm.address, "21000000000000000000000000")
};
