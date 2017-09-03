pragma solidity ^0.4.4;

contract Splitter {

	address public sender;

	address public receiver1;
	uint 		public receiver1Balance;

	address public receiver2;
	uint 		public receiver2Balance;

	event   LogReceiver1Set(address receiverAddress);
	event   LogReceiver2Set(address receiverAddress);
	event   LogFundsFromSenderReceived(uint amount);
	event   LogReceiver1Withdrawed(uint amount);
	event   LogReceiver2Withdrawed(uint amount);


	function Splitter() {
		/* the person sending funds to be splitted
			will be the contract creator */
		sender = msg.sender;
	}


	/* receivers are set with setters and not in the
	constructor */
	function setReceiver1(address _address) {
		if (msg.sender != sender) throw;
		receiver1 = _address;
		LogReceiver1Set(receiver1);
	}

	function setReceiver2(address _address) {
		if (msg.sender != sender) throw;
		receiver2 = _address;
		LogReceiver2Set(receiver2);
	}

	/* no reason to implement a balance when there is already
	a function that gets the balance of a contract address */

	/*function getBalance() public returns(uint) {
		return this.balance;
	}*/

	/* Fallback function to check if ether comes from sender*/
	function () payable {
		if (msg.sender == sender) {
			receiver1Balance += msg.value / 2;
			receiver2Balance += msg.value / 2;
			LogFundsFromSenderReceived(msg.value);
		}
	}

	function getSenderBalance() public returns (uint) {
		return sender.balance;
	}

	function getReceiver1Balance() public returns (uint) {
		return receiver1.balance;
	}

	function getReceiver2Balance() public returns (uint) {
		return receiver2.balance;
	}

	/* pattern in which receiver 1 and 2 can withdraw their funds
		instead of sending them every time funds arrive */
	function getMyFunds() public returns (bool success){
		if (msg.sender != receiver1 && msg.sender != receiver2) throw;

		uint fundsToSend;

		if (msg.sender == receiver1) {
			fundsToSend = receiver1Balance;
			/* reset funds before sending */
			receiver1Balance = 0;
			if(!receiver1.send(fundsToSend)) {
				/* sent failed, so keep the funds available */
				receiver1Balance = fundsToSend;
			}
			LogReceiver1Withdrawed(fundsToSend);
			return true;
		}

		if (msg.sender == receiver2) {
			fundsToSend = receiver2Balance;
			/* reset funds before sending */
			receiver2Balance = 0;
			if(!receiver2.send(fundsToSend)) {
				/* sent failed, so keep the funds available */
				receiver2Balance = fundsToSend;
			}
			LogReceiver2Withdrawed(fundsToSend);
			return true;
		}

		return false;
	}

	function kill() public {
		if(msg.sender == sender) {
			selfdestruct(sender);
		}
	}
}
