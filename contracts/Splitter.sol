pragma solidity ^0.4.4;

contract Splitter {

	mapping (address => uint) public balances;

	event   LogFundsReceived(uint amount, address sender, address receiver1, address receiver2);
	event   LogFundsWithdrawn(uint amount, address receiver);

	function Splitter() {
	}

	/* Fallback function to check if ether comes from sender*/
	function split(address receiver1, address receiver2) payable returns (bool success) {
		balances[receiver1] += msg.value / 2;
		balances[receiver2] += msg.value / 2;

		/* handle odd numbers */
		uint remainder = msg.value - (msg.value / 2) - (msg.value / 2);
		if (remainder > 0) {
			if(!msg.sender.send(remainder)) {
				// problem sending remainder back to sender
			}
		}

		LogFundsReceived(msg.value, msg.sender, receiver1 , receiver2);
		return true;
	}

	function getBalanceOf(address receiver) public returns (uint) {
		return balances[receiver];
	}

	function getMyFunds() public returns (bool success){
		if (balances[msg.sender] == 0) throw;

		uint orgBalance = balances[msg.sender];
		/* reset funds before sending */
		balances[msg.sender] = 0;
		if(!msg.sender.send(orgBalance)) {
			/* sent failed, so keep the funds available */
			balances[msg.sender] = orgBalance;
			return false;
		}

		LogFundsWithdrawn(orgBalance, msg.sender);
		return true;
	}

}
