const Marketplace = artifacts.require('./marketplace.sol');

require('chai')
    .use(require('chai-as-promised'))
    .should()

contract('Marketplace', ([deployer, seller, buyer]) => {
    let marketplace
    
    before(async () => {
        marketplace = await Marketplace.deployed();
    });

    describe('deployment', async () =>{

        // test case to check if the contract is deployed successfully
        it('check for successful deployment', async () =>{
            const address = await marketplace.address
            assert.notEqual(address, 0x0, "Invalid address");
            assert.notEqual(address, '', "Empty address");
            assert.notEqual(address, null, "Null address");
            assert.notEqual(address, undefined, "Undefined address");
        });

        // test case to check if the deployed contract has a valid name
        it('check for a valid name', async () =>{
            const name = await marketplace.name()
            assert.equal(name, "Ganesh's marketplace", "Valid Name");
        });
    });

    describe('products', async () => {
        let result, productcount

        before(async () => {
            result = await marketplace.addProduct('Xbox one', web3.utils.toWei('1','Ether'), {from: seller});
            productcount = await marketplace.productsCount(); 
        });

        // test case to check if the product is added on addition
        it('Check for successful product addition', async () =>{
            //Success
            assert.equal(productcount, 1, "correct product count");
            const event = result.logs[0].args;
            assert.equal(event.id.toNumber(), productcount.toNumber(), "Valid Id");
            assert.equal(event.name, 'Xbox one', "Valid Name");
            assert.equal(event.price, 1000000000000000000, "Valid Price");
            assert.equal(event.owner, seller, "Valid Owner");
            assert.equal(event.purchased, false, 'Valid Purchase');

            //Failure : Product must have a valid name
            await await marketplace.addProduct('', web3.utils.toWei('1', 'Ether'), {from: seller}).should.be.rejected;
            
            //Failure : Product must have a valid price
            await await marketplace.addProduct('Xbox one','0',{from: seller}).should.be.rejected;
        });

        // test case to check if the products are listed after addition
        it('Check for products added to the network', async () =>{
            const product = await marketplace.products(productcount);
            assert.equal(product.id.toNumber(), productcount.toNumber(), "Valid Id");
            assert.equal(product.name, 'Xbox one', "Valid Name");
            assert.equal(product.price, 1000000000000000000, "Valid Price");
            assert.equal(product.owner, seller, "Valid Owner");
            assert.equal(product.purchased, false, 'Valid Purchase');
        });
    });
});
