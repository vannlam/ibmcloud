import json, requests, calendar, os, pandas as pd
from ibm_platform_services import UsageReportsV4, ResourceManagerV2, ResourceControllerV2

def treat_tags(tag_list):
    result = {}
    for tag in tag_list:
        if ":" in tag:
            split = tag.split(":")
            result[split[0]] = split[1]
        else:
            result[tag]=""
    return result

def float_equal(a, b):
    return a - b < 1e-9

focus_template = {
    "AvailabilityZone" : "",
    "BilledCost" : "", #
    "BillingAccountID" : "", #
    "BillingAccountName" : "", #
    "BillingCurrency" : "", #
    "BillingPeriodEnd" : "",
    "BillingPeriodStart" : "",
    "ChargeCategory" : "",
    "ChargeDescription" : "",
    "ChargeFrequency" : "",
    "ChargePeriodEnd" : "",
    "ChargePeriodStart" : "",
    "ChargeSubcategory" : "",
    "CommitmentDiscountCategory" : "",
    "CommitmentDiscountID" : "", #
    "CommitmentDiscount Name" : "", #
    "CommitmentDiscountType" : "", #
    "EffectiveCost" : "",
    "InvoiceIssuer" : "IBM",
    "ListCost" : "", #
    "ListUnitPrice" : "", #
    "PricingCategory" : "", 
    "PricingQuantity" : "", #
    "PricingUnit" : "", #
    "Provider" : "IBM",
    "Publisher" : "IBM",
    "Region" : "", #
    "ResourceID" : "", #
    "ResourceName" : "", #
    "ResourceType" : "",
    "ServiceCategory" : "",
    "ServiceName" : "",
    "SKUID" : "",
    "SKUPriceID" : "",
    "SubAccountID" : "",
    "SubAccountName" : "",
    "Tags" : "", #
    "UsageQuantity" : "",
    "UsageUnit" : "", #
}

account_id      = os.environ.get("ACCOUNT_ID")
billing_month   = os.environ.get("BILLING_MONTH")
api_key         = os.environ.get('API_KEY')
year            = int(billing_month.split("-")[0])
month           = int(billing_month.split("-")[1])
month_range     = calendar.monthrange(year, month)
auth_endpoint   = 'https://iam.cloud.ibm.com/identity/token?grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey='

usage_report_client         = UsageReportsV4.new_instance()
resource_manager_client     = ResourceManagerV2.new_instance()
resource_controller_service = ResourceControllerV2.new_instance()

focus_output        = []
resource_id_dict    = {}
resource_group_dict = {}
account_name_dict   = {}

BillingAccountID    = account_id
resource_usage      = usage_report_client.get_resource_usage_account(account_id = account_id, billingmonth = billing_month, limit = 200).get_result()
account_summary     = usage_report_client.get_account_summary(account_id = account_id, billingmonth = billing_month).get_result()

# Get Athenticate token
token = requests.post(auth_endpoint + api_key)
token = json.loads(token._content.decode())["access_token"]

# Get Account Names
url         = "https://accounts.cloud.ibm.com/v1/accounts"
headers     = {
    "Accept": "application/json",
    "Authorization": token,
    "Content-Type":"application/json"
}
response    = json.loads(requests.get(url, headers=headers)._content.decode())

for resource in response["resources"]:
    account_name_dict[resource["metadata"]["guid"]] = resource["entity"]["name"]

# Get Resource Groups names
for resource in account_summary["account_resources"]:
    resource_id_dict[resource["resource_id"]] = resource["resource_name"]

# Debug: Checking get_resource_usage_account output
# print(json.dumps(resource_usage, indent='\t'))
# with open('result.json', 'w') as f:
#     json.dump(resource_usage, f, indent='\t')

