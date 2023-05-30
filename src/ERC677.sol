// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC677Receiver} from "./interfaces/IERC677Receiver.sol";

contract FeedBackToken is ERC20 {
    address public protocolAdmin;

    constructor(string memory _tokenName, string memory _tokenSymbol, uint256 _totalSupply, address _admin)
        ERC20(_tokenName, _tokenSymbol)
    {
        _mint(address(this), _totalSupply);
        protocolAdmin = _admin;
    }

    modifier onlyProtocol() {
        require(msg.sender == protocolAdmin, "Only admin can call this function");
        _;
    }

    function send(address _to, uint256 _value) external onlyProtocol {
        _transfer(address(this), _to, _value);
    }

    function updateAdmin(address _newAdmin) external onlyProtocol {
        protocolAdmin = _newAdmin;
    }

    function transferAndCall(address _to, uint256 _value, bytes memory _data) public returns (bool) {
        super.transfer(_to, _value);
        if (isContract(_to)) {
            contractFallback(msg.sender, _to, _value, _data);
        }
        return true;
    }

    function transferAndCallFrom(address _sender, address _to, uint256 _value, bytes memory _data)
        internal
        returns (bool)
    {
        _transfer(_sender, _to, _value);
        if (isContract(_to)) {
            contractFallback(_sender, _to, _value, _data);
        }
        return true;
    }

    function contractFallback(address _sender, address _to, uint256 _value, bytes memory _data) internal {
        IERC677Receiver receiver = IERC677Receiver(_to);
        receiver.onTokenTransfer(_sender, _value, _data);
    }

    function isContract(address _addr) internal view returns (bool hasCode) {
        uint256 length;
        assembly {
            length := extcodesize(_addr)
        }
        return length > 0;
    }
}
