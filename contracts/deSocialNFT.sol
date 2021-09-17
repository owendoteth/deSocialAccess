pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "OpenZeppelin/openzeppelin-contracts@3.0.0/contracts/token/ERC721/ERC721.sol";

contract HasSecondarySaleFees is ERC165 {
    address payable teamAddress;
    uint256 teamSecondaryBps;

	/*
    * bytes4(keccak256('getFeeBps(uint256)')) == 0x0ebd4c7f
    * bytes4(keccak256('getFeeRecipients(uint256)')) == 0xb9c4d9fb
    *
    * => 0x0ebd4c7f ^ 0xb9c4d9fb == 0xb7799584
    */

    bytes4 private constant _INTERFACE_ID_FEES = 0xb7799584;

    constructor() public {
        _registerInterface(_INTERFACE_ID_FEES);
    }

    function getFeeRecipients(uint256 id) public view returns (address payable[] memory){
        address payable[] memory addressArray = new address payable[](1);
        addressArray[0] = teamAddress;
        return addressArray;
    }

    function getFeeBps(uint256 id) public view returns (uint[] memory){
        uint[] memory bpsArray = new uint[](1);
        bpsArray[0] = teamSecondaryBps;
        return bpsArray;
    }
}

//owen.eth
contract deSocialBetaBuddy is ERC721("Beta Buddies by de.Social", "BETA BUDDY"), HasSecondarySaleFees{

	address public owner;
	uint256 public limit = 8888;
	uint256 public price = 75000000000000000; // 0.075 eth
	uint256 public dropTime;

	mapping(uint256 => bool) public redeemed;
	mapping(address => bool) public betaUser;

	constructor(uint256 _time) public {
		require(_time > block.timestamp);
		dropTime = _time;
		owner = msg.sender;
		_setBaseURI("https://nft.de.social/token/");

		for(uint i = 0; i < 50; i++) {
			_mint(owner, totalSupply() + 1);
		}
	}

	function mint(uint256 _amount) public payable {
		require(block.timestamp >= dropTime, "Drop not yet available!");
		require( 1 <= _amount && _amount <= 10, "1-10 tx limit");
		require(msg.value == _amount * price, "Invalid payable");
		require((totalSupply() + _amount) <= limit, "Sold out!");

		for (uint i = 0; i < _amount; i++) {
			_mint(msg.sender, totalSupply() + 1);
		}
	}

	function register(uint256 _token, address _user) public {
		require(redeemed[_token] != true);
		require(ownerOf(_token) == msg.sender);
		require(betaUser[_user] != true);

		betaUser[_user] = true;
		redeemed[_token] = true;
	}

	function collect() public {
		require(msg.sender == owner);
		payable(owner).transfer(address(this).balance);
	}

	function updateTeamAddress(address payable newTeamAddress) public {
		require(msg.sender == owner);
        teamAddress = newTeamAddress;
    }

    function updateSecondaryFee(uint256 newSecondaryBps) public {
		require(msg.sender == owner);
        teamSecondaryBps = newSecondaryBps;
    }

	function updateURI(string memory newURI) public {
		require(msg.sender == owner);
		_setBaseURI(newURI);
	}

	function changeOwner(address _newOwner) public {
		require(msg.sender == owner);
		owner = _newOwner;
	}




}