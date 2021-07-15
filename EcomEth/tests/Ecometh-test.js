const { assert } = require("chai");

const Ecometh = artifacts.require("./Ecometh.sol");

contract('Ecometh', (accounts) => {
    let ecometh;

    before( async () => {
        const ecometh = await Ecometh.deployed();
    });

    describe('Test Deployment', async () => {
        // test case to check the successful deployement
        it('Check for successful deployment', async () => {
            const address = await ecometh.address;
            assert.notEqual(address, 0x0, "Invalid address");
            assert.notEqual(address, '', "Invalid address");
            assert.notEqual(address, null, "Invalid address");
            assert.notEqual(address, undefined, "Invalid address");
        });

        // test case to check for success of deployment
        it('Check for success of deployment', async () => {
            const name = await ecometh.name();
            assert.equal(name, "Ganesh's Ecom", "Successfully deployed");
        });
    });
});