const { assert } = require('chai');

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
            assert.equal(event.purchased, false, 'Valid Purchase status');

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
            assert.equal(product.purchased, false, 'Valid Purchase status');
        });

        // test case to check if product acn be sold
        it('Check for selling the products on marketplace', async () => {
            // track seller balance before purchase
            let _sellerBalance = await web3.eth.getBalance(seller);
            _sellerBalance = new web3.utils.BN(_sellerBalance);

            // Success
            const _result = await marketplace.purchaseProduct(productcount, {from: buyer, value: web3.utils.toWei('1', 'Ether')});
            const _event = _result.logs[0].args;
            assert.equal(_event.id.toNumber(), productcount.toNumber(), "Valid Id");
            assert.equal(_event.name, 'Xbox one', "Valid Name");
            assert.equal(_event.price, 1000000000000000000, "Valid Price");
            assert.equal(_event.owner, buyer, "Valid Owner");
            assert.equal(_event.purchased, true, "Valid Purchase status");

            // track seller balance after purchase
            let _newSellerBalance = await web3.eth.getBalance(seller);
            _newSellerBalance = new web3.utils.BN(_newSellerBalance);

            let price = web3.utils.toWei('1', 'Ether');
            price = new web3.utils.BN(price);

            const expectedBalance = _sellerBalance.add(price);
            assert.equal(_newSellerBalance.toString(), expectedBalance.toString() , "Valid Balance");
            
            // Failure : Buyer tries to buy a product that doesn't exist on network
            await marketplace.purchaseProduct(10, {from: buyer, value: web3.utils.toWei('1', 'Ether')}).should.be.rejected;

            // Failure : Buyer tries to buy a product with insufficient funds or for less price than quoted
            await marketplace.purchaseProduct(productcount, {from: buyer, value: web3.utils.toWei('0.5', 'Ether')}).should.be.rejected;

            // Failure : Deployer tries to buy the product
            await marketplace.purchaseProduct(productcount, {from: buyer, value: web3.utils.toWei('1', 'Ether')}).should.be.rejected;

            // Failure : Buyer tries to buy a product again
            await marketplace.purchaseProduct(productcount, {from: buyer, value: web3.utils.toWei('0.5', 'Ether')}).should.be.rejected;
        });
    });
});

// test results

/*
    ganesh@mac basic-marketplace % truffle test ./test/marketplace-test.js
    Using network 'development'.


    Compiling your contracts...
    ===========================
    ✔ Fetching solc version list from solc-bin. Attempt #1
    > Compiling ./contracts/Migrations.sol
    > Compiling ./contracts/marketplace.sol
    ✔ Fetching solc version list from solc-bin. Attempt #1
    > Compilation warnings encountered:

        Warning: Visibility for constructor is ignored. If you want the contract to be non-deployable, making it "abstract" is sufficient.
    --> project:/contracts/marketplace.sol:9:5:
    |
    9 |     constructor() public {
    |     ^ (Relevant source part starts here and spans across multiple lines).


    > Artifacts written to /var/folders/_7/pztlwypx3bz5zty5lnnw8ps80000gn/T/test--19823-9fOhrnnpdPq7
    > Compiled successfully using:
    - solc: 0.8.6+commit.11564f7e.Emscripten.clang


    Contract: Marketplace
        deployment
        ✓ check for successful deployment
        ✓ check for a valid name (53ms)
        products
        ✓ Check for successful product addition (1393ms)
        ✓ Check for products added to the network (66ms)
        ✓ Check for selling the products on marketplace (819ms)


    5 passing (3s)
            
*/

