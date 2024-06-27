# dbt_recharge v0.3.0
[PR #17](https://github.com/fivetran/dbt_recharge/pull/17) includes the following updates:
## Feature Updates
- Introduced the new `recharge__line_item_enhanced` model. This model includes a line item enriched with invoice, subscription, payment, and refund information. This model has been built with the intention of retaining a common line item schema across all other Fivetran billing data models.

# dbt_recharge v0.2.0
[PR #16](https://github.com/fivetran/dbt_recharge/pull/16) includes the following updates:
## Features
- For Fivetran Recharge connectors created on or after June 18, 2024, the `ORDER` source table has been renamed to `ORDERS`. The [dbt_recharge_source](https://github.com/fivetran/dbt_recharge_source) package will now use the `ORDERS` table if it exists and then `ORDER` if not.  
  - If you have both versions but wish to use the `ORDER` table instead, you can set the variable `recharge__using_orders` to false in your `dbt_project.yml`.
  - See the [June 2024 connector release notes](https://fivetran.com/docs/connectors/applications/recharge/changelog#june2024), the [dbt_recharge_source](https://github.com/fivetran/dbt_recharge_source/releases/tag/v0.2.0) release notes, and the related [README section](https://github.com/fivetran/dbt_recharge/blob/main/README.md##leveraging-orders-vs-orders-source) for more details.

## Under the Hood:
- Updated the pull request templates.
- Included auto-releaser GitHub Actions workflow to automate future releases.

# dbt_recharge v0.1.1
[PR #13](https://github.com/fivetran/dbt_recharge/pull/13) includes the following updates:
## Features
- Updated the join logic for `recharge__subscription_overview` to produce more accurate results.
- The [source package](https://github.com/fivetran/dbt_recharge_source/) model `stg_recharge__subscription_history` was updated to use the source's `updated_at` column to determine most recent record. See the source package [CHANGELOG](https://github.com/fivetran/dbt_recharge_source/blob/main/CHANGELOG.md) for more details. 

# dbt_recharge v0.1.0
🎉 This is the initial release of this package! 🎉
# 📣 What does this dbt package do?
- Produces modeled tables that leverage Recharge data from [Fivetran's connector](https://fivetran.com/docs/applications/recharge) in the format described by [this ERD](https://fivetran.com/docs/applications/recharge#schemainformation) and build off the output of our [Recharge source package](https://github.com/fivetran/dbt_recharge_source).
- Enables you to better understand your Recharge data by summarizing customer, revenue, and subscription trends.
- Generates a comprehensive data dictionary of your source and modeled Recharge data through the [dbt docs site](https://fivetran.github.io/dbt_recharge/).

For more information refer to the [README](https://github.com/fivetran/dbt_recharge/blob/main/README.md).
