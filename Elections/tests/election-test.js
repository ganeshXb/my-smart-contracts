const { assert } = require("chai");

const Election = artifacts.require("./Election.sol");

contract('Election', (accounts) => {
    let election;

    before( async () => {
        election = await Election.deployed();
    });

    describe('Test Deployment', async () => {
        // test case to check the successful deployement
        it('Check for successful deployment', async () => {
            const address = await election.address;
            assert.notEqual(address, 0x0, "Invalid address");
            assert.notEqual(address, '', "Invalid address");
            assert.notEqual(address, null, "Invalid address");
            assert.notEqual(address, undefined, "Invalid address");
        });

        // test case to check for success of deployment
        it('Check for success of deployment', async () => {
            const name = await election.name();
            assert.equal(name, "Ganesh's Election Dapp", "Successfully deployed");
        });
    });

    describe('Test Fuctionality', async () => {
        // test case to check the initialisation of candidates
        it('Check for Initialisation with 3 Candidates', async () => {
            const count = await election.candidateCount();
            assert.equal(count, 3, "Valid candidate count");
        });

        // test case to check candidate details
        it('Check for the Valid candidate details', async () => {
            const candidate1 = await election.candidates(1);
            assert.equal(candidate1[0], 1, "Valid Id");
            assert.equal(candidate1[1],"Mr.X", "Valid name");
            assert.equal(candidate1[2], 0, "Valid vote count ");
            
            const candidate2 = await election.candidates(2);
            assert.equal(candidate2[0], 2, "Valid Id");
            assert.equal(candidate2[1], "Mr.Y", "Valid name");
            assert.equal(candidate2[2], 0, "Valid vote count ");

            const candidate3 = await election.candidates(3);
            assert.equal(candidate3[0], 3, "Valid Id");
            assert.equal(candidate3[1], "Mr.Z", "Valid name");
            assert.equal(candidate3[2], 0, "Valid vote count ");
        });

        // test case to check casting of votes
        it('Check if voter can cast a vote', async () => {
            const candidateId = 2;

            // check vote status before vasting votes
            const _voted = await election.voters(accounts[0]);
            assert.equal(_voted, false, "Valid vote status");

            const result = await election.casteVote(candidateId, {from: accounts[0]});
            const event = result.logs[0].args;
            assert.equal(event.id.toNumber(), 2, "Valid candidate Id");
            assert.equal(event.name, "Mr.Y", "Valid name");
            assert.equal(event.voteCount.toNumber(), 1, "Valid vote count");
            assert.equal(event.voted, true, "Valid vote status");

            // check vote status after casting votes
            const voted = await election.voters(accounts[0]);
            assert.equal(voted, true, "Valid vote status"); 
        });

        // test case to check avoiding of casting votes to invalid candidates
        it('Check if vote is not casted to invalid candidate ', async () => {
            // use try catch block to catch exception - 'VM Exception while processing transaction: revert'
            // This error happens when a function call jumps out of bounds 
            // This is done to punish the caller for attempting to do something they weren't supposed to do
            try {
                _candidateId = 10;
                const _result = await election.casteVote(_candidateId, {from: accounts[1]});
                const _event = _result.logs[0].args;
                
                // check if vote is casted to the candidate
                assert.equal(_event.voteCount.toNumber(), 1, "Vote casted to valid candidate");

                // check if vote isn't casted to any other candidate 
                const _candidate2 = await election.candidates(2);
                assert.equal(_candidate2[2].toNumber(), 0, "Vote isn't casted to invalid candidate");
                const _candidate3 = await election.candidates(3);
                assert.equal(_candidate3[2].toNumber(), 0, "Vote isn't casted to invalid candidate");

            } catch (error) {
                assert(error.message.indexOf('revert') >= 0, "error message must contain revert");
            }   
        });

        // test case to check avoiding of double voting
        it('Check to prevent double voting problem', async () => {
            // use try catch block to catch exception - 'VM Exception while processing transaction: revert'
            try {
                const _candidateId = 1;

                // caste first vote
                const _result = await election.casteVote(_candidateId, {from: accounts[2]});
                const _event = _result.logs[0].args;
                assert.equal(_event.voteCount.toNumber(), 1, "Valid vote count");

                //caste another vote
                const _resultRe = await election.casteVote(_candidateId, {from: accounts[2]});
                const _eventRe = _resultRe.logs[0].args;

                // Given voter already voted once, (to same candidate)
                // check if the voter can't cast another vote to same candidate 
                assert.equal(_eventRe.voteCount.toNumber(), 1, "Candidate didn't recieve any votes");

                // Given voter already voted once (to different candidate)
                // check if the voter can't cast another vote to other candidates
                const _candidate2 = await election.candidates(2);
                assert.equal(_candidate2[2].toNumber(), 0, "Vote isn't casted to invalid candidate");
                const _candidate3 = await election.candidates(3);
                assert.equal(_candidate3[2].toNumber(), 0, "Vote isn't casted to invalid candidate");
            } catch (error) {
                assert(error.message.indexOf('revert') >= 0, "error message must contain revert");
            }
        });
    });
});

// My Test Results
/*

    ganesh@mac elections % truffle test ./test/Election-test.js
    Using network 'development'.


    Compiling your contracts...
    ===========================
    > Everything is up to date, there is nothing to compile.



    Contract: Election
        Test Deployment
        ✓ Check for successful deployment
        ✓ Check for success of deployment (43ms)
        Test Fuctionality
        ✓ Check for Initialisation with 3 Candidates (40ms)
        ✓ Check for the Valid candidate details (150ms)
        ✓ Check if voter can cast a vote (247ms)
        ✓ Check if vote is not casted to invalid candidate  (643ms)
        ✓ Check to prevent double voting problem (207ms)

    7 passing (2s)
*/