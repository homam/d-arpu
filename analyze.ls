{id, Obj,map, concat, mean, filter, head, each, take, find, fold, foldr, fold1, tail, any, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique, sort-by, reverse, empty} = require 'prelude-ls'
{get-all-params, forAllA_} = require \./utils.ls
moment = require \moment
fs = require \fs


console.log 'run it only once!'
return

db = require("mongojs").connect \arpu, [\records]



save = ({start-date-string, billing-duration}, callback) ->
	file-name = "./data/#{start-date-string}_#{billing-duration}.json"
	if not fs.existsSync file-name
		callback!
		return
	(_, raw) <- fs.readFile file-name
	data = JSON.parse raw
	console.log start-date-string, billing-duration, data.length
	records = map ((d)-> 
		d.SubscriptionDate = new Date(start-date-string)
		d.SubscriptionDateString = start-date-string
		d.BillingDuration = billing-duration
		d
	), data
	(err, saved) <- db.records.insert records
	if not err
		callback!
	else
		console.log err


_ <- forAllA_ save, get-all-params moment '2014-01-01'

console.log 'all saved'


#db.records.find((err, records) -> console.log <| sum <| map (.Subscribers), records)



#query = {SubscriptionDate: {$gt: new Date('2014-01-01'), $lt: new Date('2014-01-15')}, BillingDuration: 75, Category: 'Android', Country: 'UAE'}
#db.records.find query, ((err, res) -> console.log <| [(map-sum (.Billings), res) / (map-sum (.Subscribers), res), (map-sum (.Subscribers), res)] )
#db.records.find {SubscriptionDateString: '2014-01-03', BillingDuration: 50, Category: 'Android', Country: 'UAE'}, ((err, res) -> console.log <| [(map-sum (.Billings), res) / (map-sum (.Subscribers), res), (map-sum (.Subscribers), res)] )
# db.records.aggregate {$group: { _id: "$BillingDuration", totalProp: { $sum: "$Subscribers"}}}, ((err, res) -> console.log res) 

# db.records.aggregate ({$group: { _id: "$CampaignId", totalProp: { $sum: "$Subscribers"}}}, {$sort: {Subscribers: 1}}), ((err, res) -> console.log res) 

# db.users.aggregate(
#   [
#   	{ $match: {BillingDuration: 1}}
#     { $project : { CampaignId : 1, Subscribers: 1 } } ,
#     { $group : { _id : {CampaignId:"$CampaignId"} , Subscribers : { $sum : "$Subscribers" } } }
#   ]
# , (err, res) -> console.log res)
