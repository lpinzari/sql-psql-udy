# Table of Contents

This file list the chapters and paragraphs of this book.

Extract of CookBook SQL 2nd edition.

# Chapter 0: DATA

[It](./00_data) contains the instructions to create the database and load the data used in this book.

|file|description|
|:-:|:----------:|
|[01_cbook_db](./00_data/01_cbook_db.md)|create the cookbook database|

# Chapter 1: Retrieving Records

[Chapter 1](./01_retrieving_records) focuses on basic SELECT statements.

|file|description|
|:---:|:--------:|
|[01](./01_retrieving_records/01_retrieving_all_rows_and_columns_from_a_table.md)|Retrieving all rows and columns from a table|
|[02](./01_retrieving_records/02_retrieving_a_subset_of_rows_from_a_table.md)|Retrieving a Subset of Rows from a Table Problem|
|[03](./01_retrieving_records/03_finding_rows_that_satisfy_multiple_conditions.md)|Finding Rows That Satisfy Multiple Conditions Problem|
|[04](./01_retrieving_records/04_retrieving_a_subset_of_columns_from_a_table.md)|Retrieving a Subset of Columns from a Table Problem|
|[05](./01_retrieving_records/05_providing_meaningful_names_to_columns.md)|Providing Meaningful Names for Columns Problem|
|[06](./01_retrieving_records/06_referencing_alias_column_in_where_clause.md)|Referencing an Aliased Column in the WHERE Clause Problem|
|[07](./01_retrieving_records/07_concatenating_column_values.md)|Concatenating Column Values Problem|
|[08](./01_retrieving_records/08_using_conditional_logic_select.md)|Using Conditional Logic in a SELECT Statement Problem|
|[09](./01_retrieving_records/09_limiting_number_of_rows.md)|Limiting the Number of Rows Returned Problem|
|[10](./01_retrieving_records/10_returning_n_random_records.md)|Returning n Random Records from a Table Problem|
|[11](./01_retrieving_records/11_finding_null_values.md)|Finding Null Values|
|[12](./01_retrieving_records/12_transforming_null_values_to_real_values.md)|Transforming Nulls into Real Values Problem|
|[13](./01_retrieving_records/13_searching_for_patterns.md)|Searching for Patterns Problem|

# Chapter 2: Sorting Query Results

[Chapter 2](./02_sorting_query_results) focuses on customizing how your query results look. By understanding how to control how your result set is organized, you can provide more readable and meaningful data.

|file|description|
|:---:|:--------:|
|[01](./02_sorting_query_results/01_returning_query_results_in_specified_order.md)|Returning Query Results in a Specified Order Problem|
|[02](./02_sorting_query_results/02_sorting_by_multiple_fields.md)|Sorting by Multiple Fields Problem|
|[03](./02_sorting_query_results/03_sorting_by_substring.md)|Sorting by Substrings Problem|
|[04](./02_sorting_query_results/04_sorting_mixed_alphanumeric_data.md)|Sorting Mixed Alphanumeric Data Problem|
|[05](./02_sorting_query_results/05_dealing_with_nulls_sorting.md)|Dealing with Nulls When Sorting Problem|
|[06](./02_sorting_query_results/06_sorting_on_data_dependent_key.md)|Sorting on a Data-Dependent Key Problem|

# Chapter 3: Working with Multiple Tables

[Chapter 3](./03_working_with_multiple_tables) introduces the use of joins and set operations to combine data from multiple tables. Joins are the foundation of SQL. Set operations are also important.

|file|description|
|:---:|:--------:|
|[01](./03_working_with_multiple_tables/01_stacking_one_rowset_atop_another.md)|Stacking One Rowset A Top Atop another|
|[02](./03_working_with_multiple_tables/02_combining_related_rows.md)|Combining Related Rows|
|[03](./03_working_with_multiple_tables/03_finding_rows_in_common_between_two_tables.md)|Finding Rows in common between tables|
|[04](./03_working_with_multiple_tables/04_retrieving_values_from_table_that_donot_exist_in_another.md)|Retrieving Values From One Table That Do not Exists in Another|
|[05](./03_working_with_multiple_tables/05_retrieving_rows_from_a_table_that_donot_correspond_to_row_in_another.md)|Retrieving Rows From One Table That Do not correspond To Rows In Another|
|[06](./03_working_with_multiple_tables/06_adding_join_to_query_without_interferring.md)|Adding Joins to a Query Without Interfering With Other Joins|
|[07](./03_working_with_multiple_tables/07_determing_whether_two_tables_have_same_data.md)|Determiong Whether Two Tables Have the Same Data|
|[08](./03_working_with_multiple_tables/08_filtering_join.md)|Identyfing and Avoiding Cartesian Product|
|[09](./03_working_with_multiple_tables/09_performing_join_when_using_aggregates.md)|Performing Joins When Using Aggregates|
|[10](./03_working_with_multiple_tables/10_performing_outer_join_when_using_aggregates.md)|Performing Outer Joins When using Aggregates|
|[11](./03_working_with_multiple_tables/11_returning_missing_data_from_multiple_tables.md)|Retruning Missing Data From Multiple Tables|
|[12](./03_working_with_multiple_tables/12_using_nulls_in_operations_compartison.md)|Using NULLs in Operations and Comparisons|

