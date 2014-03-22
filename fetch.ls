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

sql = require \mssql
fs = require \fs
moment = require \moment

# :: -> [{start-date-string :: String, billing-duration :: Int}]
get-all-params = (start-date) ->
	last-midnight = moment(moment! .format('YYYY-MM-DD'))
	last-date = last-midnight.clone! .add \days, -2
	last-billing-date = last-midnight.clone! .add \days, -1

	start-days = map (-> start-date.clone! .add \days, it), [0 to moment.duration(last-date - start-date).asDays!]
	params = map (-> [it, moment.duration(last-billing-date - it).asDays!]), start-days
	flatten <| map (([date, days])-> [{start-date-string: date.format('YYYY-MM-DD'), billing-duration: d} for d in [1 to days]]), params




query = fs.readFileSync 'queries/Billings-Per-Day.sql', 'utf8'

get-query = (start-date-string, billing-duration) ->
	aquery = query.replace '{FROM_DATE}', start-date-string
	aquery.replace '{BILLING_DURATION}', billing-duration




config =
	user: 'homam'
	password: 'gamma123'
	server: '172.30.0.165'
	database: 'Mobitrans'







sql.connect config, (err) ->
	return console.err err if !!err

	get-and-save-results = ({start-date-string, billing-duration}, callback) ->
		file-name = "data/#{start-date-string}_#{billing-duration}.json"
		if fs.existsSync file-name
			callback file-name
			return

		request = new sql.Request!

		(err, records) <- request.query (get-query start-date-string, billing-duration)
		return console.err err if !!err

		#console.log (JSON.stringify records, null, 4)

		fs.writeFileSync file-name, (JSON.stringify records, null, 4)

		console.log 'done!'

		callback file-name
		process.exit!
	
	rs <- forAllA get-and-save-results, (get-all-params moment '2014-01-01')
	console.log rs




