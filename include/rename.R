rename = function(data, oldName, newName) {
	colnames(data)[names(data) == oldName] = newName;
	data;
}
