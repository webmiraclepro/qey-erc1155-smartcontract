const whitelist = require("../whitelist");

const Web3 = require("web3");
const { assert } = require("chai");
const Qey = artifacts.require('./Qey.sol')

// require('chai')
//   .use(require('chai-as-promised'))
//   .should()

contract('Qey', (accounts) => {
  let contract

  before(async () => {
    contract = await Qey.deployed(whitelist)
  })

  describe('deployment', async () => {
    it('deploys successfully', async () => {
      const address = contract.address
      assert.notEqual(address, 0x0)
      assert.notEqual(address, '')
      assert.notEqual(address, null)
      assert.notEqual(address, undefined)
    })

  })

  describe('minting', async () => {
    it('creates a new NFT token', async () => {
      const result = await contract.mint('ECEA058EF4523', 'uri0')
      const totalSupply = await contract.balanceOf(accounts[0], 0)
      // is only one NFT of this type created in this account
      assert.equal(totalSupply, 1)
      // check NFT id, from address, to address
      const event = result.logs[0].args
      assert.equal(event.id, 0, 'id is correct')
      assert.equal(event.from, '0x0000000000000000000000000000000000000000', 'from is correct')
      assert.equal(event.to, accounts[0], 'to is correct')
      // FAILURE: cannot mint same hash twice
      // await contract.mint('ECEA058EF4523', 'uri1').should.be.rejected

    })
  })

  describe('indexing', async () => {
    xit('lists hashes', async () => {
      // Mint 3 more NFT tokens
      await contract.mint('5386E4EABC345', 'uri1')
      await contract.mint('FFF567EAB5FFF', 'uri2')
      await contract.mint('234AEC00EFFD0', 'uri3')

      //check number of minted NFTs
      const qeyCount = await contract.getQeyCount()
      assert.equal(qeyCount, 4)


      let hash
      let result = []
      //check indexing and hashes of minted NFTs
      for (var i = 1; i <= qeyCount; i++) {
        hash = await contract.hashes(i - 1)
        result.push(hash)
      }

      let expected = ['ECEA058EF4523', '5386E4EABC345', 'FFF567EAB5FFF', '234AEC00EFFD0']
      assert.equal(result.join(','), expected.join(','))
    })
  })

  describe('URIs', async () => {
    xit('retrieves URIs', async () => {
      let result1 = await contract.uri(1)
      assert.equal(result1, 'uri1')
      let result2 = await contract.uri(2)
      assert.equal(result2, 'uri2')
    })
    xit('change URI', async () => {
      await contract.setTokenUri(1, 'test1')
      let result3 = await contract.uri(1)
      assert.equal(result3, 'test1')
    })
    //only owner of smart contract is able to change the uri of NFT
    xit('change URI onlyOwner', async () => {
      await contract.setTokenUri(2, 'test2', { from: accounts[1] }).should.be.rejected
    })
  })

  describe('transfering', async () => {
    xit('transferring NFT', async () => {
      let result = await contract.safeTransferFrom(accounts[0], accounts[2], 0, 1, "0x0")
      const event = result.logs[0].args
      assert.equal(event.to, accounts[2])
    })
  })

  //describe('selling', async () => {
  //  it('selling NFT with provision', async () => {
  //
  //    let result = await contract.safeTransferFromWithProvision(accounts[0], accounts[2], 1, 1, web3.utils.toWei('100', 'Ether'))
  //    const event = result.logs[0].args
  //    assert.equal(event.to, accounts[3])
  //  })
  //})


})
