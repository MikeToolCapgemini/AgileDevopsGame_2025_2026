# rpc_incoming_logger.gd
extends Node

# memory log of incoming RPCs while backgrounded
var rpc_log := []
var is_background := false

func _ready():
	print("RPC Incoming Logger ready")

# track tab focus
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		is_background = true
		rpc_log.clear() # start fresh when leaving focus
		print("Client backgrounded, logging RPCs...")
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		is_background = false
		print("Client refocused, dumping RPC log...")
		dump_rpc_log()

# call this in any networked node's _rpc call
func log_rpc(node: Node, method: String, args: Array):
	if is_background:
		rpc_log.append({
			"node": node.name,
			"method": method,
			"args": args
		})

# output log after refocus (or write to file)
func dump_rpc_log():
	if rpc_log.size() == 0:
		print("No RPCs received while backgrounded.")
		return

	print("--- RPCs received while backgrounded ---")
	var counter = {}
	for entry in rpc_log:
		var key = entry.method
		counter[key] = counter.get(key, 0) + 1

	for method_name in counter.keys():
		print(method_name, "called", counter[method_name], "times")
