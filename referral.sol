
contract ETHitemReferralDB{
    function ownerOf(uint _id)public returns(address){
        address a=0x9401e8c832058C308398923019A2CC23e169687F;
        return a;
    }
}

contract Ref{
    
    address public master;
    uint public id;
    ETHitemReferralDB ethrdb=ETHitemReferralDB(0x9401e8c832058C308398923019A2CC23e169687F);
    
    constructor(address _creator,uint _id) public {
        master=_creator;
        id=_id;
    }
    
    function pull(address _tkn)public returns(address){
        ERC20 token=ERC20(_tkn);
        uint bal=token.balanceOf(address(this));
        require(bal>=5);
        token.transfer(0x9401e8c832058C308398923019A2CC23e169687F,bal/5);
        token.transfer(0x9401e8c832058C308398923019A2CC23e169687F,bal*3/5);
        token.transfer(ethrdb.ownerOf(id),token.balanceOf(address(this)));
    }
    
    function setMaster(address mstr)public returns(bool){
        require(msg.sender==master);
        master=mstr;
        return true;
    }

}

contract refBook{
    
    //list of referral contracts
    address[] public referral;
    
    function createRef()public returns(address,uint){
        
        Ref r=new Ref(msg.sender,referral.length+1);
        referral.push(address(r));
        return (address(r),referral.length);
    }
    
    function id2address(uint _id)public view returns(address){
        return referral[_id];
    }
    
    function list(uint _id)public view returns(address,uint){
        return (referral[_id],referral.length);
    }
}


contract Ticket {
    
    uint8 public code=4;
    address public vault;
    HappyBox public box;
    priceList public prices;
    refBook ref;
    
    constructor(address vlt, address prcs, address gftr) public{
        vault=vlt;
        prices=priceList(prcs);
        box=HappyBox(gftr); 
        ref=refBook(0x9401e8c832058C308398923019A2CC23e169687F);
    }
    
    function buy(address tkn,uint _id) payable public returns(bool){
        require(box.ship(tkn,msg.value*1000/prices.price(tkn),msg.sender));
        payable(ref.id2address(_id)).transfer(msg.value/200);
        return true;
    } 
    
    function pull() public {
       payable(vault).transfer(address(this).balance);
    }
    
}
