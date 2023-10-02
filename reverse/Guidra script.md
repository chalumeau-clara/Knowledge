
Print all function call by a function

def get_callee(addr):
	func = getFunctionAt(toAddr(addr))
	return func.getCalledFunctions(guidra.utils.task.TaskMonitor.DUMMY)

