require 'sqlite3'
require 'json'

SQLite3::Database.new 'stats.sqlite3' do |db|
	stats = {}

	db.query 'select map, sum(t_wins), sum(ct_wins), sum(all_ct_killed), sum(all_t_killed), sum(hostage_reached), sum(hostage_rescued), sum(bomb_planted), sum(bomb_detonated), sum(bomb_defused), sum(time_ran_out) from rounds join matches on rounds.match = matches.match group by map order by map asc' do |result|
		result.each_hash do |row|
			map = stats[row['map']] = {}
			row.each do |k, v|
				if k =~ /\Asum\((.*)\)\z/
					map[$1] = v
				end
			end
		end
	end

	puts JSON.pretty_generate stats
end
