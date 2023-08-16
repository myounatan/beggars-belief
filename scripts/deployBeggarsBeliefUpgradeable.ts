import { ethers, upgrades, run } from "hardhat";

async function main() {
  const [owner] = await ethers.getSigners();
  const ownerAddress = await owner.getAddress();

  const v1Path = 'contracts/BeggarsBelief.sol:BeggarsBelief';

  const BeggarsBeliefV1: any = await ethers.getContractFactory(v1Path);

  const instance = await upgrades.deployProxy(BeggarsBeliefV1, { initializer: 'initialize', kind: 'transparent' });
  const contract = await instance.waitForDeployment();

  const implementationAddress = await upgrades.erc1967.getImplementationAddress(await contract.getAddress());

  // verify implementation
  await run('verify:verify', { address: implementationAddress, contract: v1Path, constructorArguments: [] });

  // set default royalty
  await contract.setDefaultRoyalty(owner, 750);

  console.log('\n\nDEPLOY PROXY SUCCESS!!')
  console.log('Proxy address: ', await contract.getAddress());
  console.log('Implementation address: ', implementationAddress, '\n\n');

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
