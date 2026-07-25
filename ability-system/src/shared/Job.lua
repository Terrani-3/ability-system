--// Module
local Job = {}
Job.__index = Job

function Job.new()
	return setmetatable({ _tasks = {} }, Job)
end

function Job:Task(task: RBXScriptConnection | Instance | (() -> ()))
	table.insert(self._tasks, task)
	return task
end

function Job:Destroy()
	for _, task in self._tasks do
		if typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif typeof(task) == "Instance" then
			task:Destroy()
		elseif type(task) == "function" then
			task()
		end
	end

	table.clear(self._tasks)
end

return Job
