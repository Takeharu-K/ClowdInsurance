pragma solidity >= 0.5.9 <0.6.0;

contract clowdInsurance{
    
    //コントラクト残高
    uint public amount;
    
    //保険の構造体
    struct Insurance{
        uint deposit;
        uint payment;
        uint startedFrom;
        uint finishedAt;
        uint voteStartedFrom;
        bool closed;
        bool challenged;
        address[] noAddress;
        address[] yesAddress;
        uint noCount;
        uint yesCount;
    }
    
    //被保険者アドレス -> 保険ID -> 保険構造体
    mapping(address => mapping(uint => Insurance)) insuranceOf; 
    
    //投票者アドレス -> 獲得報酬
    mapping(address => uint) voterRefundAmount;
    
    //オーナーアドレス
    address public owner;
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    //投票に必要なデポジット(0.01ETH)
    uint public voteFee = 0.01 ether;
    
    //チャレンジ期間
    uint public challengePeriod = 2 minutes;
    
    constructor() public {
        owner = msg.sender;
    }
    
    //被保険者の保険を作成する
    function makeInsurance(uint deposit, uint payment, uint id, uint startedFrom, uint finishedAt) payable public {
        require(msg.value >= deposit);
        require(startedFrom < finishedAt);
        amount += msg.value;
        
        Insurance storage insurance = insuranceOf[msg.sender][id];
        insurance.deposit = deposit;
        insurance.payment = payment;
        insurance.startedFrom = startedFrom;
        insurance.finishedAt = finishedAt;
        insurance.closed = false;
        insurance.challenged = false;
    }
    
    //challengeリクエスト
    function challengeRequest(address applicant, uint id) public {
        require(msg.sender == applicant);
        require(insuranceOf[applicant][id].challenged == false);
        require(insuranceOf[applicant][id].finishedAt > now);
        
        insuranceOf[applicant][id].challenged = true;
        insuranceOf[applicant][id].voteStartedFrom = now;
    }
    
    //Yes投票
    function voteYesTo(address payable applicant, uint id) payable public {
        require(insuranceOf[applicant][id].challenged == true);
        require(insuranceOf[applicant][id].closed != true);
        require(msg.value >= voteFee);
        require(insuranceOf[applicant][id].voteStartedFrom + challengePeriod > now);
        require(!isExist(applicant, id, msg.sender));

        amount += msg.value;
        
        Insurance storage insurance = insuranceOf[applicant][id];
        insurance.yesAddress.push(msg.sender);
        insurance.yesCount++;

    }

    //No投票
    function voteNoTo(address payable applicant, uint id) payable public {
        require(insuranceOf[applicant][id].challenged == true);
        require(insuranceOf[applicant][id].closed != true);
        require(msg.value >= voteFee);
        require(insuranceOf[applicant][id].voteStartedFrom + challengePeriod > now);
        require(!isExist(applicant, id, msg.sender));

        amount += msg.value;
        
        Insurance storage insurance = insuranceOf[applicant][id];
        insurance.noAddress.push(msg.sender);
        insurance.noCount++;

    }
    
    //結果確認と保険金払い戻し(Yesが過半数を超えていれば)
    function checkOutApplicant(address payable applicant, uint id) payable public {
        require(msg.sender == applicant);
        require(insuranceOf[applicant][id].voteStartedFrom + challengePeriod < now, 'Not finished yet');
        require(insuranceOf[applicant][id].closed != true);
        
        Insurance storage insurance = insuranceOf[applicant][id];
        
        insurance.closed = true;
        
        if(insurance.yesCount > insurance.noCount){
            challengeSuccess(applicant, id);
        }else if(insurance.yesCount == insurance.noCount){
            challengeNeutral(applicant, id);
        }else{
            challengeFailed(applicant, id);
        }
    }
    
    //challenge成功
    //被保険者に保険金
    //Yes投票者にデポジットと報酬
    function challengeSuccess(address payable applicant, uint id) internal {
        require(amount >= insuranceOf[applicant][id].payment, 'Not enough ETH of contract. Cannot pay');
        require(amount > (insuranceOf[applicant][id].yesAddress.length * voteFee), 'Not enough ETH of contract. Cannot pay');

        Insurance storage insurance = insuranceOf[applicant][id];
        
        applicant.transfer(insurance.payment * 9 / 10);
        amount -= insurance.payment * 9 / 10;
        
        uint voterReward = insurance.payment / 10 / insurance.yesAddress.length;
        for(uint8 i=0; i < insurance.yesAddress.length; i++){
            voterRefundAmount[insurance.yesAddress[i]] = voteFee + voterReward; 
        }
    }

    //challenge失敗
    //被保険者はデポジット喪失
    //No投票者にデポジットと報酬
    function challengeFailed(address payable applicant, uint id) internal {
        require(amount >= insuranceOf[applicant][id].payment / 10, 'Not enough ETH of contract. Cannot pay');
        require(amount > (insuranceOf[applicant][id].noAddress.length * voteFee), 'Not enough ETH of contract. Cannot pay');
        
        Insurance storage insurance = insuranceOf[applicant][id];
        
        uint voterReward = insurance.payment / 10 / insurance.noAddress.length;
        for(uint8 i=0; i < insurance.noAddress.length; i++){
            voterRefundAmount[insurance.noAddress[i]] = voteFee + voterReward;
        }
    }
    
    //challenge中立
    //被保険者はデポジット喪失
    //投票者全員のデポジットが返還
    function challengeNeutral(address applicant, uint id) internal {
        require(amount > (insuranceOf[applicant][id].noAddress.length + insuranceOf[applicant][id].yesAddress.length)*voteFee, 'Not enough ETH of contract. Cannot pay');
        
        Insurance storage insurance = insuranceOf[applicant][id];
        
        for(uint8 i=0; i < insurance.yesAddress.length; i++){
            voterRefundAmount[insurance.yesAddress[i]] += voteFee;
        }
        
        for(uint8 i=0; i < insurance.noAddress.length; i++){
            voterRefundAmount[insurance.noAddress[i]] += voteFee;
        }
    }

    //投票者が報酬を引き出す
    function withdrawVoter(address applicant, uint id) payable public {
        require(insuranceOf[applicant][id].closed == true);
        require(isExist(applicant, id, msg.sender),'You did not vote to this insurance');
        
        msg.sender.transfer(voterRefundAmount[msg.sender]);
        amount -= voterRefundAmount[msg.sender];
        voterRefundAmount[msg.sender] = 0;
    }
    
    //投票者の存在確認
    function isExist(address applicant, uint id, address voter) internal view returns (bool) {
        Insurance storage insurance = insuranceOf[applicant][id];
        
        for(uint i=0; i < insurance.yesAddress.length; i++){
            if(insurance.yesAddress[i] == voter){
                return true;
            }
        }
        for(uint i=0; i < insurance.noAddress.length; i++){
            if(insurance.noAddress[i] == voter){
                return true;
            }
        }
        
        return false;
    }
}