normalize = function(column) {
	minValue = min(column);
	maxValue = max(column);
	delta = maxValue - minValue;
    for (i in 1 : length(column)) {
    	column[i] = (column[i] - minValue) / delta;
    }
    column
}
