// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

contract Ecometh {
    string public cname;
    address payable public owner;
    uint id;
    uint purchaseId;

    constructor() public {
        cname = "Ganesh's Ecom";
        owner = payable(msg.sender);
    }

    // struct type for seller details
    struct seller{
        string name;
        address addr;
        uint depositGuarantee;  
        bool dgPaid;
    }

    // struct type for product details
    struct product{
        string productId;
        string productName;
        string Category;
        uint price;
        string description;
        address payable seller;
        bool isAvailable;
    }

    // struct type for purchase orders placed
    struct ordersPlaced{
        string productId;
        uint purchaseId;
        address orderedBy;
    }

    // struct types for shipment details
    struct sellerShipment{
        string productId;
        uint purchaseId;
        string shipmentStatus;
        string deliveryAddress;
        address payable orderedBy;
        bool isActive;
        bool isCancelled;
    }

    // to store register seller
    mapping(address => seller) public sellers;

    // to store products of various sellers
    mapping(string => product) public products;
    product[] public allProducts;

    // to store the order details
    mapping(address => ordersPlaced[]) public sellerOrders;

    //to store shipment details of product delivery
    mapping(address => mapping(uint => sellerShipment)) sellerShipments;    
    // inner mapping key: uint (purchaseId), value: corresponding shipment details of purchaseId
    // outer mapping key: address (orderby), value: shipment details

    // function to register Seller on the ecom network with deposit guarantee
    function SellerRegistration(string memory _name) public payable {

        // require that Seller hasn't already paid the deposit guarantee
        require(!sellers[msg.sender].dgPaid);

        // require that deposit guarantee is 5 ether
        require(msg.value == 5 ether);
        
        // pay the deposit guarantee to the owner
        owner.transfer(msg.value);
        
        // add the Seller details to sellers to register them on the network
        sellers[msg.sender].name = _name;
        sellers[msg.sender].addr = msg.sender;
        sellers[msg.sender].depositGuarantee = msg.value;
        sellers[msg.sender].dgPaid = true;
    }

    // function for Seller to add products to the network
    function addProduct(string memory _productId, string memory _productName, string memory _category, uint _price, string memory _description) public{
        
        // require that product isn't already available on the network
        require(!products[_productId].isAvailable);

        // require that Seller has paid deposit guarantee and registered to network
        require(sellers[msg.sender].dgPaid);

        // add the product to the products mapping
        product memory _product = product(_productId, _productName, _category, _price, _description, payable(msg.sender), true);
        products[_productId].productId = _productId;
        products[_productId].productName = _productName;
        products[_productId].Category = _category;
        products[_productId].price = _price;
        products[_productId].description = _description;
        products[_productId].seller = payable(msg.sender);
        products[_productId].isAvailable = true;

        // add all the products to allProducts array for listing all products using array looping
        allProducts.push(_product);
    }

    // function returns orders placed by Buyers
    function getOrdersPlacedDetails(uint _index) public view returns(string memory, uint, address, string memory){
        
        // return details of orders placed
        return(
            sellerOrders[msg.sender][_index].productId,
            sellerOrders[msg.sender][_index].purchaseId,
            sellerOrders[msg.sender][_index].orderedBy,
            sellerShipments[msg.sender][sellerOrders[msg.sender][_index].purchaseId].shipmentStatus
        );
    }

    // function returns the shipment details of placd orders
    function getOrderShipmentDetails(uint _purchaseId) public view returns(string memory, string memory, address, string memory){
        
        // return shipmetn details of orders
        return(
            sellerShipments[msg.sender][_purchaseId].productId,
            sellerShipments[msg.sender][_purchaseId].shipmentStatus,
            sellerShipments[msg.sender][_purchaseId].orderedBy,
            sellerShipments[msg.sender][_purchaseId].deliveryAddress
        );
    }

    // function that updatea product shipment details
    function updateOrderShipmentDetails(uint _purchaseId, string memory _shipmentDetails) public {
        
        // require that product shipment is still active
        require(sellerShipments[msg.sender][_purchaseId].isActive);

        // update the shipment status
        sellerShipments[msg.sender][_purchaseId].shipmentStatus = _shipmentDetails;
    }

    function refundOnCancellation(string memory _productId, uint _purchaseId) public payable {

        require(!sellerShipments[products[_productId].seller][_purchaseId].isActive);
        require(sellerShipments[msg.sender][_purchaseId].isCancelled);
        require(msg.value == products[_productId].price);

        sellerShipments[msg.sender][_purchaseId].orderedBy.transfer(msg.value);
        sellerShipments[products[_productId].seller][_purchaseId].shipmentStatus = "Order Cancellation Success, Payment Refund Processes";
    }
}