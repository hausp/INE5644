clean_string = function(input) {
	input = gsub("[^A-Za-z]", "", input, perl=T);
	input = as.character(input);
	input = tolower(input);
	input;
}
