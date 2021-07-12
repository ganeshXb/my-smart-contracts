// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

contract Election{
    uint public candidateCount = 0;
    string public name;

    constructor() public {
        name = "Ganesh's Election Dapp";
        addCandidate('Mr.X');
        addCandidate('Mr.Y');
        addCandidate('Mr.Z');
    }

    struct Candidate{
        uint id;
        string name;
        uint voteCount;
    }

    // key-value type to store the data
    mapping(uint => Candidate) public candidates;

    mapping(address => bool) public voters;

    event voted( uint id, string name, uint voteCount, bool voted );

    function addCandidate(string memory _name) public {
        //increment count when a new candidate is added
        candidateCount ++;
        // store new candidate details in the candidate mapping
        candidates[candidateCount] = Candidate(candidateCount, _name, 0);
    }

    function casteVote(uint _candidateId) public {
        // check if the voters haven't casted their votes already
        require(!voters[msg.sender]);

        // check if the candidate Id is valid
        require(_candidateId >0 && _candidateId < candidateCount);

        // Caste vote -> set voter as true
        voters[msg.sender] = true;

        //increase the vote count of the candidate
        candidates[_candidateId].voteCount ++;
        
        //emit event on successful casting of vote
        emit voted(_candidateId, candidates[_candidateId].name, candidates[_candidateId].voteCount, voters[msg.sender]);
    }
}