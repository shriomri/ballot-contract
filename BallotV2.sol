pragma solidity 0.8.0;
contract BallotV2 {

  struct Voter {
    uint weight;
    bool voted;
    uint vote;
  }

  struct Proposal {
    uint voteCount;
  }

  address chariperson;
  mapping(address => Voter) voters;
  Proposal[] proposals;

  enum Phase { Init, Regs, Vote, Done }

  Phase public state = Phase.Init;
  
  modifier validatePhase(Phase p) {
    require(state == p);
    _;
  }

  constructor (uint numProposal) public {
    chariperson = msg.sender;
    voters[chariperson].weight = 2;
    for(uint prop=0; prop < numProposal; prop++) {
      proposals.push(Proposal(0));
    }
  }

  //function to change state, can be only done by chariperson
  function changeState(Phase x) public {
    if(msg.sender != chariperson) {
      revert();
    }

    if(x < state) {
      revert();
    }

    state = x;
  }

  function register(address voter) public validatePhase(Phase.Regs) {
    if (msg.sender != chariperson || voters[voter].voted) return;
    voters[voter].weight = 1;
    voters[voter].voted = false;
  }

  function vote(uint toProposal) public validatePhase(Phase.Vote) {
    Voter memory sender = voters[msg.sender];
    if (sender.voted || toProposal > proposals.length) revert();

    sender.voted = true;
    sender.vote  = toProposal;
    proposals[toProposal].voteCount += sender.weight;
  }

  function reqWinner() public validatePhase(Phase.Done) view returns (uint winningProposal) {
    uint winningVoteCount = 0;
    for (uint prop = 0; prop < proposals.length; prop++)
      if (proposals[prop].voteCount > winningVoteCount) {
          winningVoteCount = proposals[prop].voteCount;
          winningProposal = prop;
      }
  }
}