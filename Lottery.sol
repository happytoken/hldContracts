pragma solidity >=0.5.0 <0.9.0;

contract Lottery {
    address payable[] public players; //there are 2 types of address (payable & non-payable)
    address public manager; //EOA that deploys the contract
    address public destory = 0x0000000000000000000000000000000000dEadfF; // destory address
    uint [] public totalHistory; // total bonus history
    address payable[][] public joinHistory; // players join history
    uint [] public bonusHistory; // player bonus history
    uint [] public timeHistory; // time bonus history
    uint [] public lenHistory; // length bonus history

    constructor() {
        manager = msg.sender;
       // players.push(payable(manager));
    }

    //Players enter lottery by sending 0.1ETH to the contract address. Players' address will be recorded
    //into dynamic array called players
    //For contract to receive ETH from EOA -> need receive() or fallback()
    receive () external payable {
        //make sure that the manager cannot participate in the lottery
        //require(msg.sender != manager);

        require(msg.value == 1 ether);

        //adds the address of the sender
        players.push(payable(msg.sender));//converting the address to payable address
    }
    
    //Returns contract's balance in wei
    function getBalance() public view returns(uint) {
        require(msg.sender == manager, "Only manager can check the balance");
        return address(this).balance;
    }

    // Return current round players length
    function getLength() public view returns(uint) {
        return players.length;
    }

    // Return history round count
    function getRound() public view returns(uint) {
        return lenHistory.length;
    }

    function random() public view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.number, block.timestamp, players.length, getRound())));
        //returning a random number
    }

    function pickWinner() public {
        require(msg.sender == manager);
        require(players.length >= 3);

        uint r = random(); //getting the randomly generated number
        address payable winner;

        //Getting the index based off of the random number
        uint index = r % players.length;
        winner = players[index];

        uint allBonus = getBalance();
        uint managerFee = (allBonus * 3) / 100;
        uint destoryBonus = (allBonus * 7) / 100;
        uint winnerBonus = (allBonus * 50) / 100;

        payable(manager).transfer(managerFee);
        payable(destory).transfer(destoryBonus);
        winner.transfer(winnerBonus);
        //transfer is a member function of any payable address & will transfer the amount
        //wei given as argument to the payable address, in this case winner

        // save lottery history
        totalHistory.push(allBonus);
        joinHistory.push(players);
        bonusHistory.push(index);
        timeHistory.push(block.timestamp);
        lenHistory.push(players.length);

        //after sending the winning money, resetting the players state variable
        players = new address payable[](0); //0 means the size of the new dynamic array
    }
}