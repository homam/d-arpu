use arpu

db.records.aggregate([{$match: {BillingDuration: 45, Country: 'Iraq' ,Subscribers: { $gt: 1 }}},  {$group: {_id: {category: "$Category"}, subscribers: { $sum:  "$Subscribers" },
billings: { $sum: "$Billings"}, active: { $sum: "$Active"} }},  {$sort: {subscribers: -1}}  ]).result.map(function(a) { return {group: a._id.category, subs: a.subscribers,  bps: a.
billings/a.subscribers, active: a.active/a.subscribers}; });
