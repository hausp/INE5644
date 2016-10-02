
source(file="include/normalize.R")
source(file="include/numerize.R")
source(file="include/rename.R")

sourceFile = "csv/train.csv";
targetFile = "csv/refined_train.csv";

data = read.csv(sourceFile);

# ------------------------- Possible label values -------------------------
outcomeTypes = c("Adoption", "Died", "Euthanasia", "Return_to_owner", "Transfer");

# TODO: do we need to numerize outcome subtypes?
# outcomeSubtypes = 

animalTypes = c("Cat", "Dog");

# TODO: there's one animal with empty SexuponOutcome, should we discard it?
genders = c("Unknown",
			"Intact Female",
			"Intact Male",
			"Neutered Male",
			"Spayed Female");


# ------------------------- Category -> Number -------------------------
data$OutcomeType = numerize(data$OutcomeType, outcomeTypes, 0:length(outcomeTypes));
data$AnimalType = numerize(data$AnimalType, animalTypes, 0:length(animalTypes));
data$SexuponOutcome = numerize(data$SexuponOutcome, genders, 0:length(genders));


# ------------------- AgeuponOutcome -> DaysuponOutcome -------------------
ages = data$AgeuponOutcome;
# ages = sub("years", "* 365", ages, perl=T);
ages = sub("year", "* 365", ages, perl=T);
# ages = sub("months", "* 365", ages, perl=T);
ages = sub("month", "* 30", ages, perl=T);
ages = sub("week", "* 7", ages, perl=T);
ages = sub("day", "", ages, perl=T);
ages = sub("s", "", ages, perl=T);
ages = lapply(ages, {function(str) {
	eval(parse(text=str));
}});
data$AgeuponOutcome = ages;

data = rename(data, "AgeuponOutcome", "DaysuponOutcome");

# ------------------------- Null treatment -------------------------
data$SexuponOutcome[sapply(data$SexuponOutcome, is.na)] = 0;
data$DaysuponOutcome[sapply(data$DaysuponOutcome, is.null)] = 0;


# ------------------------- DateTime -> timestamp -------------------------
data$DateTime = lapply(data$DateTime, {function(str) {
	as.numeric(as.POSIXct(str));
}});


# ------------------------- Normalization -------------------------
data$DateTime = normalize(unlist(data$DateTime));
data$OutcomeType = normalize(as.numeric(data$OutcomeType));
data$SexuponOutcome = normalize(as.numeric(data$SexuponOutcome));
data$DaysuponOutcome = normalize(unlist(data$DaysuponOutcome));


# Save
write.csv(as.matrix(data), targetFile);
