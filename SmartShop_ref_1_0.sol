pragma solidity ^0.7.4;

contract ExtensionExample {
    address private _collection;
    uint public amount=300;
    string public uri="ipfs metada file address";
    address[] public list;
    address public HappyFarm=0xfa28ED428D54424D42ED4F71415315df2f2E49D6;
    
    function init() public {
        require(_collection == address(0), "Init already called!");
        _collection = msg.sender;
    }

    function mint()payable public {
        //pay 0.01 eth
        require(msg.value>=10000000000000000);
        //wil generate max 10k wallets
        require(amount<10000);
        amount++;
        //mints item
        (,address tokenAddress) = IEthItem(_collection).mint(1, "SmartWallet_Badge", "SWB", uri, false);
        //generates wallet controlled by the ITEM
        SmartWallet sw=new SmartWallet(tokenAddress);
        //adds the wallet to the list of wallets
        list.push(address(sw));
        //sends the item to the creator
        IERC20 token=IERC20(tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
    
    function lister(uint _index)public view returns(address,uint){
        address a;
        if(_index<=300){
            a=HappyFarm;
        }else{
            a=list[_index-300];
        }
        return (a,list.length);
        
    }

}

contract SmartWallet{
    IERC20 public controller;
    
    constructor(address _control){
        controller=IERC20(_control);
    }
    
     modifier onlyController {
        require(controller.balanceOf(msg.sender)==1);
        _;
    }
    
    function act()public onlyController{
        //pull eth or tokens or do things
        //only the owner of the controller ITEM can trigger this function
    }
}

interface IEthItem {
    function mint(uint256 amount, string calldata tokenName, string calldata tokenSymbol, string calldata objectUri, bool editable) external returns (uint256 objectId, address tokenAddress);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
} 
