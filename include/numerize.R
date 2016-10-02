numerize = function(column, sourceValues, targetValues) {
    result = as.vector(column);
    for (i in 1 : length(result)) {
        value = result[i];
        index = match(c(value), sourceValues);
        result[i] = targetValues[index];
    }
    as.factor(result);
}
