// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.5.0 <0.9.0;

contract CrowdFunding {
    mapping (address=>uint)public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public totalContribution;

    struct Request {
        string description;
        address payable recipient;
        uint Value;
        bool completed;
        uint noofVoters;
        mapping (address=>bool) voters;
    }

    mapping (uint=>Request) public request;
    uint public numRequest;

    constructor(uint _target,uint _deadline){
        minimumContribution = 100 wei;
        deadline = block.timestamp+_deadline; //10sec + 3600sec(60*60)
        target = _target;
        manager=msg.sender;
    }

    function sendEth() public payable {
        require(block.timestamp < deadline,"Dealine has passed.");
        require(msg.value >=minimumContribution,"Eth send amount should be greater than minimum contribution.");

        if (contributors[msg.sender]==0){
            totalContribution++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }

    function grtContractBalance() public  view  returns (uint){
        return address(this).balance;
    }

    function refund() public {
        require(block.timestamp>deadline && raisedAmount<target,"you are not eligible for  asjzrefund.");
        require(contributors[msg.sender]>0);
        address payable user=payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }

    modifier onlyManger(){
        require(msg.sender==manager,"only manager can call this function.");
        _;
    }

    function createRequest(string memory _description, address payable _recipient, uint _Value) public onlyManger{
        Request storage newRequest = request[numRequest];
        numRequest++;
        newRequest.description=_description;
        newRequest.recipient=_recipient;
        newRequest.Value=_Value;
        newRequest.completed=false;
        newRequest.noofVoters=0;
    }

    function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender]>0,"You must be contributor.");
        Request storage thisRequest=request[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"You have already voted.");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noofVoters++;
    }

    function makePayment (uint _requestNo) public onlyManger {
        require(raisedAmount>=target);
        Request storage thisRequest=request[_requestNo];
        require(thisRequest.completed==false,"The requesthas been completed.");
        require(thisRequest.noofVoters>totalContribution/2,"Majority does not support.");
        thisRequest.recipient.transfer(thisRequest.Value);
        thisRequest.completed=true;
    }
}
