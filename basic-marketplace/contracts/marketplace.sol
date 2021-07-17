// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0;

contract marketplace {
    string public name;
    uint public productsCount = 0;

    constructor() public {
        name = "Ganesh's marketplace";
    }

    struct Product {
        uint id;
        string name;
        uint price;
        address payable owner;
        bool purchased;
    }

    mapping(uint => Product) public products;

    event ProductAdded(
        uint id,
        string name,
        uint price,
        address payable owner,
        bool purchased
    );

    function addProduct(string memory _name, uint _price) public {
        require(bytes(_name).length > 0 );  // require a valid name
        require(_price > 0);                // require a valid price
        productsCount ++;                   // increment the product count
        products[productsCount] = Product(productsCount, _name, _price, payable(msg.sender), false);

        // Trigger an event on successful product addition
        emit ProductAdded(productsCount, _name, _price, payable(msg.sender), false);
    }
    
    event ProductPurchased(
        uint id,
        string name,
        uint price,
        address payable owner,
        bool purchased
    );

    function purchaseProduct(uint _id) external payable {
        Product memory _product = products[_id]; 
        address payable _seller = _product.owner;

        require(_product.id > 0 && _product.id <= productsCount);     // check if the product exists on the network
        require(! _product.purchased);                                 // check if the product is not purchased
        require(msg.value >= _product.price);                         // check if the buyer has enough ether(value) to buy  
        require(_seller != msg.sender);                               // check if buyer is not seller

        
        _product.owner = payable(msg.sender);    // transfer ownership to the buyer
        _product.purchased = true;      // mark the products purchased 
        products[_id] = _product;       // update the product to the network
        
        payable(_seller).transfer(msg.value);   // pay the seller with ether
        
        // Trigger the event when purchased
        emit ProductPurchased(productsCount, _product.name, _product.price, payable(msg.sender), true);
    }
}
