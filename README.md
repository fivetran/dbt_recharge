# WORK IN PROGRESS!!
<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_recharge/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
</p>

# Recharge dbt package ([Docs](https://fivetran.github.io/dbt_recharge/))
# 📣 What does this dbt package do?
- Produces modeled tables that leverage Recharge data from [Fivetran's connector](https://fivetran.com/docs/applications/recharge) in the format described by [this ERD](https://fivetran.com/docs/applications/recharge#schemainformation) and build off the output of our [Recharge source package](https://github.com/fivetran/dbt_recharge_source).
- Enables you to better understand your Recharge data by summarizing customer, revenue, and subscription trends.
- Generates a comprehensive data dictionary of your source and modeled Recharge data through the [dbt docs site](https://fivetran.github.io/dbt_recharge/).

The following table provides a detailed list of all models materialized within this package by default. 
> TIP: See more details about these models in the package's [dbt docs site](https://fivetran.github.io/dbt_recharge/#!/overview?g_v=1).
 
| **model** | **description** |
|-----------|-----------------|
| [recharge__billing_history](https://fivetran.github.io/dbt_recharge/#!/model/model.recharge.recharge__billing_history) | Each record represents an order, enriched with metrics about related charges and line items. Line items are aggregated at the billing (order) level. |
| [recharge__charge_line_item_history](https://fivetran.github.io/dbt_recharge/#!/model/model.recharge.recharge__charge_line_item_history) | Each record represents a specific line item charge, refund, or other line item that accumulates into final charges. |
| [recharge__customer_daily_rollup](https://fivetran.github.io/dbt_recharge/#!/model/model.recharge.recharge__customer_daily_rollup) | Each record provides totals and running totals for a customer's associated transactions for the specified day. |
| [recharge__customer_details](https://fivetran.github.io/dbt_recharge/#!/model/model.recharge.recharge__customer_details) | Each record represents a customer, enriched with metrics about their associated transactions. |
| [recharge__monthly_recurring_revenue](https://fivetran.github.io/dbt_recharge/#!/model/model.recharge.recharge__monthly_recurring_revenue) | Each record represents a customer, MRR, and non-MRR generated on a monthly basis. |
| [recharge__subscription_overview](https://fivetran.github.io/dbt_recharge/#!/model/7+model.recharge.recharge__subscription_overview) | Each record represents a subscription, enriched with customer and charge information. |

An example churn model is separately available in the analysis folder:
| **analysis model** | **description** |
|-----------|-----------------|
| [recharge__account_churn_analysis](https://fivetran.github.io/dbt_recharge/#!/analysis/analysis.recharge.recharge__churn_analysis) | Each record represents a customer and their churn reason according to recharge's documentation. |
# 🎯 How do I use the dbt package?
## Step 1: Prerequisites
To use this dbt package, you must have the following:
- At least one Fivetran Recharge connector syncing data into your destination. 
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, **Databricks** destination.

## Step 2: Install the package
Include the following recharge package version in your `packages.yml` file.
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yaml
packages:
  - package: fivetran/recharge
    version: [">=0.1.0", "<0.2.0"] # we recommend using ranges to capture non-breaking changes automatically
```
Do **NOT** include the `recharge_source` package in this file. The transformation package itself has a dependency on it and will install the source package as well.

### Databricks Dispatch Configuration
If you are using a Databricks destination with this package, you must add the following (or a variation of the following) dispatch configuration within your `dbt_project.yml`. This is required for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.

```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```
## Step 3: Define database and schema variables
By default, this package runs using your destination and the `recharge` schema. If your Recharge data is in a different database or schema (for example, if your recharge schema is named `recharge_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
  recharge_database: your_destination_name
  recharge_schema: your_schema_name 
```

## Step 4: Disable models for non-existent sources
Your Recharge connector may not sync every table that this package expects. If you do not have the `ONE_TIME_PRODUCT` and/or `CHARGE_TAX_LINE` tables synced, add the corresponding variable(s) to your root `dbt_project.yml` file to disable these sources:

```yml
vars:
  recharge__one_time_product_enabled: false # Disables if you do not have the ONE_TIME_PRODUCT table. Default is True.
  recharge__charge_tax_line_enabled: false # Disables if you do not have the CHARGE_TAX_LINE table. Default is True.
``` 

## (Optional) Step 5: Additional configurations
<details><summary>Expand for configurations</summary>

### Setting the date range
By default, the models `customer_daily_rollup` and `monthly_recurring_revenue` will aggregate data for the entire date range of your data set. However, you may limit this date range if desired by defining the following variables. You do not need to set both if you only want to limit one. 
```yml
vars:
    recharge_first_date: "yyyy-mm-dd"
    recharge_last_date: "yyyy-mm-dd"
```
### Passing Through Additional Columns
This package includes all source columns defined in the macros folder. If you would like to pass through additional columns to the staging models, add the following configurations to your `dbt_project.yml` file. These variables allow for the pass-through fields to be aliased (`alias`) and casted (`transform_sql`) if desired, but not required. Datatype casting is configured via a sql snippet within the `transform_sql` key. You may add the desired sql while omitting the `as field_name` at the end and your custom pass-though fields will be casted accordingly. Use the below format for declaring the respective pass-through variables in your root `dbt_project.yml`.
```yml
vars:
    recharge__address_passthrough_columns: 
      - name: "new_custom_field"
        alias: "custom_field_name"
        transform_sql:  "cast(custom_field_name as int64)"
      - name: "a_second_field"
        transform_sql:  "cast(a_second_field as string)"
    # a similar pattern can be applied to the rest of the following variables.
    recharge__charge_passthrough_columns:
    recharge__charge_line_item_passthrough_columns: 
    recharge__order_passthrough_columns:
    recharge__order_line_passthrough_columns:
    recharge__subscription_passthrough_columns:
    recharge__subscription_history_passthrough_columns:
```

### Changing the Build Schema
By default, this package builds the Recharge staging models within a schema titled (<target_schema> + `_recharge_source`) and the Recharge transformation models within a schema titled (<target_schema> + `_recharge`) in your destination. If this is not where you would like your Recharge data written, add the following configuration to your root `dbt_project.yml` file:

```yml
models:
    recharge:
      +schema: my_new_schema_name # leave blank for just the target_schema
    recharge_source:
      +schema: my_new_schema_name # leave blank for just the target_schema
```

### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:

> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_recharge_source/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
vars:
    recharge_<default_source_table_name>_identifier: your_table_name 
```

### 🚨 Snowflake Users 🚨
You may need to provide the case-sensitive spelling of your source tables that are also Snowflake reserved words.

In this package, this would apply to the `ORDER` source. If you are receiving errors for this source, include the following in your `dbt_project.yml` file:
```yml
vars:
  recharge_order_identifier: '"Order"' # as an example, must include this quoting pattern and adjust for your exact casing
```

**Note!** if you have sources defined in your project's yml, the above will not work. Instead you will need to add the following where your order table is defined in your yml:
```yml
sources:
  tables:
    - name: order 
      # Add the below
      identifier: ORDER # Or what your order table is named, being mindful of casing
      quoting:
        identifier: true
```
</details>

## (Optional) Step 6: Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for more details</summary>

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core™ setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).
    
</details>

# 🔍 Does this package have dependencies?
This dbt package is dependent on the following dbt packages. Please be aware that these dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.
```yml
packages:
    - package: fivetran/recharge_source
      version: [">=0.1.0", "<0.2.0"]

    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]
```

# 🙌 How is this package maintained and can I contribute?
## Package Maintenance
The Fivetran team maintaining this package maintains _only_ the latest version of the package. We highly recommend that you consistently use the [latest version](https://hub.getdbt.com/fivetran/recharge/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_recharge/blob/main/CHANGELOG.md) and release notes for more information about changes.

## Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions! 

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) to learn how to contribute to a dbt package!

## Opinionated Modelling Decisions
This dbt package takes an opinionated stance on revenue is calculated, using charges in some cases and orders in others. If you would like a deeper explanation of the logic used by default in the dbt package you may reference the [DECISIONLOG](https://github.com/fivetran/dbt_recharge/blob/main/DECISIONLOG.md).

# 🏪 Are there any resources available?
- If you have questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_microsoft_ads/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
- Have questions or want to be part of the community discourse? Create a post in the [Fivetran community](https://community.fivetran.com/t5/user-group-for-dbt/gh-p/dbt-user-group) and our team along with the community can join in on the discussion!