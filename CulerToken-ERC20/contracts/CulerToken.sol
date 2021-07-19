// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

contract CulerToken {
    string public message;
    string public name = "Culer Token";
    string public symbol = "Culer";
    string public standard = "Culer Token v1.0";
    uint256 public totalSupply;
    

    // to store balances of each account that holds a token
    mapping(address => uint256) public balances;
    // to store spending of owner and spender that holds a token
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(
        address indexed _from, 
        address indexed _to, 
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint _value
    );

    constructor(uint256 _initialSupply) public {
        message = "Ganesh's Culer Token";
        balances[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer( msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value);
        require(allowance[_from][msg.sender] >= _value);

        balances[_from] -= _value;
        balances[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);

        return true;
    }
}