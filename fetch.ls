{id, Obj, map, head, concat, filter, each, find, fold, foldr, fold1, tail, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique, sort-by, reverse, empty} = require 'prelude-ls'

{get-all-params, forAllA} = require \./utils.ls

sql = require \mssql
fs = require \fs
moment = require \moment
prompt = require \prompt
prompt.start!


query = fs.readFileSync 'queries/Billings-Per-Day.sql', 'utf8'

get-query = (start-date-string, billing-duration) ->
	aquery = query.replace '{FROM_DATE}', start-date-string
	aquery.replace '{BILLING_DURATION}', billing-duration


(err, {username, password}) <- prompt.get ['username', 'password']


config =
	user: username
	password: password
	server: '172.30.0.165'
	database: 'Mobitrans'







sql.connect config, (err) ->
	return console.err err if !!err

	get-and-save-results = ({start-date-string, billing-duration}, callback) ->
		file-name = "data/#{start-date-string}_#{billing-duration}.json"
		if fs.existsSync file-name
			console.log "alreday got", start-date-string, billing-duration
			callback file-name
			return

		console.log "getting...", start-date-string, billing-duration
		
		request = new sql.Request!

		(err, records) <- request.query (get-query start-date-string, billing-duration)
		return console.err err if !!err

		#console.log (JSON.stringify records, null, 4)

		fs.writeFileSync file-name, (JSON.stringify records, null, 4)

		console.log "got", start-date-string, billing-duration

		callback file-name
	
	rs <- forAllA get-and-save-results, (get-all-params moment '2014-01-01')
	console.log rs
	
	console.log "all done!"
	process.exit!




