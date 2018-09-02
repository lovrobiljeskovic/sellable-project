pragma solidity ^0.4.24;

contract Sellable {

  address public owner;
  bool public selling = false;
  address public sellingTo;
  uint public askingPrice;

  modifier onlyOwner {
    require(
      msg.sender == owner,
      "You are not an owner of this contract"
    );
    _;
  }

  modifier ifNotLocked {
    require(
      !selling,
      "This contract is locked for sale"
    );
    _;
  }

  event Transfer(uint _saleDate, address _from, address _to, uint _salePrice);

  constructor() public {
    owner = msg.sender;
    emit Transfer(block.number * 15, address(0), owner, 0);
  }

  function initiateSale(uint _price, address _to) public onlyOwner {
    require(
      _to != address(this) && _to != owner,
      "You cannot sell the contract to yourself"
      );
    require(
      !selling,
      "This contract is already locked for sale"
    );
    selling = true;
    sellingTo = _to;
    askingPrice = _price;
  }

  function cancelSale() public onlyOwner {
    require(
      selling,
      "You cannot cancel a sale if contract is not set up for sale"
      );
    resetSale();
  }

  function completeSale(uint valued) public payable {
    require(
      selling,
      "Contract is not for sale"
    );
    require(
      msg.sender != owner,
      "Owner cannot be a buy of a contract"
    );
    require(
      msg.sender == sellingTo || sellingTo == address(0),
      "New owner must match the address which bought the contract"
    );
    require(
      valued == askingPrice,
      "Value must match the asking price"
    );
    address prevOwner = owner;
    address newOwner = msg.sender;
    uint salePrice = askingPrice;
    owner = newOwner;

    emit Transfer(block.number * 15, prevOwner, newOwner, salePrice);
    resetSale();
  }

  function resetSale() internal {
    selling = false;
    sellingTo = address(0);
    askingPrice = 0;
  }
}
