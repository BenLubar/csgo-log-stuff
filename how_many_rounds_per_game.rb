require 'sqlite3'
require 'json'

SQLite3::Database.new 'stats.sqlite3' do |db|
	db.query 'select * from (select map, round, (count(1)-(select count(1) from rounds as r2 where r1.map=r2.map and r1.round=r2.round-1)) as c from rounds as r1 group by map, round order by map asc, round asc) where c != 0 order by map asc, round asc' do |result|
		result.each do |row|
			puts "Map:#{row[0]} Rounds:#{row[1]} Count:#{row[2]}"
		end
	end
end
