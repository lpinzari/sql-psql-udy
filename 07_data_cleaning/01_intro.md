# Data Cleaning

Data cleaning is the set of activities and techniques that identify and fix problems with the data in a dataset. In general, we want **to identify and get rid of ‘bad’ or ‘wrong’ data**. However, it may be very hard to identify such data, depending on the `domain` and `data type`:

- For (`finite`) **enumerated types**, a simple membership test is needed. For instance, `months of the year` can be expressed as **integers** (in which case only values between `1` and `12` are allowed) or as **strings** (in which case only value “`January`,” . . . , “`December`” are allowed). For this types, distinguishing ‘good’ from ‘bad’ data is usually not hard, unless some **non-standard encoding** is used (for instance, using ‘`A`,’ ‘`B`,’ . . . for `months of year`).
- For **pattern-based domains** (like `telephone numbers` or `IP addresses`), a test can rule out values that do not fit the pattern. However, **when a value fails to follow the expected pattern**, it may be a case of `bad formatting`; **such values must be rewritten, not ignored, or deleted**. Telling badly formatted from plain wrong values can become quite hard.
- In **open-ended domains** (as most measurements are), what is a ‘bad’ or ‘wrong’ value is not clear cut. An in-depth analysis of the existing values and domain information have to be combined to infer the range of possible and/or likely values, and even this knowledge may not be enough to tell ‘good’ from ‘bad’ values in many cases.

In general, the problems attacked at this stage may be quite diverse and have different causes; hence, data cleaning is a complex and messy activity. Different authors differ in what should be considered at this stage; however, there are some basic issues that most everyone agrees should be addressed at this point, including

- **Proper data**. For starters, we need to make sure that values are of the right kind and are in a proper format. When **we load data into the database we must make sure that values are read correctly**.
  - In spite of our efforts, we may end up with `numbers` **that are read as** `strings` (because of commas in the values, or other problems), or `dates` that **are not recognized as such and also read as** `plain strings`.
  - Even if the **data is read correctly**, the **format may be not appropriate for analysis**. Hence,**making sure data is properly represented is usually a first step before any other tasks**.
- **Missing values**. In the context of tabular data, this means records that are `missing some attribute values`, not missing records. The issues of whether the data records we have in a dataset are all those that we should have and whether the `dataset is a representative sample of the underlying population are very important but different and treated in detail in Statistics`. Missing values refers exclusively to records that are present in the dataset but are not complete—in other words, **missing attribute values**. **Detection** `may be tricky when the absence of a value is marked in an ad-hoc manner in a dataset`, but the real problem here is **what to do with the incomplete records**.
  - The general strategies are to
    - **ignore** (delete) the affected data (either the attribute or the record),
    - or to **predict** (also called impute) the absent values from other values of the same attribute or from value of other attributes. The exact approach, as we will see, depends heavily on the context.
- **Outliers**. Outliers are data values that have characteristics that are very different from the characteristics of most other data values in the same attribute. **Detecting outliers** is extremely tricky because this is a vague, context-dependent concept: **it is often unclear whether an outlier is the result of an error or problem, or a legitimate but extreme value**.
  - For instance, consider a person dataset with attribute height: when measured in feet, usually the value is in the 4.5 to 6.5 range; anyone below or above is considered very short or very tall. But certainly there are people in the world who are very short (and very tall). And, of course, we would expect different heights if we are measuring a random group of people or basketball players. In a sense, **an outlier is a value that is not normal, but what constitutes normal is difficult to pin down**. Thus, the challenge with outliers is finding (defining) them. **Once located, they can be treated like missing values**.
- **Duplicate data**. **It is assumed that each data record in a dataset refers to a different entity, event, or observation in the real world**. However, `sometimes we may have a dataset where two different records are actually about the same entity` (or event, or observation), hence being duplicates of each other. In many situations, this is considered undesirable as **it may bias the data**. Thus, **detecting duplicates and getting rid of them can be considered a way to improve the quality of the data**. Unfortunately, this is another very difficult problem, since most of the time all we have to work with is the dataset itself. The simpler case where two records have exactly the same values for all attributes is easy to detect, but in many cases duplicate records may contain attributes with similar, but not exactly equal, values due to a variety of causes: `rounding errors`, `limits in precision in measurement`, `etc`. This situation make duplicate detection much harder. The special case of data integration (also called data fusion), where two or more datasets must be combined to create a single dataset, usually brings the problem of duplicate detection in its most difficult form.

## ATTRIBUTE TRANSFORMATION

In general, **attribute transformations** are operations that **transform the values of an attribute to a certain format or range**. These are needed to make sure that data values are understandable to database functions, so that data can be manipulated in meaningful ways. Many times it may be necessary to transform data before any other analysis, even EDA, can begin.

Because these transformations are highly dependent on the data type, they are discussed separately next.

In this lesson, you will be learning a number of techniques to

- **Clean and re-structure messy data**.
- **Convert columns to different data types**.
- **Tricks for manipulating** `NULLs`.

This will give you a robust toolkit to get from raw data to clean data that's useful for analysis.
