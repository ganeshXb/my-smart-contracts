// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

contract TodoList {
    uint public taskCount = 0;
    string public name;

    constructor() public{
        name = "Ganesh's Todo";
	    createTask("Start R&D on News Network");
    }

    struct Task{
        uint id;
        string taskContent;
        bool completed;
    }

    event TaskCreated(
        uint id,
        string taskContent,
        bool completed
    );

    event TaskCompleted(
        uint id,
        bool completed
    );

    mapping (uint => Task) public tasks;

    function createTask (string memory _taskContent) public {
        taskCount ++;
        tasks[taskCount] = Task(taskCount, _taskContent, false);
        emit TaskCreated(taskCount, _taskContent, false);
    }

    function completeTask(uint _id) public {
        Task memory _task = tasks[_id];
        _task.completed = !_task.completed;
        tasks[_id] = _task;
        emit TaskCompleted(_id, _task.completed);
    }

}
