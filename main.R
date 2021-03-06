source(file="include/normalize.R")
source(file="include/numerize.R")
source(file="include/rename.R")
source(file="include/clean_string.R")

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

days = c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday");

# ------------------------- Useless field removal -------------------------
data$AnimalID = NULL;


# ------------------------- Category -> Number -------------------------
# data$OutcomeType = numerize(data$OutcomeType, outcomeTypes, 0:length(outcomeTypes));
# data$AnimalType = numerize(data$AnimalType, animalTypes, 0:length(animalTypes));
# data$SexuponOutcome = numerize(data$SexuponOutcome, genders, 0:length(genders));
data$SexuponOutcome = lapply(data$SexuponOutcome, {function(str) {
	str = clean_string(str);
}});


# ------------------- SexuponOutcome -> SexUponOutcome -------------------
data = rename(data, "SexuponOutcome", "SexUponOutcome");


# ------------------- AgeuponOutcome -> DaysUponOutcome -------------------
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

data = rename(data, "AgeuponOutcome", "DaysUponOutcome");


# ------------------------- timestamp -> weekday -------------------------
data$DateTime = lapply(data$DateTime, {function(str) {
	# as.numeric(as.POSIXct(str)$wday);
	weekdays(as.Date(str));
}});

data$DateTime = numerize(unlist(data$DateTime), days, 0:length(days));
data = rename(data, "DateTime", "Weekday");

# ----------------------- Name analysis (HasName) -----------------------
data$Name = lapply(data$Name, {function(str) {
	ifelse(str != "", "true", "false");
}});

data = rename(data, "Name", "HasName");


# ------------------------- Color analysis -------------------------
placeholder = "ZZZZ";
clean_placeholder = tolower(placeholder);

pairs = lapply(data$Color, {function(str) {
	p = strsplit(as.character(str), "/");
	if (is.na(p[[1]][2]))
		p[[1]][2] = placeholder;
	p;
}});

data$Color = lapply(pairs, {function(pair) {
	first = clean_string(pair[[1]][1]);
	second = clean_string(pair[[1]][2]);
	ifelse(first < second, first, second);
}});

data$Color2 = lapply(pairs, {function(pair) {
	first = clean_string(pair[[1]][1]);
	second = clean_string(pair[[1]][2]);
	ifelse(first < second, second, first);
}});

data = rename(data, "Color", "Color1");


# ------------------------- IsMixedColor -------------------------
data$IsMixedColor = lapply(pairs, {function(pair) {
	ifelse(pair[[1]][2] == placeholder, "false", "true");
}});


# ---------------------- Breed analysis (IsMixedBreed) ----------------------
data$Breed = lapply(data$Breed, {function(str) {
	if (grepl("Mix|/", str)) {
		"mixed";
	} else {
		str = clean_string(str);
	}
}});

#data = rename(data, "Breed", "IsMixedBreed");


# ------------------------- Null treatment -------------------------
data$SexUponOutcome[sapply(data$SexUponOutcome, is.na)] = 0;
data$DaysUponOutcome[sapply(data$DaysUponOutcome, is.null)] = 0;
data$Color2[sapply(data$Color2, {function(str) {
	str == clean_placeholder;
}})] = "";


# ------------------------- Normalization -------------------------
# data$DateTime = normalize(unlist(data$DateTime));
# data$OutcomeType = normalize(as.numeric(data$OutcomeType));
# data$SexUponOutcome = normalize(as.numeric(data$SexUponOutcome));
# data$DaysUponOutcome = normalize(unlist(data$DaysUponOutcome));


# Save
write.csv(as.matrix(data), targetFile);
