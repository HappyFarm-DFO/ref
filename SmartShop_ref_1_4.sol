pragma solidity ^0.7.4;

contract ReferralFactory {
    uint public amount=300;
    string public uri="ipfs://ipfs/QmNWWea25ankd8kxxaV9fjRhKbeMd5dBvGoHoCmw9xTyVU";
    address public HappyFarm=0xfa28ED428D54424D42ED4F71415315df2f2E49D6;
    address public _collection;
    address[] public list;
    mapping(address => address)public badgeToSmartWallet;
    
    function init() public {
        require(_collection == address(0), "Init already called!");
        _collection = msg.sender;
    }

    function mint(address _ref)payable public {
        
        //pay 0.01 eth or multiple, now checks how many badges you paid for
        uint i=msg.value/10000000000000000;
        
        //20% to referral
        payable(_ref).transfer(msg.value/5);
        
        //wil generate max 10k wallets
        require(amount+i<=10000);
        amount+=i;
        
        for(uint x=0;x<i;x++){
            //mints item
            (,address tokenAddress) = IEthItem(_collection).mint(1, "SmartWallet_Badge", "SWB", uri, false);
        
            //generates wallet controlled by the ITEM
            SmartWallet sw=new SmartWallet(tokenAddress);
            
            //associate referral container to badge contract so we can find it later
            badgeToSmartWallet[tokenAddress]=address(sw);
            
            //adds the wallet to the list of wallets
            list.push(address(sw));
            
            //sends the item to the creator
            IERC20 token=IERC20(tokenAddress);
            token.transfer(msg.sender, token.balanceOf(address(this)));
        }
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
    
    function pull()public{
        payable(HappyFarm).transfer(address(this).balance);
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
    
    function pullToken(address _token)public onlyController{
         IERC20 token=IERC20(_token);
         token.transfer(msg.sender, token.balanceOf(address(this)));
    }
    
       function pullETH()public onlyController{
         payable(msg.sender).transfer(address(this).balance);
    }
}

interface IEthItem {
    function mint(uint256 amount, string calldata tokenName, string calldata tokenSymbol, string calldata objectUri, bool editable) external returns (uint256 objectId, address tokenAddress);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
} 
