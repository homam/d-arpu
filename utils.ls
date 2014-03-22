{id, Obj, map, head, concat, filter, each, find, fold, foldr, fold1, tail, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique, sort-by, reverse, empty} = require 'prelude-ls'

forAllA = (fA, arr, callback) ->
	results = []

	next = ->
		r <- fA(arr[results.length])
		results.push r
		if results.length == arr.length
			callback results
		else
			next!

	next!


moment = require \moment

# :: -> [{start-date-string :: String, billing-duration :: Int}]
get-all-params = (start-date) ->
	last-midnight = moment(moment! .format('YYYY-MM-DD'))
	last-date = last-midnight.clone! .add \days, -2
	last-billing-date = last-midnight.clone! .add \days, -1

	start-days = map (-> start-date.clone! .add \days, it), [0 to moment.duration(last-date - start-date).asDays!]
	params = map (-> [it, moment.duration(last-billing-date - it).asDays!]), start-days
	flatten <| map (([date, days])-> [{start-date-string: date.format('YYYY-MM-DD'), billing-duration: d} for d in [1 to days]]), params



exports.forAllA = forAllA
exports.get-all-params = get-all-params