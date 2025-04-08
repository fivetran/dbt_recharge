# dbt_recharge v0.3.1
[PR #26](https://github.com/fivetran/dbt_recharge/pull/26) includes the following changes:

- For Quickstart users, removed `recharge__line_item_enhanced` from the public models list in `quickstart.yml` since the model is disabled by default.
- In `recharge__charge_line_item_history`, updated the discounts section to pull directly from the `charges` table. This is because we are currently unable to determine discounts on a charge_line level. Therefore, we have decided to maintain discounts at the charge level. In a future release, we may re-examine calculating discounts on the charge_line level when we have more complete data.

## Documentation
- Added Quickstart model counts to README. ([#22](https://github.com/fivetran/dbt_recharge/pull/22))
- Corrected references to connectors and connections in the README. ([#22](https://github.com/fivetran/dbt_recharge/pull/22))

# dbt_recharge v0.3.0
[PR #17](https://github.com/fivetran/dbt_recharge/pull/17) includes the following updates:

## Features
- Addition of the `recharge__line_item_enhanced` model. This model constructs a comprehensive, denormalized analytical table that enables reporting on key revenue, subscription, customer, and product metrics from your billing platform. It’s designed to align with the schema of the `*__line_item_enhanced` model found in Recharge, Recurly, Stripe, Shopify, and Zuora, offering standardized reporting across various billing platforms. To see the kinds of insights this model can generate, explore example visualizations in the [Fivetran Billing Model Streamlit App](https://fivetran-billing-model.streamlit.app/). Visit the app for more details.
  - This model is currently disabled by default. You may enable it by setting the `recharge__standardized_billing_model_enabled` as `true` in your `dbt_project.yml`.

## Breaking Changes
- In the [dbt_recharge_source v0.3.0 release](https://github.com/fivetran/dbt_recharge_source/releases/tag/v0.3.0), the following columns were added to model `stg_recharge__address`:
  - `country`
  - `payment_method_id`
  - Note: If you have already added any of these fields as passthrough columns to the `recharge__address_passthrough_columns` var, you will need to remove or alias these fields from the var to avoid duplicate column errors.

## Additional source package updates ([release notes](https://github.com/fivetran/dbt_recharge_source/releases/tag/v0.3.0))
- Added staging model `stg_recharge__checkout`. See [this doc](https://fivetran.github.io/dbt_recharge/#!/model/model.recharge_source.stg_recharge__checkout) for the fields added and their definitions.
  - This model is disabled by default but can be enabled by setting variable `recharge__checkout_enabled` to true in your `dbt_project.yml` file. See the [Enable/disable models and sources section](https://github.com/fivetran/dbt_recharge/blob/main/README.md#step-4-enable-disable-models-and-sources) of the README for more information.
  - This model can also be passed additional columns beyond the predefined columns by using the variable `recharge__checkout_passthrough_columns`. See the [Passing Through Additional Columns](https://github.com/fivetran/dbt_recharge/blob/main/README.md#passing-through-additional-columns) section of the README for more information on how to set this variable.

- Added the following columns to model `stg_recharge__customer`. See [this doc](https://fivetran.github.io/dbt_recharge/#!/model/model.recharge_source.stg_recharge__customer) for field definitions.
  - `billing_first_name`
  - `billing_last_name`
  - `billing_company`
  - `billing_city`
  - `billing_country`

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
