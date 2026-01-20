# dbt_recharge v1.4.0

[PR #44](https://github.com/fivetran/dbt_recharge/pull/44) includes the following updates:

## Documentation
- Updates README with standardized Fivetran formatting.

## Under the Hood
- In the `quickstart.yml` file:
  - Adds `table_variables` for relevant sources to prevent missing sources from blocking downstream Quickstart models.
  - Adds `supported_vars` for Quickstart UI customization.

# dbt_recharge v1.3.0

[PR #43](https://github.com/fivetran/dbt_recharge/pull/43) includes the following updates:

## Features
  - Increases the required dbt version upper limit to v3.0.0

# dbt_recharge v1.2.0

[PR #41](https://github.com/fivetran/dbt_recharge/pull/41) includes the following updates:

## Schema/Data Change
**1 total change • 0 possible breaking changes**

| Data Model(s) | Change type | Old | New | Notes |
| ------------- | ----------- | ----| --- | ----- |
| All models | New column | | `source_relation` | Identifies the source connection when using multiple Recharge connections |

## Feature Update
- **Union Data Functionality**: This release supports running the package on multiple Recharge source connections. See the [README](https://github.com/fivetran/dbt_recharge/tree/main?tab=readme-ov-file#step-3-define-database-and-schema-variables) for details on how to leverage this feature.

## Tests Update
- Removes uniqueness tests. The new unioning feature requires combination-of-column tests to consider the new `source_relation` column in addition to the existing primary key, but this is not supported across dbt versions.
- These tests will be reintroduced once a version-agnostic solution is available.

## Under the Hood
- Refactored `int_recharge__calendar_spine` to include compile-time guards and determine spine boundaries from `ref('stg_recharge__charge_tmp')` instead of direct source reference, enabling compatibility when unioning multiple sources.

# dbt_recharge v1.1.0
This release aligns with the [Fivetran Recharge Connector August 2025](https://fivetran.com/docs/changelog/2025/august-2025#recharge) updates. [PR #35](https://github.com/fivetran/dbt_recharge/pull/35) includes the following updates:

## Schema/Data Changes

**3 total changes • 3 possible breaking changes**
| **Data Model/Column** | **Change type** | **Old** | **New** | **Notes** |
| --------------------- | --------------- | ------- |-------- | --------- |
| `ORDER` | Source removed | | | Sunset in favor of `ORDERS`, which is now standard across all connections. |
| [`stg_recharge__discount`](https://fivetran.github.io/dbt_recharge/#!/model/model.recharge.stg_recharge__discount) | Column removed | `applies_to_id` | | Removed due to inconsistent data types (JSON vs. string) in the source. It can be re-enabled via the newly added `recharge__discount_passthrough_columns` variable. See the [Passing Through Additional Columns](https://github.com/fivetran/dbt_recharge/blob/main/README.md#passing-through-additional-columns) section in the README for usage details. |
| [`stg_recharge__one_time_product`](https://fivetran.github.io/dbt_recharge/#!/model/model.recharge.stg_recharge__one_time_product)<br>[`stg_recharge__order`](https://fivetran.github.io/dbt_recharge/#!/model/model.recharge.stg_recharge__order)<br>[`recharge__billing_history`](https://fivetran.github.io/dbt_recharge/#!/model/model.recharge.recharge__billing_history) | Column removed | `is_deleted` | | Removed deprecated column. The same information is already captured in `_fivetran_deleted`. |

## Documentation
- Removed deprecated source and columns from documentation.

## Under the Hood
- Removed deprecated source and columns from testing seed files.
- Removed deprecated source and columns from `get_*_column` macros.

# dbt_recharge v1.0.0

[PR #34](https://github.com/fivetran/dbt_recharge/pull/34) includes the following updates:

## Breaking Changes

### Source Package Consolidation
- Removed the dependency on the `fivetran/recharge_source` package.
  - All functionality from the source package has been merged into this transformation package for improved maintainability and clarity.
  - If you reference `fivetran/recharge_source` in your `packages.yml`, you must remove this dependency to avoid conflicts.
  - Any source overrides referencing the `fivetran/recharge_source` package will also need to be removed or updated to reference this package.
  - Update any recharge_source-scoped variables to be scoped to only under this package. See the [README](https://github.com/fivetran/dbt_recharge/blob/main/README.md) for how to configure the build schema of staging models.
- As part of the consolidation, vars are no longer used to reference staging models, and only sources are represented by vars. Staging models are now referenced directly with `ref()` in downstream models.

### dbt Fusion Compatibility Updates
- Updated package to maintain compatibility with dbt-core versions both before and after v1.10.6, which introduced a breaking change to multi-argument test syntax (e.g., `unique_combination_of_columns`).
- Temporarily removed unsupported tests to avoid errors and ensure smoother upgrades across different dbt-core versions. These tests will be reintroduced once a safe migration path is available.
  - Removed all `dbt_utils.unique_combination_of_columns` tests.
  - Removed all `accepted_values` tests.
  - Moved `loaded_at_field: _fivetran_synced` under the `config:` block in `src_recharge.yml`.

### Under the Hood
- Updated conditions in `.github/workflows/auto-release.yml`.
- Added `.github/workflows/generate-docs.yml`.

# dbt_recharge v0.5.0

[PR #31](https://github.com/fivetran/dbt_recharge/pull/31) includes the following changes:

## Schema & Data Updates
**4 new columns -- 2 deprecated columns -- 6 potential breaking changes introduced in the upstream [v0.4.0 dbt_recharge_source release](https://github.com/fivetran/dbt_recharge_source/releases/tag/v0.4.0)**

| Data Model                                                                                                                                               | Change Type | Old Name                     | New Name                                             | Notes                                                                                    |
| -------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- | ---------------------------- | ---------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `stg_recharge__one_time_product`             | Deprecated column | `_is_deleted`  |  `_is_deleted`  | The column will continue to persist for the time being, but we encourage referencing the `_fivetran_deleted` column in its place.    |
| `stg_recharge__one_time_product`             | New column | `_fivetran_deleted`  |   | Boolean created by Fivetran to indicate whether the record has been deleted. | 
| `stg_recharge__order`             | Deprecated column | `_is_deleted`  |  `_is_deleted`  | The column will continue to persist for the time being, but we encourage referencing the `_fivetran_deleted` column in its place.    |
| `stg_recharge__order`             | New column | `_fivetran_deleted`  |   | Boolean created by Fivetran to indicate whether the record has been deleted. **For dbt Core users: If this field is included in the `recharge__order_passthrough_columns` variable. It will need to be removed in order to avoid duplicate column compilation failures.**  | 
| `stg_recharge__charge`             | New column | `_fivetran_deleted`  |   | Boolean created by Fivetran to indicate whether the record has been deleted. **For dbt Core users: If this field is included in the `recharge__charge_passthrough_columns` variable. It will need to be removed in order to avoid duplicate column compilation failures.**  | 
| `stg_recharge__customer`             | New column | `_fivetran_deleted`  |   | Boolean created by Fivetran to indicate whether the record has been deleted. | 


## Bug Fixes
- Updated `recharge__billing_history` to cast `orders.is_prepaid` as an integer and evaluate the result, ensuring compatibility with integer-based booleans as well as boolean data types.

## Documentation
- Added all new column documentation in the relevant recharge.yml file.
- Updated all the deprecated column documentation in the relevant recharge.yml file.
- Added column documentation for the `billing_*` fields related to the `CUSTOMER` source, staging, and end models.

## Under the Hood
- Added a new `ORDERS` seed data file to properly test cases where `is_prepaid` is either a boolean or integer.
- Included relevant updates to the impacted seed files for integration tests.
- Introduced the generate-docs github workflow for consistent docs generation.
- Created `consistency_billing_history` and `consistency_customer_details` validation tests.

# dbt_recharge v0.4.0
[PR #28](https://github.com/fivetran/dbt_recharge/pull/28) includes the following changes:

## Schema/Data Changes
**1 total change • 0 possible breaking changes**
| **Data Model** | **Change type** | **Old name** | **New name** | **Notes** |
| ---------------- | --------------- | ------------ | ------------ | --------- |
| [`recharge__line_item_enhanced`](https://fivetran.github.io/dbt_recharge/#!/model/model.recharge.recharge__line_item_enhanced) | Modified Model | | | Now enabled by default. |

## Features
- Enabled the `recharge__line_item_enhanced` model by default. Previously, this model required opting in via the `recharge__standardized_billing_model_enabled` variable. This change ensures the model is available by default for Quickstart users.
  - Users can still disable the model by setting the variable to `false` in `dbt_project.yml`.

# dbt_recharge v0.3.1
[PR #27](https://github.com/fivetran/dbt_recharge/pull/27) includes the following changes:

## Bug Fixes
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
