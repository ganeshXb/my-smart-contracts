// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "./CulerToken.sol";

contract CulerTokenSale {
    string public message;
    address payable public admin;
    CulerToken public CulerContract;
    uint256 public CulerPrice;
    uint256 public CulersSold;

    event Sell(
        address _buyer, 
        uint256 _amount
    );

    constructor(CulerToken _CulerCotract, uint256 _CulerPrice) public {
        message = "Ganesh's Culer Token Sale";
        admin = payable(msg.sender);
        CulerContract = _CulerCotract;
        CulerPrice = _CulerPrice;
    }

    function multiply(uint x, uint y) internal pure returns (uint z){
        require(y == 0 || (z = x*y)/y == x);
    }

    function buyCulers(uint256 _numOfCulers) public payable {
        require(msg.value == multiply(_numOfCulers, CulerPrice));
        require(CulerContract.balances(address(this)) >= _numOfCulers);
        require(CulerContract.transfer(msg.sender, _numOfCulers));

        CulersSold += _numOfCulers;
        emit Sell(msg.sender, _numOfCulers);
    }

    function endCulerSale() public {
        require(msg.sender == admin);
        require(CulerContract.transfer(admin, CulerContract.balances(address(this))));

        admin.transfer(address(this).balance);
    }
}