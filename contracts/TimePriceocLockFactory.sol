// minimum version required.
pragma solidity ^0.4.18;

// others contracts.
import "./TimePriceLock.sol";

// main object.
contract TimeLockedWalletFactory {

// mapping contains the wallets of users/contract creators/owners.
mapping(address => address[]) wallets;

// returning the contract wallets created by users.
// view doesnt change the blockchain state and doesnt cost gas.
function getWallets(address _user) 
    public
    view
    returns(address[])
{
    return wallets[_user];
}

// creates a new timelocked wallet on the fly.
function newTimeLockedWallet(address _owner, uint _unlockDate)
    payable
    public
    returns(address wallet)
{
    // creates a new wallet.
    wallet = new TimeLockedWallet(msg.sender, _owner, _unlockDate);
    
    // adds wallet to senders wallet.
    wallets[msg.sender].push(wallet);
    
    // adds wallet to senders wallet if owner and sender are de same.
    if(msg.sender != _owner){
        wallets[_owner].push(wallet);
    }
    
    // send funds to new contract.
    wallet.transfer(msg.value);
    
    // event
    Created(wallet, msg.sender, _owner, now, _unlockDate, msg.value);
}
    // prevents sending funds to factory.
    function () public {
        revert();
    }
    // passes all the optional funds to a new wallet.
    event Created(address wallet, address from, address to, uint256 createdAt, uint256 unlockDate, uint256 amount);
}