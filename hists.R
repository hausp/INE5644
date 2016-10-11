bar = function(data, title) {
	c = table(data);
	barplot(c / sum(c), main=title);
}

# HasName
# hist(unlist(data$HasName));
bar(data$HasName, "HasName");

# Weekday
levels(data$DateTime) = days;
bar(data$DateTime, "Weekday");

# OutcomeType
levels(data$OutcomeType) = outcomeTypes;
levels(data$OutcomeType)[4] = "Ret_owner";
bar(data$OutcomeType, "Outcome Type");

# AnimalType
levels(data$AnimalType) = animalTypes;
bar(data$AnimalType, "Animal Type");

# SexUponOutcome
levels(data$SexUponOutcome) = genders;
levels(data$SexUponOutcome)[4] = "Neut. Male";
levels(data$SexUponOutcome)[5] = "Spayed Fem";
bar(data$SexUponOutcome, "Sex upon outcome");

# DaysUponOutcome
hist(data$DaysUponOutcome);

# IsMixedBreed
bar(unlist(data$IsMixedBreed), "Is mixed breed");

# IsMixedColor
bar(unlist(data$IsMixedColor), "Is mixed color");

