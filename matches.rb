require 'sqlite3'

SQLite3::Database.new 'stats.sqlite3' do |db|
	db.query 'select map, (select sum(t_wins) from rounds where rounds.match = matches.match and rounds.round >= 1 and rounds.round <= 15) as t1s1, (select sum(ct_wins) from rounds where rounds.match = matches.match and rounds.round >= 16 and rounds.round <= 30) as t1s2, t1p1, t1p2, t1p3, t1p4, t1p5, (select sum(ct_wins) from rounds where rounds.match = matches.match and rounds.round >= 1 and rounds.round <= 15) as t2s1, (select sum(t_wins) from rounds where rounds.match = matches.match and rounds.round >= 16 and rounds.round <= 30) as t2s2, t2p1, t2p2, t2p3, t2p4, t2p5 from matches where t1s1 > 0 or t2s1 > 0 order by ts asc' do |result|
		result.each_hash do |row|
			t1 = (1..5).each.map do |i|
				row["t1p#{i}"]
			end.sort
			t2 = (1..5).each.map do |i|
				row["t2p#{i}"]
			end.sort

			puts "#{row['map'].inspect}\tT:#{row['t1s1']+(row['t2s2']||0)}\tCT:#{row['t2s1']+(row['t1s2']||0)}"
			puts "#{row['t1s1']}\t#{row['t1s2']||0}\t#{t1.join ', '}"
			puts "#{row['t2s1']}\t#{row['t2s2']||0}\t#{t2.join ', '}"
			puts
		end
	end
end
