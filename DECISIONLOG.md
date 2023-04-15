# dbt_Recharge_source v0.1.0
## Billing History
- When deciding on a grain for this model, we realized there was a choice between `orders` and `charges` as they are related tables and provide similar information. We took the opinionated stance to provide this model at the `order` level when considering a single charge can be associated with multiple orders.
    - For example, if a customer places a prepaid charge that is shipped every month, that charge will be associated with multiple orders over time. If revenue is calculated solely based on the charge amount, it will overstate the revenue for the first month when the charge is made, and understate the revenue for subsequent months when the charge is not repeated. By using the orders data, orders can still be matched with the source charge. 
- Also to note, in the case of prepaid, this model does not divide portions of the initial charge amongst the related orders since this is how recharge presents the order data. As a result, we also made sure to include aggegated metrics only in the first instance of the charge. This allows data from this model to be used in downstream models or visualizations without risk of fanout. 
    - We also welcome suggestions for other situations unaccounted for in this model!

## Charge Line Item History
- Since the billing history model summarized at the order level, we also wanted to provide insight at the line item model. For this model, the charges data was used since most of the line item data, such as shipping, tax, discounts, is provided at this level by the Fivetran connector. 