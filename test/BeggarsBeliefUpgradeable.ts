import { loadFixture, time } from '@nomicfoundation/hardhat-network-helpers';
import hre, {ethers, network, upgrades } from 'hardhat';

import { expect } from 'chai';
import { ContractFactory } from 'ethers';


describe('Beggars Belief upgradability test', function () {
  it('creates a proxy and implementation V1', async () => {
    const [owner, admin] = await ethers.getSigners();
    const ownerAddress = await owner.getAddress();
    const adminAddress = await admin.getAddress();

    const BeggarsBeliefV1: any = await hre.ethers.getContractFactory('BeggarsBeliefV1');

    const instance = await upgrades.deployProxy(BeggarsBeliefV1, [ownerAddress, adminAddress]);
    const contract = await instance.waitForDeployment();

    // instance.initialize();

    expect(await contract.owner()).to.equal(ownerAddress);
    expect(await contract.getAdmin()).to.equal(adminAddress);

    // log proxy and implementation addresses
    const proxyAddress = await contract.getAddress();
    console.log('Proxy address: ', proxyAddress);
    console.log('Implementation address: ', await upgrades.erc1967.getImplementationAddress(proxyAddress));

  });

  it('creates and upgrades to V2', async () => {
    const [owner, admin] = await ethers.getSigners();
    const ownerAddress = await owner.getAddress();
    const adminAddress = await admin.getAddress();

    const BeggarsBeliefV1: any = await hre.ethers.getContractFactory('BeggarsBeliefV1');

    const instance = await upgrades.deployProxy(BeggarsBeliefV1, [ownerAddress, adminAddress]);
    const contract = await instance.waitForDeployment();

    // await contract.initialize(ownerAddress, adminAddress);

    expect(await contract.owner()).to.equal(ownerAddress);
    expect(await contract.getAdmin()).to.equal(adminAddress);

    // log proxy and implementation addresses
    const proxyAddress = await contract.getAddress();
    console.log('Proxy address: ', proxyAddress);
    console.log('Implementation address: ', await upgrades.erc1967.getImplementationAddress(proxyAddress));

    // upgrade to V2

    const BeggarsBeliefV2: any = await hre.ethers.getContractFactory('BeggarsBeliefV2');

    const upgraded = await upgrades.upgradeProxy(proxyAddress, BeggarsBeliefV2);
    const upgradedContract = await upgraded.waitForDeployment();

    await upgradedContract.initializeV2();

    expect(await upgradedContract.getSomeMapping(0)).to.equal('hello');

    console.log('Upgraded implementation address: ', await upgrades.erc1967.getImplementationAddress(proxyAddress));
  });
});