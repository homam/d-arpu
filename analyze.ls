{id, Obj,map, concat, mean, filter, head, each, take, find, fold, foldr, fold1, tail, any, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique, sort-by, reverse, empty} = require 'prelude-ls'
{get-all-params, forAllA} = require \./utils.ls
moment = require \moment
fs = require \fs




databaseUrl = \arpu
collections = [\records]
db = require("mongojs").connect databaseUrl, collections



save = ({start-date-string, billing-duration}, callback) ->
	file-name = "./data/#{start-date-string}_#{billing-duration}.json"
	if not fs.existsSync file-name
		callback!
		return
	data = require file-name
	console.log "data", data.length
	_ <- forAllA ((d, callback)-> 
		d.SubscriptionDate = new Date(start-date-string)
		d.SubscriptionDateString = start-date-string
		d.BillingDuration = billing-duration
		(err, saved) <- db.records.save d 
		console.log err, saved
		callback {err, saved}
	), data
	callback!


# _ <- forAllA save, get-all-params moment '2014-01-01'


#db.records.find((err, records) -> console.log <| sum <| map (.Subscribers), records)
(err, records) <- db.records.find! 
filtered-records = records |> (filter (-> it.Category == 'Rest' and it.BillingDuration == 1))
subscribers = records |> (filter (-> it.Category == 'Rest')) >> (map (.Subscribers)) >> sum
first-billings = filtered-records |> (map (-> it.Billings * it.Subscribers / subscribers)) >> sum

console.log subscribers
console.log first-billings