# Chapter 4: Working with Strings

This [chapter](./04_working_with_strings) focuses on **string manipulation** in `SQL`. Keep in mind that `SQL` **is not designed to perform complex string manipulation**, and you can (and will) find working with strings in SQL to be cumbersome and frustrating at times.

Despite SQL’s limitations, there are some **useful built-in functions provided by the different DBMSs**, and we’ve tried to use them in creative ways. Hopefully you take away from this chapter a better appreciation for what can and can’t be done in SQL when working with strings.

In many cases you’ll be surprised by how easy parsing and transforming strings can be, while at other times you’ll be aghast by the kind of SQL that is necessary to accomplish a particular task.

Many of the recipes that follow use the `TRANSLATE` and `REPLACE` functions that are now available in all the DBMSs covered in this book, with the exception of MySQL, which only has replace. In this last case, it is worth noting early on that you can replicate the effect of `TRANSLATE` by using nested `REPLACE` functions.

The first recipe in this chapter is critically important, as it is leveraged by several of the subsequent solutions. In many cases, you’d like to have the **ability to traverse a string by moving through it a character at a time**. Unfortunately, SQL does not make this easy. Because there is limited loop functionality in SQL, you need to **mimic a loop to traverse a string**. We call this operation “**walking a string**” or “walking through a string,” and the very first recipe explains the technique. This is a fundamental operation in string parsing when using SQL, and is referenced and used by almost all recipes in this chapter. We strongly suggest becoming comfortable with how the technique works.

|file|description|
|:---:|:--------:|
|[01](./04_working_with_strings/01_walking_a_string.md)|Walking a string|
|[02](./04_working_with_strings/02_embedding_quotes_with_string_literals.md)|Embedding Quotes Within String Literals|
|[03](./04_working_with_strings/03_counting_occurrences_char_strings.md)|Counting the Occurrences of a Character in a String|
|[04](./04_working_with_strings/04_removing_unwanted_characters_from_a_string.md)|Removing Unwanted Characters from a String|
|[05](./04_working_with_strings/05_separating_numeric_and_charater_data.md)|Separating Numeric and Character Data|
|[06](./04_working_with_strings/06_determining_whether_a_string_is_alphanumeric.md)|Determining Whether a String Is Alphanumeric|
|[07](./04_working_with_strings/07_extracting_initials_from_a_name.md)|Extracting Initials from a Name|
|[08](./04_working_with_strings/08_ordering_by_parts_of_a_string.md)|Ordering by Parts of a String|
|[09](./04_working_with_strings/09_ordering_by_a_number_in_a_string.md)|Ordering by a Number in a String|
|[10](./04_working_with_strings/10_creating_delimited_list_form_table_rows.md)|Creating a Delimited List from Table Rows|
|[11](./04_working_with_strings/11_converting_delimited_data_into_multivalue_in_list.md)|Converting Delimited Data into a Multivalued IN-List|
|[12](./04_working_with_strings/12_alphabetaizing_a_string.md)|Alphabetizing a String|
|[13](./04_working_with_strings/13_identifying_string_that_can_be_treated_as_numbers.md)|Identifying Strings That Can Be Treated as Numbers|
|[14](./04_working_with_strings/14_extracting_the_nth_delimited_string.md)|Extracting the nth Delimited Substring|
|[15](./04_working_with_strings/15_parsing_an_ip_address.md)|Parsing an IP Address|
|[16](./04_working_with_strings/16_finiding_text_not_matching_a_pattern.md)|Finding Text Not Matching a Pattern|

# Chapter 5: Working with Numbers

