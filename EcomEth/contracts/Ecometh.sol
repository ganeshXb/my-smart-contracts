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

    // struct type for buyer details
    struct user{
        string name;
        string email;
        string deliveryAddress;
        bool isUser;
    }

    // struct type for user order details
    struct orders{
        string productId;
        uint purchaseId;
        string orderStatus;
        string shipmentStatus;
    }

    // to store registered seller
    mapping(address => seller) public sellers;

    // to store products of various sellers
    mapping(string => product) public products;
    product[] public allProducts;

    // to store the order details
    mapping(address => ordersPlaced[]) public sellerOrders;

    //to store shipment details of product delivery
    mapping(address => mapping(uint => sellerShipment)) sellerShipments;    
    // inner mapping key: uint (purchaseId), value: corresponding shipment details of purchaseId
    // outer mapping key: address (seller address), value: shipment details

    // to store registered user
    mapping(address => user) public users;

    //to store user orders
    mapping(address => orders[]) public userOrders;

    // function to register Seller on the ecom network with deposit guarantee
    function SellerRegistration(string memory _name) public payable {
        // require that Seller hasn't already paid the deposit guarantee
        require(!sellers[msg.sender].dgPaid, "Seller not registered");

        // require that deposit guarantee is 5 ether
        require(msg.value == 5 ether, " Deposit guarantee of 5 ETH");
        
        // pay the deposit guarantee to the owner
        owner.transfer(msg.value);
        
        // add the Seller details to sellers to register them on the network
        sellers[msg.sender].name = _name;
        sellers[msg.sender].addr = msg.sender;
        sellers[msg.sender].depositGuarantee = msg.value;
        sellers[msg.sender].dgPaid = true;
    }

    // function for Seller to add products to the network
    function addProductToEcom(string memory _productId, string memory _productName, string memory _category, uint _price, string memory _description) public{    
        // require that product isn't already available on the network
        require(!products[_productId].isAvailable, "Product already available on network");

        // require that Seller has paid deposit guarantee and registered to network
        require(sellers[msg.sender].dgPaid, "Seller hasn't paid deposit guarantee");

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

    // function to register user to the network
    function UserRegistration(string memory _name, string memory _email, string memory _deliveryAddress) public{
        
        // require that users aren't registered to Ecom 
        require(!users[msg.sender].isUser, "User already exists on network");

        // add the user details to users to register them on the network
        users[msg.sender].name = _name;
        users[msg.sender].email = _email;
        users[msg.sender].deliveryAddress = _deliveryAddress;
        users[msg.sender].isUser = true;
    }

    // function that lets the user purchase product
    function PurchaseProducts(string memory _productId) public payable {

        // require that user is registered
        require(users[msg.sender].isUser, "User must be registered");

        // require that product is available
        require(products[_productId].isAvailable, "Product should be available");

        // require that price paid is same as product price
        require(msg.value == products[_productId].price, "Value Must be Equal to Price of Product");

        // pay the seller the price
        products[_productId].seller.transfer(msg.value);
        
        //increment purchase Id for every purchase
        purchaseId = id++;

        // Add orders to the userOrders mapping
        orders memory _order = orders(_productId, purchaseId, "Order Placed with Seller", sellerShipments[products[_productId].seller][purchaseId].shipmentStatus);
        userOrders[msg.sender].push(_order);

        // Add orders to the sellerOrders mapping
        ordersPlaced memory _orderPlaced = ordersPlaced(_productId, purchaseId, msg.sender);
        sellerOrders[products[_productId].seller].push(_orderPlaced);

        // Update the shipment details of everyorder placed
        sellerShipments[products[_productId].seller][purchaseId].productId = _productId;
        sellerShipments[products[_productId].seller][purchaseId].purchaseId = purchaseId;
        sellerShipments[products[_productId].seller][purchaseId].orderedBy = payable(msg.sender);
        sellerShipments[products[_productId].seller][purchaseId].deliveryAddress = users[msg.sender].deliveryAddress;
        sellerShipments[products[_productId].seller][purchaseId].isActive = true;    
    }

    // function that updatea product shipment details
    function updateOrderShipmentDetails(uint _purchaseId, string memory _shipmentDetails) public {
        // require that product shipment is still active
        require(sellerShipments[msg.sender][_purchaseId].isActive, "Product shipment is active");

        // update the shipment status
        sellerShipments[msg.sender][_purchaseId].shipmentStatus = _shipmentDetails;
    }

    // function that cancels orders
    function CancelOrders(string memory _productId, uint _purchaseId) public payable {
        // require that the order is cancelled by the buyer
        require(sellerShipments[products[_productId].seller][_purchaseId].orderedBy == payable(msg.sender), "User not autherized to cancel this order");
        
        // require that order isn't cancelled yet
        require(sellerShipments[products[_productId].seller][_purchaseId].isActive, "Order already cancelled");

        // update shipment status
        sellerShipments[products[_productId].seller][_purchaseId].shipmentStatus = "Buyer cancelled the order, payment refund processed";

        // update order cancellaion status 
        sellerShipments[products[_productId].seller][_purchaseId].isCancelled = true;

        // update shipment status
        sellerShipments[products[_productId].seller][_purchaseId].isActive = false;
    }

    // function that refunds the payment when order is cancelled by the buyer
    function refundOnCancellation(string memory _productId, uint _purchaseId) public payable {
        // the product with purchaseId's order is active or not
        require(!sellerShipments[products[_productId].seller][_purchaseId].isActive, "Shipment is still active");

        // require the buyer has cancelled the order
        require(sellerShipments[msg.sender][_purchaseId].isCancelled, "Order isn't cancelled by buyer yet");

        // require the value to refund is equal to the price paid by the buyer
        require(msg.value == products[_productId].price, "Value Must be Equal to Price of Product" );

        // refund the price paid to the address orderedBy (the buyer)
        sellerShipments[msg.sender][_purchaseId].orderedBy.transfer(msg.value);

        // return a message after successfull cancellation and refund process
        sellerShipments[products[_productId].seller][_purchaseId].shipmentStatus = "Order Cancellation Success, Payment Refund Processes";
    }

    // function that returns the details of user orders
    function UserPurchaseOrders(uint _index) public view returns(string memory, uint, string memory, string memory) { 
        // return user order details
        return(
            userOrders[msg.sender][_index].productId,
            userOrders[msg.sender][_index].purchaseId,
            userOrders[msg.sender][_index].orderStatus,
            sellerShipments[products[userOrders[msg.sender][_index].productId].seller][userOrders[msg.sender][_index].purchaseId].shipmentStatus
            // sellerShipments arg 1 -> seller address. seller address is only available in products mapping
            // products mapping can be accessed with productId 
        );
    }

    // function returns the shipment details of placd orders
    function getOrderShipmentDetails(uint _purchaseId) public view returns(string memory, string memory, address, string memory){    
        // return shipment details of orders
        return(
            sellerShipments[msg.sender][_purchaseId].productId,
            sellerShipments[msg.sender][_purchaseId].shipmentStatus,
            sellerShipments[msg.sender][_purchaseId].orderedBy,
            sellerShipments[msg.sender][_purchaseId].deliveryAddress
        );
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
}