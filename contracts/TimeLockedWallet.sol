pragma solidity ^0.4.18;
import "./ERC20.sol";

// variables.
contract TimeLockedWallet {
    address public creator;
    address public owner;
    uint public unlockDate;
    uint public createdAt;

// condition that has to be met before starting the function below.
modifier onlyOwner {
  require(msg.sender == owner);
  _;
}
// contructor gets called when the contract is created.
// the name has to be the same as the filename else it will create a backdoor.
// "parity multisig wallet bug"(https://medium.com/@codetractio/a-look-into-paritys-multisig-wallet-bug-affecting-100-million-in-ether-and-tokens-356f5ba6e90a)
function TimeLockedWallet(
    address _creator, address _owner, uint _unlockDate
) public {
    creator = _creator;
    owner = _owner;
    unlockDate = _unlockDate;
    createdAt = now;
}
// keeps all the funds sent to this address.
function() payable public { 
  Received(msg.sender, msg.value);
}
// returs current balanance.
function info() public view returns(address, address, uint, uint, uint) {
    return (creator, owner, unlockDate, createdAt, this.balance);
}
// callable by owner after set time.
function withdraw() onlyOwner public {
   require(now >= unlockDate);
   // sends all the funds.
   msg.sender.transfer(this.balance);
   Withdrew(msg.sender, this.balance);
}

// callable by owner  after set time to implement ERC20 tokens.
function withdrawTokens(address _tokenContract) onlyOwner public {
   require(now >= unlockDate);
   ERC20 token = ERC20(_tokenContract);
   // sends all the funds.
   uint tokenBalance = token.balanceOf(this);
   token.transfer(owner, tokenBalance);
   WithdrewTokens(_tokenContract, msg.sender, tokenBalance);
}
// returns current funds in the contract.
function info() public view returns(address, address, uint256, uint256, uint256) {
        return (creator, owner, unlockDate, createdAt, this.balance);
    }
    // creates reciepts on the blockchain.
    event Received(address from, uint256 amount);
    event Withdrew(address to, uint256 amount);
    event WithdrewTokens(address tokenContract, address to, uint256 amount);
}
