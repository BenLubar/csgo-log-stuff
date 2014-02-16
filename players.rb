require 'sqlite3'

SQLite3::Database.new 'stats.sqlite3' do |db|
	db.query 'select p, sum(s) as score from (select p, (select sum(t_wins) from rounds where rounds.match = m and rounds.round >= 1 and rounds.round <= 15)+(select sum(ct_wins) from rounds where rounds.match = m and rounds.round >= 16 and rounds.round <= 30) as s from (select match as m, t1p1 as p from matches union select match as m, t1p2 as p from matches union select match as m, t1p3 as p from matches union select match as m, t1p4 as p from matches union select match as m, t1p5 as p from matches) union select p, (select sum(ct_wins) from rounds where rounds.match = m and rounds.round >= 1 and rounds.round <= 15)+(select sum(t_wins) from rounds where rounds.match = m and rounds.round >= 16 and rounds.round <= 30) as s from (select match as m, t2p1 as p from matches union select match as m, t2p2 as p from matches union select match as m, t2p3 as p from matches union select match as m, t2p4 as p from matches union select match as m, t2p5 as p from matches)) where p is not null group by p order by score asc' do |result|
		result.each_hash do |row|
			puts "#{row['p']}: #{row['score']} wins"
		end
	end
end
