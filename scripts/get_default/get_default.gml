function get_default(name, fallback = -1){
	var value = style[$ name];
	
	if (value == undefined) return fallback;
	return value;
}

function get_overwrite(){
	var fallback = argument[argument_count - 1];
	
	for(var i = 0; i < argument_count - 1; i++){
		var name = argument[i];
		var value = style[$ name];
		
		if (value != undefined) return value;
	}
	
	return fallback;
}

function get_default_struct(struct, name, fallback = -1){
	if (style[$ struct] == undefined) return fallback;
	
	var value = style[$ struct][$ name];
	if (value == undefined) return fallback;
	return value;
}

function get_overwrite_struct(){
	var struct = argument[0];
	var fallback = argument[argument_count - 1];
	
	if (style[$ struct] == undefined) return fallback;
	
	for(var i = 1; i < argument_count - 1; i++){
		var name = argument[i];
		var value = style[$ struct][$ name];
		
		if (value != undefined) return value;
	}
	
	return fallback;
}