This [chapter](./05_working_with_numbers) focuses on common operations involving numbers, including numeric computations. While SQL is not typically considered the first choice for complex computations, it is efficient for day-to-day numeric chores. More importantly, as databases and datawarehouses supporting SQL probably remain the most common place to find an organization’s data, using SQL to explore and evaluate that data is essential for anyone putting that data to work. The **techniques in this section have also been chosen to help data scientists decide which data is the most promising for further analysis**.

Some recipes in this chapter make use of aggregate functions and the GROUP BY clause. If you are not familiar with grouping, please read at least the first major section, called [04-sql-Aggregations](https://github.com/lpinzari/sql-psql-udy/tree/master/04_sql_aggregations).

|file|description|
|:---:|:--------:|
|[01](./05_working_with_numbers/01_computing_average.md)|computing an Average|
|[02](./05_working_with_numbers/02_finind_min_max_value_in_a_column.md)|Finding the Min/Max Value in a Column|
|[03](./05_working_with_numbers/03_summing_the_values_in_a_column.md)|Summing the Values in a Column|
|[04](./05_working_with_numbers/04_counting_rows_in_a_table.md)|Counting Rows in a Table|
|[05](./05_working_with_numbers/05_counting_values_in_a_column.md)|Counting Values in a Column|
|[06](./05_working_with_numbers/06_counting_values_in_multiple_columns.md)|Counting values in multiple columns|
|[07](./05_working_with_numbers/07_generating_running_total.md)|Generating a Running Total|
|[08](./05_working_with_numbers/08_generating_a_running_product.md)|Generating a Running Product|
|[09](./05_working_with_numbers/09_smoothing_a_series_of_values.md)|Smoothing a Series of Values|
|[10](./05_working_with_numbers/10_calculating_mode.md)|Calculating a Mode|
|[11](./05_working_with_numbers/11_calculating_median.md)|Calculating a Median|
|[12](./05_working_with_numbers/12_determing_the_percentage_of_a_total.md)|Determining the Percentage of a Total|
|[13](./05_working_with_numbers/13_aggregating_nullable_columns.md)|Aggregating Nullable Columns|
|[14](./05_working_with_numbers/14_computing_averages_without_high_low_values.md)|Computing Averages Without High and Low Values|
|[15](./05_working_with_numbers/15_converting_alphanumeric_string_to_numbers.md)|Converting Alphanumeric Strings into Numbers|
|[16](./05_working_with_numbers/16_changing_values_in_a_running_total.md)|Changing Values in a Running Total|
|[17](./05_working_with_numbers/17_finding_outliers_using_median_absolute_deviation.md)|Finding Outliers Using the Median Absolute Deviation|
|[18](./05_working_with_numbers/18_finding_anomalies_using_benford_law.md)|Finding Anomalies Using Benford’s Law|

# Chapter 6: Date Arithmetic

This [chapter](./06_date_arithmetic) introduces techniques for performing simple date arithmetic. Recipes cover common tasks such as adding days to dates, finding the number of business days between dates, and finding the difference between dates in days.
Being able to successfully manipulate dates with your RDBMS’s built-in functions can greatly improve your productivity. For all the recipes in this chapter, we try to take advantage of each RDBMS’s built-in functions.

For Additional information about `Date` data type format in PostgreSql please refer to the following resource: [Date](https://github.com/lpinzari/sql-psql-udy/blob/master/04_sql_aggregations/14_date_grouping.md).

|file|description|
|:---:|:--------:|
|[01](./06_date_arithmetic/intro.md)| introduction|
|[02](./06_date_arithmetic/02_add_subtract_days_months_years.md)|Adding and Subtracting Days, Months, and Years|
|[03](./06_date_arithmetic/03_determining_number_of_days_between_dates.md)|Determining the Number of Days Between Two Dates|
|[04](./06_date_arithmetic/04_determining_number_of_business_days_between_dates2.md)|Determining the Number of Business Days Between Two Dates for all employees|
|[04b](./06_date_arithmetic/04_determining_number_of_business_days_between_dates.md)|Determining the Number of Business Days Between Two Dates|
|[05](./06_date_arithmetic/05_determining_number_of_months_years_between_dates.md)| Determining the Number of Months or Years Between Two Dates|
|[06](./06_date_arithmetic/06_determining_seconds_minutes_hours_between_dates.md)|Determining the Number of Seconds, Minutes, or Hours Between Two Dates|
|[07](./06_date_arithmetic/07_counting_occurrence_weekdays_current_year.md)|Counting the Occurrences of Weekdays in a Year|
|[08](./06_date_arithmetic/08_determining_date_difference_between_current_record_next_record.md)|Determining the Date Difference Between the Current Record and the Next Record|

# Chapter 7: Date Manipulation

This [chapter](./07_date_manipulation) introduces recipes for searching and modifying dates. Queries involving dates are very common. Thus, you need to know how to think when working with dates, and you need to have a good understanding of the functions that your RDBMS platform provides for manipulating them. The recipes in this chapter form an impor‐ tant foundation for future work as you move on to more complex queries involving not only dates, but times, too.

|file|description|
|:---:|:--------:|
|[01](./07_date_manipulation/01_determining_whether_a_year_is_leap_year.md)| Determining Whether a Year Is a Leap Year|
|[02](./07_date_manipulation/02_determining_number_of_days_in_a_year.md)|Determining the Number of Days in a Year |
|[03](./07_date_manipulation/03_extracting_units_of_time_from_a_date.md)| Extracting Units of Time from a Date|
|[04](./07_date_manipulation/04_determining_first_last_day_of_month.md)| Determining the First and Last Days of a Month|
|[05](./07_date_manipulation/05_determining_all_dates_for_a_weekday_throughtout_year.md)| Determining All Dates for a Particular Weekday Throughout a Year|
|[06](./07_date_manipulation/06_determining_the_day_first_last_occurrences_of_a_weekday_month.md)|Determining the Date of the First and Last Occurrences of a Specific Weekday in a Month |
|[07](./07_date_manipulation/07_creating_a_calendar.md)| Creating a Calendar|
|[08](./07_date_manipulation/08_listing_quarter_start_end_of_year.md)| Listing Quarter Start and End Dates for the Year|
|[09](./07_date_manipulation/09_determining_quarter_start_end_of_given_year_quarter.md)| Determining Quarter Start and End Dates for a Given Quarter|
|[10](./07_date_manipulation/10_filling_in_missing_dates.md)|Filling In Missing Dates |
|[11](./07_date_manipulation/11_searching_on_specific_units_of_time.md)|Searching on Specific Units of Time |
|[12](./07_date_manipulation/12_comparing_records_using_specifc_part_of_a_date.md)| Comparing Records Using Specific Parts of a Date|
|[13](./07_date_manipulation/13_identifying_overlapping_date_ranges.md)| Identifying Overlapping Date Ranges|

# Chapter 8: Working with Ranges

This [chapter](./08_working_with_ranges) is about “everyday” queries that involve ranges. Ranges are common in everyday life. For example, projects that we work on range over consecutive periods of time. In SQL, it’s often necessary to search for ranges, or to generate ranges, or to otherwise manipulate range-based data. The queries you’ll read about here are slightly more involved than the queries found in the preceding chapters, but they are just as common, and they’ll begin to give you a sense of what SQL can really do for you when you learn to take full advantage of it.

|file|description|
|:---:|:--------:|
|[00](./08_working_with_ranges/00_identify_non_consecutive_values.md)|Identify non-consecutive values |
|[01](./08_working_with_ranges/01_identify_consecutive_values.md)|Identify consecutive values |
|[02](./08_working_with_ranges/02_grouping_a_range_consecutive_values.md)| Grouping a Range of Consecutive Values|
|[03](./08_working_with_ranges/03_finding_differences_between_rows_in_the_same_group.md)| Finding Differences Between Rows in the Same Group or Partition|
|[04](./08_working_with_ranges/04_filling_in_missing_values_in_a_range_of_values.md)|Filling in Missing Values in a Range of Values |
|[05](./08_working_with_ranges/05_generating_consecutive_values.md)| Generating Consecutive Numeric Values|


# Chapter 9: Advanced Searching

You’ve seen all sorts of queries that use joins and WHERE clauses and grouping techniques to search out and return the results you need.

Some types of searching operations, though, stand apart from others in that they represent a different way of thinking about searching. Perhaps `you’re displaying a result set one page at a time`. Half of that problem is to identify (search for) the entire set of records that you want to display. The other half of that problem is to repeatedly search for the next page to display as a user cycles through the records on a display. Your first thought may not be to think of **pagination as a searching problem**, but it can be thought of that way, and it can be solved that way; that is the type of searching solution this [chapter](./09_advanced_searching) is all about.

|file|description|
|:---:|:--------:|
|[01](./09_advanced_searching/01_paginating_through_a_result_set.md)|Paginating Through a Result Set|
|[02](./09_advanced_searching/02_skipping_n_rows_from_a_table.md)|Skipping n Rows from a Table|
|[03](./09_advanced_searching/03_incorporating_or_logic_using_outer_join.md)|Incorporating OR Logic When Using Outer Joins|
|[04](./09_advanced_searching/04_determining_which_rows_are_reciprocals.md)|Determining Which Rows Are Reciprocals|
|[05](./09_advanced_searching/05_selecting_top_n_records.md)|Selecting the Top n Records|
|[06](./09_advanced_searching/06_find_records_with_highest_lowest_values.md)|Finding Records with the Highest and Lowest Values|
|[07](./09_advanced_searching/07_investigating_future_rows.md)|Investigating Future Rows|
|[08](./09_advanced_searching/08_shifting_row_values.md)|Shifting Row Values|
|[09](./09_advanced_searching/09_ranking_results.md)|Ranking Results|
|[10](./09_advanced_searching/10_suppressing_duplicates.md)|Suppressing Duplicates|
|[11](./09_advanced_searching/11_finding_knight_values.md)|Finding Knight Values|
|[12](./09_advanced_searching/12_generating_simple_forecast.md)|Generating Simple Forecasts|

# Chapter 10: Reporting and Reshaping

This [chapter](./10_reporting_reshaping) introduces queries you may find helpful for **creating reports**. These typically involve `reporting-specific formatting` considerations along with different levels of aggregation.

Another focus of this chapter is **transposing** or **pivoting result sets**:
- `reshaping the data by turning rows into columns`.

In general, these recipes have in common that they allow you to present data in for‐ mats or shapes different from the way they are stored.


|file|description|
|:---:|:--------:|
|[01](./10_reporting_reshaping/01_pivoting_a_result_set_into_one_row.md)|Pivoting a Result Set into One Row|
|[02](./10_reporting_reshaping/02_pivoting_a_result_set_into_multiple_rows.md)|Pivoting a Result Set into Multiple Rows|
|[03](./10_reporting_reshaping/03_reverse_pivoting_a_result_set.md)|Reverse Pivoting a Result Set|
|[04](./10_reporting_reshaping/04_reverse_pivoting_result_set_into_one_column.md)|Reverse Pivoting a Result Set into One Column|
|[05](./10_reporting_reshaping/05_suppressing_repeating_values_in_result_set.md)|Suppressing Repeating Values from a Result Set|
|[06](./10_reporting_reshaping/06_pivoting_result_setto_facilitate_interrow_calculations.md)|Pivoting a Result Set to Facilitate Inter-Row Calculations|
|[07](./10_reporting_reshaping/07_creating_buckets_of_data_of_fixed_sized.md)|Creating Buckets of Data, of a Fixed Size|
|[08](./10_reporting_reshaping/08_creating_predifined_number_of_buckets.md)|Creating a Predefined Number of Buckets|
|[09](./10_reporting_reshaping/09_creating_horizontal_histograms.md)|Creating Horizontal Histograms|
|[10](./10_reporting_reshaping/10_creating_vertical_histograms.md)|Creating Vertical Histograms|
|[11](./10_reporting_reshaping/11_returning_non_groupby_columns.md)|Returning Non-GROUP BY Columns|
|[12](./10_reporting_reshaping/12_calculating_simple_subtotals.md)|Calculating Simple Subtotals|
|[13](./10_reporting_reshaping/13_calculating_subtotals_for_all_possible_expression_combinations.md)|Calculating Subtotals for All Possible Expression Combinations|
|[14](./10_reporting_reshaping/14_using_case_expressions_to_flag_rows.md)|Using Case Expressions to Flag Rows|
|[15](./10_reporting_reshaping/15_creating_a_sparse_matrix.md)|Creating a Sparse Matrix|
|[16](./10_reporting_reshaping/16_grouping_rows_by_units_of_time.md)|Grouping Rows by Units of Time|
|[17](./10_reporting_reshaping/17_performing_aggregation_over_different_group.md)|Performing Aggregations over Different Groups/ Partitions Simultaneously|
|[18](./10_reporting_reshaping/18_performing_aggregations_over_a_moving_range_of_values.md)|Performing Aggregations over a Moving Range of Values|
|[19](./10_reporting_reshaping/19_pivoting_a_result_set_with_subtotals.md)|Pivoting a Result Set with Subtotals|
