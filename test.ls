{id, Obj, map, head, concat, filter, each, find, fold, foldr, fold1, tail, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique, sort-by, reverse, empty} = require 'prelude-ls'

db = require("mongojs").connect \arpu, [\records]

# (err, res) <- db.records.aggregate [
# 	* $match: BillingDuration: 1, Country: 'UAE'
# 	* $project: CampaignId: 1, Subscribers: 1, Visits: 1
# 	* $group: _id : { CampaignId: "$CampaignId" }, Subscribers : { $sum: "$Subscribers" }, Visits: { $sum: "$Visits" }
# 	* $sort: Subscribers: 1,
# 	* $project: {CampaignId: "$_id.CampaignId", Subscribers: 1, Visits: 1, _id: 0}
# ]

# console.log res;

# return

(err, res) <- db.records.aggregate [
	* $match: {CampaignId: 2868}
	* $project: Subscribers: 1, Visits: 1, Billings: 1, BillingDuration: 1, Category: 1
	* $group: _id : { BillingDuration: "$BillingDuration", Category: "$Category" }, Visits: { $sum: "$Visits" }, Subscribers: { $sum: "$Subscribers" }, Billings: { $sum: "$Billings" }
	* $sort: _id: 1
]

res = res |> map (-> day: it._id.BillingDuration, category: it._id.Category, visit: it.Visits, subscribers: it.Subscribers, billings: it.Billings)
res = group-by (.category), res

console.log res
return


# (err, res) <- db.records.aggregate [
# 	* $match: BillingDuration: 1
# 	* $project: Subscribers: 1, Category: 1, Service: 1
# 	* $group: _id : { Service: "$Service", Category: "$Category" }, Subscribers: { $sum: "$Subscribers" }
# 	* $sort: Subscribers: 1
# ]


console.log res
	