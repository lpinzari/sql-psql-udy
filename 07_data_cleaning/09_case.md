# PostgresQL CASE

CASE statements can be used to perform a variety of cleaning, enrichment, and summarization tasks. Sometimes the data exists and is accurate, but it would be more useful for analysis if values were standardized or grouped into categories.

Nonstandard values occur for a variety of reasons. Values might come from different systems with slightly different lists of choices, system code might have changed, options might have been presented to the customer in different languages, or the customer might have been able to fill out the value rather than pick from a list.

An introduction to the syntax and use of the `CASE` operator is in chapter 04: [case](../04_sql_aggregations/16_case_grouping.md).

Imagine a field containing information about the gender of a person. Values indicat‐ ing a female person exist as “F,” “female,” and “femme.” We can standardize the values like this:

```SQL
    CASE when gender = 'F' then 'Female'
         when gender = 'female' then 'Female'
         when gender = 'femme' then 'Female'
         else gender
         end as gender_cleaned
```

CASE statements can also be used to add categorization or enrichment that does not exist in the original data. As an example, many organizations use a Net Promoter Score, or NPS, to monitor customer sentiment.

NPS surveys ask respondents to rate, on a scale of 0 to 10, how likely they are to recommend a company or product to a friend or colleague. Scores of 0 to 6 are considered detractors, 7 and 8 are passive, and 9 and 10 are promoters. The final score is calculated by subtracting the percentage of detractors from the percentage of promoters. Survey result data sets usually include optional free text comments and are sometimes enriched with information the orga‐ nization knows about the person surveyed. Given a data set of NPS survey responses, the first step is to group the responses into the categories of detractor, passive, and promoter:

```SQL
SELECT response_id,
       likelihood,
       case when likelihood <= 6 then 'Detractor'
            when likelihood <= 8 then 'Passive'
            else 'Promoter'
        end as response_type
 FROM nps_responses;
```

Note that the data type can differ between the field being evaluated and the return data type. In this case, we are checking an integer and returning a string. Listing out all the values with an IN list is also an option. The `IN` operator allows you to specify a list of items rather than having to write an equality for each one separately. It is useful when the input isn’t continuous or when values in order shouldn’t be grouped together:

```SQL
case when likelihood in (0,1,2,3,4,5,6) then 'Detractor'
     when likelihood in (7,8) then 'Passive'
     when likelihood in (9,10) then 'Promoter'
     end as response_type;
```

CASE statements can consider multiple columns and can contain AND/OR logic. They can also be nested, though often this can be avoided with `AND/OR` logic:

```SQL
case when likelihood <= 6 and
          country = 'US' and
          high_value = true then 'US high value detractor'
     when likelihood >= 9
          and (country in ('CA','JP')
               or high_value = true
              )
          then 'some other label'
... end
```

Another useful thing you can do with `CASE` statements is to **create flags** indicating whether a certain value is present, without returning the actual value. This can be useful during profiling for understanding how common the existence of a particular attribute is. Another use for flagging is during preparation of a data set for statistical analysis. In this case, a flag is also known as a dummy variable, taking a value of 0 or 1 and indicating the presence or absence of some qualitative variable. For example, we can create `is_female` and `is_promoter` flags with `CASE` statements on gender and likelihood (to recommend) fields:

```SQL
SELECT customer_id
   ,case when gender = 'F' then 1 else 0 end as is_female
   ,case when likelihood in (9,10) then 1 else 0 end as is_promoter
   FROM ... ;
```

If you are working with a data set that has multiple rows per entity, such as with line items in an order, you can flatten the data with a CASE statement wrapped in an aggregate and turn it into a flag at the same time by using 1 and 0 as the return value. We saw previously that a `BOOLEAN` data type is often used to create flags (fields that represent the presence or absence of some attribute). Here, 1 is substituted for TRUE and 0 is substituted for FALSE so that a max aggregation can be applied. The way this works is that for each customer, the CASE statement returns 1 for any row with a fruit type of “apple.” Then max is evaluated and will return the largest value from any of the rows. As long as a customer bought an apple at least once, the flag will be 1; if not, it will be 0:

```SQL
SELECT customer_id,
       max(case when fruit = 'apple' then 1 else 0
       end) as bought_apples,
       max(case when fruit = 'orange' then 1 else 0
       end) as bought_oranges
 FROM ...
GROUP BY 1 ;
```

You can also construct more complex conditions for flags, such as requiring a threshold or amount of something before labeling with a value of 1:

```SQL
SELECT customer_id,
       max(case when fruit = 'apple' and quantity > 5 then 1 else 0
       end) as loves_apples,
       max(case when fruit = 'orange' and quantity > 5 then 1 else 0
       end) as loves_oranges
  FROM ...
 GROUP BY 1 ;
```

CASE statements are powerful, and as we saw, they can be used to clean, enrich, and flag or add dummy variables to data sets. In the next section, we’ll look at some special functions related to CASE statements that handle null values specifically.

## Alternatives for Cleaning Data

Cleaning or enriching data with a CASE statement works well as long as there is a relatively short list of variations, you can find them all in the data, and the list of val‐ ues isn’t expected to change. For longer lists and ones that change frequently, a lookup table can be a better option. A lookup table exists in the database and is either static or populated with code that checks for new values periodically. The query will JOIN to the lookup table to get the cleaned data. In this way, the cleaned values can be maintained outside your code and used by many queries, without your having to worry about maintaining consistency between them. An example of this might be a lookup table that maps state abbreviations to full state names. In my own work, I often start with a CASE statement and create a lookup table only after the list becomes unruly, or once it’s clear that my team or I will need to use this cleaning step repeatedly.
Of course, it’s worth investigating whether the data can be cleaned upstream. I once started with a CASE statement of 5 or so lines that grew to 10 lines and then eventu‐ ally to more than 100 lines, at which point the list was unruly and difficult to main‐ tain. The insights were valuable enough that I was able to convince engineers to change the tracking code and send the meaningful categorizations in the data stream in the first place.
