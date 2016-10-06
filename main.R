
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


# ------------------------- Useless field removal -------------------------
# data$outcomeSubtype = NULL;


# ------------------------- Category -> Number -------------------------
data$OutcomeType = numerize(data$OutcomeType, outcomeTypes, 0:length(outcomeTypes));
data$AnimalType = numerize(data$AnimalType, animalTypes, 0:length(animalTypes));
data$SexuponOutcome = numerize(data$SexuponOutcome, genders, 0:length(genders));


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


# ------------------------- DateTime -> timestamp -------------------------
data$DateTime = lapply(data$DateTime, {function(str) {
	as.numeric(as.POSIXct(str));
}});


# ----------------------- Name analysis (HasName) -----------------------
data$Name = lapply(data$Name, {function(str) {
	as.integer(str != "");
}});

data = rename(data, "Name", "HasName");


# ------------------------- Color analysis -------------------------
placeholder = "ZZZZ";

pairs = lapply(data$Color, {function(str) {
	p = strsplit(as.character(str), "/");
	if (is.na(p[[1]][2]))
		p[[1]][2] = placeholder;
	p;
}});

data$Color = lapply(pairs, {function(pair) {
	ifelse(pair[[1]][1] < pair[[1]][2],
		pair[[1]][1],
		pair[[1]][2])
}});

data$Color2 = lapply(pairs, {function(pair) {
	ifelse(pair[[1]][1] < pair[[1]][2],
		pair[[1]][2],
		pair[[1]][1])
}});

data = rename(data, "Color", "Color1");


# ------------------------- IsMixedColor -------------------------
data$IsMixedColor = lapply(pairs, {function(pair) {
	ifelse(pair[[1]][2] == placeholder, 0, 1);
}});


# ---------------------- Breed analysis (IsMixedBreed) ----------------------
data$Breed = lapply(data$Breed, {function(str) {
	as.integer(grepl("Mix|/", str));
}});

data = rename(data, "Breed", "IsMixedBreed");


# ------------------------- Null treatment -------------------------
data$SexUponOutcome[sapply(data$SexUponOutcome, is.na)] = 0;
data$DaysUponOutcome[sapply(data$DaysUponOutcome, is.null)] = 0;
data$Color2[sapply(data$Color2, {function(str) {
	str == placeholder;
}})] = "";


# ------------------------- Normalization -------------------------
# data$DateTime = normalize(unlist(data$DateTime));
# data$OutcomeType = normalize(as.numeric(data$OutcomeType));
# data$SexUponOutcome = normalize(as.numeric(data$SexUponOutcome));
data$DaysUponOutcome = normalize(unlist(data$DaysUponOutcome));


# Save
write.csv(as.matrix(data), targetFile);
