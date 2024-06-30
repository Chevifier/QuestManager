class_name QMCallableStep extends QMQuestStep


func _ready() -> void:
	call_function(step.callable,step.params["funcparams"])

func call_function(autoloadfunction:String,params:Array) -> void:
	#split function from autoload script name
	var autofuncsplit = autoloadfunction.split(".")
	var singleton_name = autofuncsplit[0]
	var function = autofuncsplit[1]
	#get only function name without ()
	var callable = function.split("(")[0]
	#Autoload name needs to be the same as script or use name of Node instead.
	assert(Engine.has_singleton(singleton_name)==false, "Singleton %s Not Loaded or invalid" % singleton_name)
	var auto_load = get_tree().root.get_node(singleton_name)
	#if array has values pass array otherwise call function normally
	if params.size()>0:
		auto_load.call(callable,params)
	else:
		auto_load.call(callable)
		
