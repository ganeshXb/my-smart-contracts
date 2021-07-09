const { assert } = require("chai");

const TodoList = artifacts.require("./TodoList.sol");

contract('TodoList', (address) => {
    let todoList;
    before(async () => {
        todoList = await TodoList.deployed();
    });

    describe('Deployment check', async () => {
        // test case to check successful deployment
        it('Check for successful deployment', async () => {
            const address = await todoList.address
            assert.notEqual(address, 0x0, "Invalid address");
            assert.notEqual(address, '', "Invalid Empty address");
            assert.notEqual(address, null, "Invalid Null address");
            assert.notEqual(address, undefined, "Invalid undefined address");
        });

        // test case to check success of deployment
        it('Check success of deployment', async () => {
            const name = await todoList.name()
            assert.equal(name, "Ganesh's Todo", "Successfully deployed");
        });
    });
    
    describe('Functionality check', async () => {
        // test case to check successful addition of tasks
        it('Check successful addition of tasks to the network', async () => {
            const taskcount = await todoList.taskCount();
            const task = await todoList.tasks(taskcount);
            assert.equal(task.id.toNumber(), taskcount.toNumber(), "Valid Id");
            assert.equal(task.taskContent, "Start R&D on News Network", "Valid task content");
            assert.equal(task.completed, false, "Valid completion status");
            assert.equal(taskcount.toNumber(), 1, "Valid task count");
        });

        // test case to check successful creation of tasks
        it('Check successfull creation of tasks', async () => {
            const result = await todoList.createTask('Prep for Auth module build');
            const taskcount = await todoList.taskCount();
            assert.equal(taskcount, 2, "Valid task count");

            const event = result.logs[0].args;
            assert.equal(event.id.toNumber(), 2, "Valid Id");
            assert.equal(event.taskContent, 'Prep for Auth module build', "Valid task content");
            assert.equal(event.completed, false, "Valid completion status");
        });

        // test case to verify task compeletion
        it('Check successful task completion', async () => {
            const result = await todoList.completeTask(1);
            const task = await todoList.tasks(1);
            assert.equal(task.completed, true, "Valid completion status");

            const event = result.logs[0].args;
            assert.equal(event.id.toNumber(), 1, "Valid Id");
            assert.equal(event.completed, true, "Valid completion status");    
        });
    });
});