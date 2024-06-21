// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract PurchaseAgreement{
    uint public value;
    address payable public buyer;
    address payable public seller;

    enum State{
        Created,
        Locked,
        Release,
        Intactive
    }

    State public state;

    // the function cannot be called at the current state;
    error InvalidState();

    // only the buyer can call this function 
    error OnlyBuyer();

    // only the seller can call this function 
    error OnlySeller();

    modifier inState(State _state){
        if(state != _state){
            revert InvalidState();
        }
        _;
    }

    modifier onlyBuyer(){
        if(msg.sender != buyer){
            revert OnlyBuyer();
        }
        _;
    }

        modifier onlySeller(){
        if(msg.sender != seller){
            revert OnlySeller();
        }
        _;
    }


    constructor() payable{
        seller = payable(msg.sender);    
        value = msg.value / 2;
    }

    function purchase() external inState(State.Created) payable {
        require(msg.value == (2 * value),"Please send x2 the purchase amount");
        buyer = payable(msg.sender);
        state = State.Locked;
    }

    function confirmReceiver() external onlyBuyer inState(State.Locked){
        state = State.Release;
        buyer.transfer(value);
    }

    function paySeller() external onlySeller inState(State.Release){
        state = State.Intactive;
        seller.transfer(3 * value);
    }

    function abort() external onlySeller inState(State.Created){
        state = State.Intactive;
        seller.transfer(address(this).balance);
    }

}