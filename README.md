# Nashville Housing Data Cleaning and Exploration Project 🏡

## Overview
This project demonstrates my SQL expertise in data cleaning, transformation, and exploration. Using a real-world dataset from the Nashville housing market, I applied a series of SQL queries to standardize, clean, and analyze the data. The project showcases my ability to handle complex data manipulation tasks, ensuring data quality and extracting meaningful insights.

## Project Objectives
1. **Standardize Date Format**: Convert inconsistent date formats into a standardized form to improve data integrity.
2. **Populate Missing Data**: Handle missing property addresses by filling them in using records with matching `ParcelID`.
3. **Split Address into Components**: Break down property addresses into `Street` and `City` components for better analysis.
4. **Standardize "Sold As Vacant" Field**: Clean the categorical data for the `SoldAsVacant` column to ensure consistency.
5. **Remove Duplicates**: Identify and remove duplicate records using SQL window functions.
6. **Column Cleanup**: Eliminate unnecessary columns to streamline the dataset.
7. **Handle Outliers**: Detect and manage outliers in `SalePrice` using statistical analysis.
8. **Normalize Numerical Data**: Apply min-max scaling to the `SalePrice` for future use in machine learning models.
9. **Data Aggregation**: Generate business insights by aggregating data on average sale prices by neighborhood and property types sold.
10. **Data Validation**: Ensure the dataset adheres to integrity constraints by validating critical fields and adding unique constraints.

## Skills Demonstrated
- **Data Cleaning**: Extensive use of SQL to handle missing data, remove duplicates, and clean categorical fields.
- **Date Manipulation**: Standardizing inconsistent date formats to ensure uniformity.
- **Data Normalization**: Min-max scaling of numerical fields like `SalePrice`.
- **SQL Window Functions**: Efficient use of `ROW_NUMBER()` to manage duplicates.
- **Data Aggregation**: Aggregating key business metrics such as average sale price by neighborhood.
- **Constraint Management**: Implementing unique constraints to ensure data integrity.

## Key SQL Techniques Used
- `CONVERT()`: Standardized inconsistent date formats.
- `ISNULL()`: Filled missing property addresses from other records with the same `ParcelID`.
- `ROW_NUMBER()`: Identified duplicate records for removal.
- `CASE`: Cleaned categorical fields for consistency.
- `AVG()`, `STDEV()`: Statistical analysis for outlier detection.
- `MIN()`, `MAX()`: Normalization of numerical data.
- `GROUP BY`: Aggregated data for business insights.
- Constraints: Added unique constraints for improved data validation.

## Business Insights Gained
- **Average Sale Prices by Neighborhood**: Identified neighborhoods with the highest average property sale prices.
- **Most Common Property Types Sold**: Analyzed and identified the most frequently sold property types in the dataset.

## Future Enhancements
- **Advanced Analysis**: Use machine learning algorithms for property price predictions.
- **Visualization**: Add visualization tools like Tableau or Power BI to showcase trends and patterns in the data.

## Conclusion
This project highlights my SQL proficiency in cleaning and exploring large datasets. By applying advanced SQL techniques, I transformed a raw dataset into a structured, clean, and insightful dataset that is ready for further analysis or modeling.

