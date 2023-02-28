// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding{
    mapping(address=>uint) public contributors;// Addrewss of the contributors linking with the value paid
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public  target;
    uint public raisedAmount;
    uint public noOfcontributors;
// manager request krega pasie crowd se ki wo smartcontracts sa i nikl le
 struct Request{
     string description;// ki cheez ke liye paise mange rha hai manager
      address payable recipient;// kiske liyai mang rhe hai isko paise dena hai
      uint value;// kitna dena hai
      bool completed;
      uint noOfVoters;
 mapping(address=>bool) voters ;// adress=>vote true aur false

 }
 mapping (uint=>Request) public requests;// this mapping consist of mapping no
 uint public numRequests;

 constructor(uint _target,uint _deadline)
 {
    target=_target;
    deadline=block.timestamp+_deadline;//block.timestamp is a globa varaible in solidity which gives the timestamp of the current block 
    //10sec+3600....10 sec contarct gets deploy.....and we want that the contract lasts for 1 hour
minimumContribution=100 wei;
manager=msg.sender;

}
function sendEth() public  payable{
    require(block.timestamp <deadline,"Deadline has passed");//the time when sender sends the ether at that time  contract should exsist ..should not cross the deadline  otherwise deadline has crossed gets print
    require(msg.value>=minimumContribution,"minimum Contribution is not met");
    if(contributors[msg.sender]==0){

// if contribution is for the first time then increase the of contributors
    noOfcontributors++;//after contribution no of contributors increases
}
contributors[msg.sender]=contributors[msg.sender] +msg.value;//
raisedAmount+=msg.value;//value transfere is added to the raised amount

}
function getContractBalance() public view  returns(uint) {
   //checking the contract balance
 return address(this).balance;
 }

function refund() public{
    require(block.timestamp>deadline &&raisedAmount<target,"you are not eligible for refund");
    require(contributors[msg.sender]>0);// check whether contributor has contributed or not
    address payable user=payable(msg.sender);//user variable stroing payable msg.sender
    user.transfer(contributors[msg.sender]);//transfering the amount given by the contributor
    contributors[msg.sender]=0;// resetting the amount 
}
 modifier onlyManger(){
        require(msg.sender==manager,"Only manager can calll this function");
        _;
    }
    // this function helps in creation of requests
    function createRequests(string memory _description,address payable _recipient,uint _value) public onlyManger{
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description=_description;
        newRequest.recipient=_recipient;
        newRequest.value=_value;
        newRequest.completed=false;
        newRequest.noOfVoters=0;
    }
    // this function allows voting
     function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender]>0,"YOu must be contributor");
        Request storage thisRequest=requests[_requestNo];// jis bhi no ki request ko ham vote krna chahte h usko point krahe hai
        require(thisRequest.voters[msg.sender]==false,"You have already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;
    }
     function makePayment(uint _requestNo) public onlyManger{
        require(raisedAmount>=target);
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.completed==false,"The request has been completed");
        require(thisRequest.noOfVoters > noOfcontributors/2,"Majority does not support");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;
    }
}
    



