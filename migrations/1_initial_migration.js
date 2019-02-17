var Migrations = artifacts.require("./Migrations.sol");
var NuVault = artifacts.require("./NuVault.sol");

module.exports = async function(deployer) {
  deployer.deploy(Migrations);
  await deployer.deploy(NuVault);
};
