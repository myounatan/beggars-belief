import { ethers, upgrades, run } from "hardhat";

const PROXY_ADDRESS = '0xd391216d8A8661F2d7Fe5D7B43338f8D53c40B34';

async function main() {
  const [owner] = await ethers.getSigners();
  const ownerAddress = await owner.getAddress();

  const v2Path = 'contracts/BeggarsBeliefV2.sol:BeggarsBeliefV2';

  const BeggarsBeliefV2: any = await ethers.getContractFactory(v2Path);

  const upgraded = await upgrades.upgradeProxy(PROXY_ADDRESS, BeggarsBeliefV2);
  const contract = await upgraded.waitForDeployment();

  await contract.initializeV2();

  console.log('\n\nUPGRADE SUCCESS!!')
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