#Iterating resource usage output
while (True):
    for resource in resource_usage["resources"]:
        focus_item = focus_template.copy()
        focus_item["BillingAccountID"]          = resource.get("account_id")
        focus_item["BillingAccountName"]        = account_name_dict.get(resource.get("account_id"))
        focus_item["BillingCurrency"]           = resource.get("currency_code")
        focus_item["Region"]                    = resource.get("region")
        focus_item["ResourceID"]                = resource.get("resource_instance_id")

        focus_item["ChargeCategory"]                = "Usage"
        focus_item["ChargeSubcategory"]             = "On-Demand"
        focus_item["ChargeFrequency"]               = "Recurring"
        focus_item["PricingCategory"]               = "On-Demand"

        

        resource_instance_detail            = resource_controller_service.get_resource_instance(id=focus_item["ResourceID"]).get_result()
        focus_item["ResourceName"]          = resource_instance_detail.get("name")
        focus_item["ResourceType"]          = resource_instance_detail.get("type")

        focus_item["BillingPeriodStart"]    = billing_month + "-" + str(month_range[0]) + "T00:00:00.000Z"
        focus_item["BillingPeriodEnd"]      = billing_month + "-" + str(month_range[1]) + "T00:00:00.000Z"

        focus_item["ChargePeriodStart"]    = focus_item["BillingPeriodStart"]
        focus_item["ChargePeriodEnd"]      = focus_item["BillingPeriodEnd"]

        focus_item["Tags"] = treat_tags(resource.get("tags")) if resource.get("tags") else ""
        for usage in resource.get("usage"):
            focus_item_usage = focus_item.copy()
            focus_item_usage["UsageUnit"]       = usage.get("unit").upper()
            focus_item_usage["UsageQuantity"]   = usage.get("quantity")
            focus_item_usage["PricingUnit"]     = usage.get("unit").upper()
            focus_item_usage["PricingQuantity"] = usage.get("quantity")
            focus_item_usage["BilledCost"]      = usage.get("cost")
            focus_item_usage["EffectiveCost"]   = usage.get("cost")
            focus_item_usage["ServiceName"]     = resource_id_dict[resource.get("resource_id")]

            # Deduce Unit Price
            if len(usage.get("price")) == 1:
                focus_item_usage["ListUnitPrice"] = usage["price"][0].get("price")
            elif float_equal(usage.get("quantity"),0):
                focus_item_usage["ListUnitPrice"] = 0
            else:
                focus_item_usage["ListUnitPrice"] = usage.get("cost")/usage.get("quantity")

            focus_item_usage["ListCost"]        = focus_item_usage["ListUnitPrice"] * usage.get("quantity")
                
            # Get Discount information
            if usage.get("discounts"):
                #TODO: Merge multi-discount later
                focus_item_usage["CommitmentDiscountID"]    = usage.get("discounts")[0]["ref"]
                focus_item_usage["CommitmentDiscountName"]  = usage.get("discounts")[0]["name"]
                focus_item["CommitmentDiscountCategory"]    = "Usage"

            # Get Subaccount (Resource Group) information
            if "resource_group_id" in resource:
                focus_item_usage["SubAccountID"]    = resource["resource_group_id"]
                if (resource["resource_group_id"] not in resource_group_dict.keys()):
                    resource_group                                      = resource_manager_client.get_resource_group(id=resource["resource_group_id"]).get_result()
                    resource_group_dict[resource["resource_group_id"]]  = resource_group["name"]
                focus_item_usage["SubAccountName"]  = resource_group_dict[resource["resource_group_id"]]

            focus_output.append(focus_item_usage)

    #Paging through the API
    if 'next' not in resource_usage.keys():
        break
    resource_usage = usage_report_client.get_resource_usage_account(account_id = account_id, billingmonth = billing_month, limit = 200, start=resource_usage['next']['offset']).get_result()

focus_json = json.dumps(focus_output)

df = pd.read_json(focus_json)
df.to_csv('IBM_Cloud-FOCUS.csv', encoding='utf-8', index=False)
