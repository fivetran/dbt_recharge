<!--section="recharge_transformation_model"-->
# Recharge dbt Package

<p align="left">
    <a alt="License"
        href="https://github.com/fivetran/dbt_recharge/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0,_<3.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
    <a alt="Fivetran Quickstart Compatible"
        href="https://fivetran.com/docs/transformations/dbt/quickstart">
        <img src="https://img.shields.io/badge/Fivetran_Quickstart_Compatible%3F-yes-green.svg" /></a>
</p>

This dbt package transforms data from Fivetran's Recharge connector into analytics-ready tables.

## Resources

- Number of materialized models¹: 38
- Connector documentation
  - [Recharge connector documentation](https://fivetran.com/docs/connectors/applications/recharge)
  - [Recharge ERD](https://fivetran.com/docs/connectors/applications/recharge#schemainformation)
- dbt package documentation
  - [GitHub repository](https://github.com/fivetran/dbt_recharge)
  - [dbt Docs](https://fivetran.github.io/dbt_recharge/#!/overview)
  - [DAG](https://fivetran.github.io/dbt_recharge/#!/overview?g_v=1)
  - [Changelog](https://github.com/fivetran/dbt_recharge/blob/main/CHANGELOG.md)

## What does this dbt package do?
This package enables you to better understand your Recharge data by summarizing customer, revenue, and subscription trends. It creates enriched models with metrics focused on billing history, customer details, and subscription analytics.

### Output schema
Final output tables are generated in the following target schema:

```
<your_database>.<connector/schema_name>_recharge
```

### Final output tables

By default, this package materializes the following final tables:

| Table | Description |
| :---- | :---- |
| [recharge__billing_history](https://fivetran.github.io/dbt_recharge/#!/model/model.recharge.recharge__billing_history) | Tracks order-level billing history with charge details including order and charge prices, subtotals, discounts, refunds, taxes, shipping costs, and item quantities to analyze order value and fulfillment patterns. <br></br>**Example Analytics Questions:**<ul><li>What is the average order_total_price and charge_total_price by order_status and charge_status?</li><li>How many orders are generated from each charge (orders_count) for prepaid versus non-prepaid orders?</li><li>What is the total_net_charge_value and how do discounts and refunds impact it by order_type?</li></ul>|
| [recharge__charge_line_item_history](https://fivetran.github.io/dbt_recharge/#!/model/model.recharge.recharge__charge_line_item_history) | Chronicles individual line item transactions including charges, refunds, discounts, shipping, and taxes by line item type to provide granular visibility into charge components and calculations. <br></br>**Example Analytics Questions:**<ul><li>Which line item types (charge, discount, shipping, tax, refund) have the highest total amounts?</li><li>How many line items of each type are typically associated with each charge_id?</li><li>What is the distribution of line item amounts by line_item_type and customer_id?</li></ul>|
| [recharge__customer_daily_rollup](https://fivetran.github.io/dbt_recharge/#!/model/model.recharge.recharge__customer_daily_rollup) | Provides daily customer transaction snapshots with realized and running totals for orders, charges, discounts, taxes, refunds, and item quantities to track customer spending evolution and lifetime value trends. <br></br>**Example Analytics Questions:**<ul><li>How does the charge_total_price_running_total evolve day-by-day for each customer?</li><li>What are the daily trends in recurring_orders versus one_time_orders by customer?</li><li>How many active_months_to_date does each customer have and how does spending correlate?</li></ul>|
| [recharge__customer_details](https://fivetran.github.io/dbt_recharge/#!/model/model.recharge.recharge__customer_details) | Consolidates customer profiles with comprehensive transaction metrics including order counts, amounts, subscription counts, discounts, taxes, refunds, and monthly averages to understand customer lifetime value and engagement patterns. <br></br>**Example Analytics Questions:**<ul><li>Which customers have the highest total_net_spend and subscriptions_active_count?</li><li>How do avg_order_amount and orders_monthly_average vary across customer segments?</li><li>What percentage of customers have is_currently_subscribed = true and how does their spending compare?</li></ul>|
| [recharge__monthly_recurring_revenue](https://fivetran.github.io/dbt_recharge/#!/model/model.recharge.recharge__monthly_recurring_revenue) | Tracks monthly recurring revenue (MRR) and non-MRR by customer including recurring order counts, one-time order counts, net recurring charges, and net one-time charges to measure subscription business health and revenue trends. <br></br>**Example Analytics Questions:**<ul><li>What is the total_net_recurring_charges (MRR) by customer and how is it trending month-over-month?</li><li>How do recurring_orders versus one_time_orders contribute to total revenue by month?</li><li>Which customers have the highest calculated_net_order_mrr and lowest churn risk?</li></ul>|
| [recharge__subscription_overview](https://fivetran.github.io/dbt_recharge/#!/model/7+model.recharge.recharge__subscription_overview) | Provides detailed subscription profiles with customer info, product details, pricing, subscription status, billing intervals, charge counts, and schedule information to monitor subscription lifecycle and billing patterns. <br></br>**Example Analytics Questions:**<ul><li>Which subscriptions have the highest price and quantity values by subscription_status?</li><li>How do charge_interval_frequency and order_interval_frequency vary across products?</li><li>What are the most common cancellation_reason values and how do they correlate with subscription tenure?</li></ul>|
| [recharge__line_item_enhanced](https://fivetran.github.io/dbt_recharge/#!/model/model.recharge.recharge__line_item_enhanced) | This model constructs a comprehensive, denormalized analytical table that enables reporting on key revenue, subscription, customer, and product metrics from your billing platform. It's designed to align with the schema of the `*__line_item_enhanced` model found in Recharge, Recurly, Stripe, Shopify, and Zuora, offering standardized reporting across various billing platforms. To see the kinds of insights this model can generate, explore example visualizations in the [Fivetran Billing Model Streamlit App](https://fivetran-billing-model.streamlit.app/). Visit the app for more details. |

An example churn model is separately available in the analysis folder:
| **analysis model** | **description** |
|-----------|-----------------|
| [recharge__account_churn_analysis](https://fivetran.github.io/dbt_recharge/#!/analysis/analysis.recharge.recharge__churn_analysis) | Each record represents a customer and their churn reason according to recharge's documentation. |

¹ Each Quickstart transformation job run materializes these models if all components of this data model are enabled. This count includes all staging, intermediate, and final models materialized as `view`, `table`, or `incremental`.

---

## Visualizations
Many of the above reports are now configurable for [visualization via Streamlit](https://github.com/fivetran/streamlit_recharge). Check out some [sample reports here](https://fivetran-recharge.streamlit.app/).

<p align="center">
<a href="https://fivetran-billing-model.streamlit.app/">
    <img src="https://raw.githubusercontent.com/fivetran/dbt_recharge/main/images/streamlit_example.png" alt="Streamlit Billing Model App" width="75%">
</a>
</p>

## Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Recharge connection syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.

## How do I use the dbt package?
You can either add this dbt package in the Fivetran dashboard or import it into your dbt project:

- To add the package in the Fivetran dashboard, follow our [Quickstart guide](https://fivetran.com/docs/transformations/dbt).
- To add the package to your dbt project, follow the setup instructions in the dbt package's [README file](https://github.com/fivetran/dbt_recharge/blob/main/README.md#how-do-i-use-the-dbt-package) to use this package.

<!--section-end-->

### Install the package
Include the following recharge package version in your `packages.yml` file.
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yaml
packages:
  - package: fivetran/recharge
    version: [">=1.4.0", "<1.5.0"] # we recommend using ranges to capture non-breaking changes automatically
```
> All required sources and staging models are now bundled into this transformation package. Do not include `fivetran/recharge_source` in your `packages.yml` since this package has been deprecated.

#### Databricks Dispatch Configuration
If you are using a Databricks destination with this package, you must add the following dispatch configuration (or a variation thereof) within your `dbt_project.yml`. This is required for the package to accurately search for macros within the `dbt-labs/spark_utils` package, then the `dbt-labs/dbt_utils` package, respectively.

```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

### Define database and schema variables

#### Option A: Single connection
By default, this package runs using your [destination](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile) and the `recharge` schema. If this is not where your Recharge data is (for example, if your Recharge schema is named `recharge_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
  recharge:
    recharge_database: your_database_name
    recharge_schema: your_schema_name
```

#### Option B: Union multiple connections
If you have multiple Recharge connections in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. For each source table, the package will union all of the data together and pass the unioned table into the transformations. The `source_relation` column in each model indicates the origin of each record.

To use this functionality, you will need to set the `recharge_sources` variable in your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
  recharge:
    recharge_sources:
      - database: connection_1_destination_name # Required
        schema: connection_1_schema_name # Required
        name: connection_1_source_name # Required only if following the step in the following subsection

      - database: connection_2_destination_name
        schema: connection_2_schema_name
        name: connection_2_source_name
```

##### Recommended: Incorporate unioned sources into DAG
> *If you are running the package through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt#transformationsfordbtcore), the below step is necessary in order to synchronize model runs with your Recharge connections. Alternatively, you may choose to run the package through Fivetran [Quickstart](https://fivetran.com/docs/transformations/quickstart), which would create separate sets of models for each Recharge source rather than one set of unioned models.*

By default, this package defines one single-connection source, called `recharge`, which will be disabled if you are unioning multiple connections. This means that your DAG will not include your Recharge sources, though the package will run successfully.

To properly incorporate all of your Recharge connections into your project's DAG:
1. Define each of your sources in a `.yml` file in your project. Utilize the following template for the `source`-level configurations, and, **most importantly**, copy and paste the table and column-level definitions from the package's `src_recharge.yml` [file](https://github.com/fivetran/dbt_recharge/blob/main/models/staging/src_recharge.yml).

```yml
# a .yml file in your root project

version: 2

sources:
  - name: <name> # ex: Should match name in recharge_sources
    schema: <schema_name>
    database: <database_name>
    loader: fivetran
    config:
      loaded_at_field: _fivetran_synced
      freshness: # feel free to adjust to your liking
        warn_after: {count: 72, period: hour}
        error_after: {count: 168, period: hour}

    tables: # copy and paste from recharge/models/staging/src_recharge.yml - see https://support.atlassian.com/bitbucket-cloud/docs/yaml-anchors/ for how to use anchors to only do so once
```

> **Note**: If there are source tables you do not have (see [Enable/disable models and sources](#enabledisable-models-and-sources)), you may still include them, as long as you have set the right variables to `False`.

2. Set the `has_defined_sources` variable (scoped to the `recharge` package) to `True`, like such:
```yml
# dbt_project.yml
vars:
  recharge:
    has_defined_sources: true
```

### Enable/disable models and sources
Your Recharge connection may not sync every table that this package expects. If you do not have the `CHECKOUT`, `ONE_TIME_PRODUCT` and/or `CHARGE_TAX_LINE` tables synced, add the corresponding variable(s) to your root `dbt_project.yml` file to disable these sources:

```yml
vars:
  recharge__one_time_product_enabled: false # Disables if you do not have the ONE_TIME_PRODUCT table. Default is True.
  recharge__charge_tax_line_enabled: false # Disables if you do not have the CHARGE_TAX_LINE table. Default is True.
  recharge__checkout_enabled: true # Enables if you do have the CHECKOUT table. Default is False.
```

### (Optional) Additional configurations
<details open><summary>Expand/collapse section.</summary>

#### Enabling Standardized Billing Model
This package contains the `recharge__line_item_enhanced` model which constructs a comprehensive, denormalized analytical table that enables reporting on key revenue, subscription, customer, and product metrics from your billing platform. It's designed to align with the schema of the `*__line_item_enhanced` model found in Recurly, Recharge, Stripe, Shopify, and Zuora, offering standardized reporting across various billing platforms. To see the kinds of insights this model can generate, explore example visualizations in the [Fivetran Billing Model Streamlit App](https://fivetran-billing-model.streamlit.app/). This model is enabled by default. To disable it, set the `recharge__standardized_billing_model_enabled` variable to `false` in your `dbt_project.yml`:

```yml
vars:
  recharge__standardized_billing_model_enabled: false # true by default.
```

#### Setting the date range
By default, the models `customer_daily_rollup` and `monthly_recurring_revenue` will aggregate data for the entire date range of your data set. However, you may limit this date range if desired by defining the following variables. You do not need to set both if you only want to limit one.
```yml
vars:
    recharge_first_date: "yyyy-mm-dd"
    recharge_last_date: "yyyy-mm-dd"
```
#### Passing Through Additional Columns
This package includes all source columns defined in the macros folder. If you would like to pass through additional columns to the staging models, add the following configurations to your `dbt_project.yml` file. These variables allow the pass-through fields to be aliased (`alias`) and casted (`transform_sql`) if desired, but not required. Datatype casting is configured via a SQL snippet within the `transform_sql` key. You may add the desired SQL while omitting the `as field_name` at the end and your custom pass-though fields will be casted accordingly. Use the below format for declaring the respective pass-through variables in your root `dbt_project.yml`.
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
    recharge__checkout_passthrough_columns:
    recharge__discount_passthrough_columns:
    recharge__order_passthrough_columns:
    recharge__order_line_passthrough_columns:
    recharge__subscription_passthrough_columns:
    recharge__subscription_history_passthrough_columns:
```

#### Changing the Build Schema
By default, this package builds the Recharge staging models within a schema titled (<target_schema> + `_recharge_source`) and the Recharge transformation models within a schema titled (<target_schema> + `_recharge`) in your destination. If this is not where you would like your Recharge data written, add the following configuration to your root `dbt_project.yml` file:

```yml
models:
    recharge:
      +schema: my_new_schema_name # Leave +schema: blank to use the default target_schema.
      staging:
        +schema: my_new_schema_name # Leave +schema: blank to use the default target_schema.
```

#### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:

> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_recharge/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
vars:
    recharge_<default_source_table_name>_identifier: your_table_name 
```

#### Snowflake Users
You may need to provide the case-sensitive spelling of your source tables that are also Snowflake reserved words.

In this package, this would apply to the `ORDER` source. If you are receiving errors for this source, include the following in your `dbt_project.yml` file. (**Note:** This should not be necessary for the `ORDERS` source table.)
```yml
vars:
  recharge_order_identifier: '"Order"' # as an example, must include this quoting pattern and adjust for your exact casing
```

**Note:** if you have sources defined in your project's yml, the above will not work. Instead, you will need to add the following where your order table is defined in your yml:
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

### (Optional) Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for more details</summary>

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core™ setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).

</details>

## Does this package have dependencies?
This dbt package is dependent on the following dbt packages. These dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.
```yml
packages:
    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]
```

<!--section="recharge_maintenance"-->
## How is this package maintained and can I contribute?

### Package Maintenance
The Fivetran team maintaining this package only maintains the [latest version](https://hub.getdbt.com/fivetran/recharge/latest/) of the package. We highly recommend you stay consistent with the latest version of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_recharge/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Learn how to contribute to a package in dbt's [Contributing to an external dbt package article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657).

### Opinionated Modelling Decisions
This dbt package takes an opinionated stance on revenue is calculated, using charges in some cases and orders in others. If you would like a deeper explanation of the logic used by default in the dbt package, you may reference the [DECISIONLOG](https://github.com/fivetran/dbt_recharge/blob/main/DECISIONLOG.md).

<!--section-end-->

## Are there any resources available?
- If you have questions or want to reach out for help, see the [GitHub Issue](https://github.com/fivetran/dbt_recharge/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).