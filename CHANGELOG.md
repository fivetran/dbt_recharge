# dbt_Recharge_source v0.1.1
[PR #13](https://github.com/fivetran/dbt_recharge/pull/13) includes the following updates:
## Features
- Updated the join logic for `recharge__subscription_overview` to produce more accurate results.
- The [source package](https://github.com/fivetran/dbt_recharge_source/) model `stg_recharge__subscription_history` was updated to use the source's `updated_at` column to determine most recent record. See the source package [CHANGELOG](https://github.com/fivetran/dbt_recharge_source/blob/main/CHANGELOG.md) for more details. 

# dbt_Recharge_source v0.1.0
🎉 This is the initial release of this package! 🎉
# 📣 What does this dbt package do?
- Produces modeled tables that leverage Recharge data from [Fivetran's connector](https://fivetran.com/docs/applications/recharge) in the format described by [this ERD](https://fivetran.com/docs/applications/recharge#schemainformation) and build off the output of our [Recharge source package](https://github.com/fivetran/dbt_recharge_source).
- Enables you to better understand your Recharge data by summarizing customer, revenue, and subscription trends.
- Generates a comprehensive data dictionary of your source and modeled Recharge data through the [dbt docs site](https://fivetran.github.io/dbt_recharge/).

For more information refer to the [README](https://github.com/fivetran/dbt_recharge/blob/main/README.md).
