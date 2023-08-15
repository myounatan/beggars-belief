import { loadFixture, time } from '@nomicfoundation/hardhat-network-helpers';
import hre, {ethers, network, upgrades } from 'hardhat';

import { expect } from 'chai';
import { ContractFactory } from 'ethers';


describe('Beggars Belief upgradability test', function () {
  it('creates a proxy and implementation V1', async () => {
    const [owner, admin, account3] = await ethers.getSigners();
    const ownerAddress = await owner.getAddress();
    const adminAddress = await admin.getAddress();
    const account3Address = await account3.getAddress();

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

    // mint token id 0 and check data

    await contract.mint(adminAddress, 0, 'https://token_1_uri');

    expect(await contract.ownerOf(0)).to.equal(adminAddress);
    expect(await contract.tokenURI(0)).to.equal('https://token_1_uri');

    // mint out of order token id 69

    await contract.mint(account3Address, 69, 'https://token_69_uri');

    expect(await contract.ownerOf(69)).to.equal(account3Address);
    expect(await contract.tokenURI(69)).to.equal('https://token_69_uri');
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

    // mint token id 0

    await upgradedContract.mint(adminAddress, 0, 'https://token_1_uri');

    expect(await upgradedContract.ownerOf(0)).to.equal(adminAddress);
    expect(await upgradedContract.tokenURI(0)).to.equal('https://token_1_uri');

    // burn token id 0

    await upgradedContract.burn(0);

    expect(await upgradedContract.balanceOf(adminAddress)).to.equal(0);
  });
});