require 'sqlite3'

SQLite3::Database.new 'stats.sqlite3' do |db|
	db.execute 'drop table if exists matches'
	db.execute 'create table matches (
		match integer primary key,
		ts timestamp not null,
		map varchar(255) not null,
		t1p1 varchar(255),
		t1p2 varchar(255),
		t1p3 varchar(255),
		t1p4 varchar(255),
		t1p5 varchar(255),
		t2p1 varchar(255),
		t2p2 varchar(255),
		t2p3 varchar(255),
		t2p4 varchar(255),
		t2p5 varchar(255)
	)'
	db.execute 'create index matches_ts on matches (ts asc)'
	db.execute 'create index matches_map on matches (map asc)'

	db.execute 'drop table if exists rounds'
	db.execute 'create table rounds (
		ts timestamp not null,
		match integer not null references matches (match),
		round unsigned tinyint not null,
		t_wins unsigned int not null default 0,
		ct_wins unsigned int not null default 0,
		all_ct_killed unsigned int not null default 0,
		all_t_killed unsigned int not null default 0,
		hostage_reached unsigned int not null default 0,
		hostage_rescued unsigned int not null default 0,
		bomb_planted unsigned int not null default 0,
		bomb_detonated unsigned int not null default 0,
		bomb_defused unsigned int not null default 0,
		time_ran_out unsigned int not null default 0
	)'
	db.execute 'create index rounds_ts on rounds (ts asc)'
	db.execute 'create index rounds_match on rounds (match asc)'
	db.execute 'create unique index rounds_match_round on rounds (match asc, round asc)'

	match = nil
	match_t1p = nil
	match_t2p = nil
	map = nil
	round = nil

	Dir['logs/*.log'].sort.each do |fn|
		open fn do |f|
			cvars = false
			bomb_planted = false
			hostage_reached = false

			f.each_line do |l|
				if l =~ /^L ([0-9]{2})\/([0-9]{2})\/([0-9]{4,}) - ([0-9]{2}):([0-9]{2}):([0-9]{2}): /
					time = "#{$3}-#{$1}-#{$2} #{$4}:#{$5}:#{$6}"
					l = l[$&.size..-1]
				else
					p l
					raise "malformed log line"
				end

				if cvars
					next unless l =~ /^server cvars end$/
				end

				case l
				when /^Log file started \(file "((?:[^\\"]|\\[\\"])*)"\) \(game "((?:[^\\"]|\\[\\"])*)"\) \(version "((?:[^\\"]|\\[\\"])*)"\)$/
					# ignore
				when /^Log file closed$/
					# ignore
				when /^Loading map "((?:[^\\"]|\\[\\"])*)"$/
					map = $1.split('/').last
					round = -2
				when /^Started map "((?:[^\\"]|\\[\\"])*)" \(CRC "((?:[^\\"]|\\[\\"])*)"\)$/
					map = $1.split('/').last
					round = -2
					db.execute 'insert into matches (ts, map) values(?, ?)', time, map
					db.query 'select last_insert_rowid()' do |result|
						result.each do |row|
							match = row.first
						end
					end
					match_t1p = 1
					match_t2p = 1
				when /^server cvars start$/
					cvars = true
				when /^server cvars end$/
					cvars = false
				when /^server_cvar: "((?:[^\\"]|\\[\\"])*)" "((?:[^\\"]|\\[\\"])*)"$/
					# ignore
				when /^server_message: "((?:[^\\"]|\\[\\"])*)"$/
					# ignore
				when /^Your server is out of date and will be shutdown during hibernation or changelevel, whichever comes first\.$/
					# ignore
				when /^"((?:[^\\"]|\\[\\"])*)<((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)>" entered the game$/
					# ignore
				when /^"((?:[^\\"]|\\[\\"])*)<((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)>" connected, address "((?:[^\\"]|\\[\\"])*)"$/
					# ignore
				when /"((?:[^\\"]|\\[\\"])*)<((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)>" disconnected \(reason "((?:[^\\"]|\\[\\"])*)"\)$/
					# ignore
				when /^"((?:[^\\"]|\\[\\"])*)<((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)>" switched from team <((?:[^\\"]|\\[\\"])*)> to <((?:[^\\"]|\\[\\"])*)>$/
					# ignore at halftime
					if round < 0
						case $5
						when "TERRORIST"
							unless match_t1p > 5
								db.execute "update matches set t1p#{match_t1p} = ? where match = ?", $1, match
								match_t1p += 1
							end
						when "CT"
							unless match_t2p > 5
								db.execute "update matches set t2p#{match_t2p} = ? where match = ?", $1, match
								match_t2p += 1
							end
						end
					end
				when /^"((?:[^\\"]|\\[\\"])*)<((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)>" changed name to "((?:[^\\"]|\\[\\"])*)"$/
					# ignore
				when /^"((?:[^\\"]|\\[\\"])*)<((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)>" purchased "((?:[^\\"]|\\[\\"])*)"$/
					# ignore
				when /^World triggered "((?:[^\\"]|\\[\\"])*)"$/
					case event = $1
					when "Game_Commencing"
						round = -1
					when "Round_Start"
						bomb_planted = false
						hostage_reached = false
						round += 1
					when "Round_End"
						# ignore
					else
						p l
						raise "unprocessed line"
					end
				when /^World triggered "killlocation" \(attacker_position "((?:[^\\"]|\\[\\"])*)"\) \(victim_position "((?:[^\\"]|\\[\\"])*)"\)$/
					# ignore
				when /^"((?:[^\\"]|\\[\\"])*)<((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)>" triggered "weaponstats2?" .*$/
					# ignore
				when /^\[META\] .*$/
					# ignore
				when /^"((?:[^\\"]|\\[\\"])*)<((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)>" \[(-?[0-9]+) (-?[0-9]+) (-?[0-9]+)\] attacked "((?:[^\\"]|\\[\\"])*)<((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)>" \[(-?[0-9]+) (-?[0-9]+) (-?[0-9]+)\] with "((?:[^\\"]|\\[\\"])*)" \(damage "((?:[^\\"]|\\[\\"])*)"\) \(damage_armor "((?:[^\\"]|\\[\\"])*)"\) \(health "((?:[^\\"]|\\[\\"])*)"\) \(armor "((?:[^\\"]|\\[\\"])*)"\) \(hitgroup "((?:[^\\"]|\\[\\"])*)"\)$/
					# ignore
				when /^"((?:[^\\"]|\\[\\"])*)<((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)>" \[(-?[0-9]+) (-?[0-9]+) (-?[0-9]+)\] committed suicide with "((?:[^\\"]|\\[\\"])*)"$/
					# ignore
				when /^"((?:[^\\"]|\\[\\"])*)<((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)>" \[(-?[0-9]+) (-?[0-9]+) (-?[0-9]+)\] killed "((?:[^\\"]|\\[\\"])*)<((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)>" \[(-?[0-9]+) (-?[0-9]+) (-?[0-9]+)\] with "((?:[^\\"]|\\[\\"])*)"( \(headshot\))?$/
					# ignore
				when /^"((?:[^\\"]|\\[\\"])*)<((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)>" assisted killing "((?:[^\\"]|\\[\\"])*)<((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)>"$/
					# ignore
				when /^"((?:[^\\"]|\\[\\"])*)<((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)>" triggered "((?:[^\\"]|\\[\\"])*)"$/
					case event = $5
					when "headshot"
						# ignore
					when "Got_The_Bomb"
						# ignore
					when "Dropped_The_Bomb"
						# ignore
					when "Planted_The_Bomb"
						bomb_planted = true
					when "Begin_Bomb_Defuse_Without_Kit"
						# ignore
					when "Defused_The_Bomb"
						# ignore
					when "Touched_A_Hostage"
						hostage_reached = true
					when "Rescued_A_Hostage"
						# ignore
					when "round_mvp"
						# ignore
					else
						p l
						raise "unprocessed line"
					end
				when /^Team "((?:[^\\"]|\\[\\"])*)" triggered "((?:[^\\"]|\\[\\"])*)" \(CT "((?:[^\\"]|\\[\\"])*)"\) \(T "((?:[^\\"]|\\[\\"])*)"\)$/
					bomb_planted_ = 0
					if bomb_planted
						bomb_planted_ = 1
						bomb_planted = false
					end
					hostage_reached_ = 0
					if hostage_reached
						hostage_reached_ = 1
						hostage_reached = false
					end

					case event = $2
					when "SFUI_Notice_CTs_Win"
						db.execute 'insert into rounds (ts, match, round, ct_wins, all_t_killed, bomb_planted, hostage_reached) values(?, ?, ?, ?, ?, ?, ?)', time, match, round, 1, 1, bomb_planted_, hostage_reached_
					when "SFUI_Notice_Terrorists_Win"
						db.execute 'insert into rounds (ts, match, round, t_wins, all_ct_killed, bomb_planted, hostage_reached) values(?, ?, ?, ?, ?, ?, ?)', time, match, round, 1, 1, bomb_planted_, hostage_reached_
					when "SFUI_Notice_Target_Saved"
						db.execute 'insert into rounds (ts, match, round, ct_wins, time_ran_out, bomb_planted, hostage_reached) values(?, ?, ?, ?, ?, ?, ?)', time, match, round, 1, 1, bomb_planted_, hostage_reached_
					when "SFUI_Notice_All_Hostages_Rescued"
						db.execute 'insert into rounds (ts, match, round, ct_wins, hostage_rescued, bomb_planted, hostage_reached) values(?, ?, ?, ?, ?, ?, ?)', time, match, round, 1, 1, bomb_planted_, hostage_reached_
					when "SFUI_Notice_Hostages_Not_Rescued"
						db.execute 'insert into rounds (ts, match, round, t_wins, time_ran_out, bomb_planted, hostage_reached) values(?, ?, ?, ?, ?, ?, ?)', time, match, round, 1, 1, bomb_planted_, hostage_reached_
					when "SFUI_Notice_Bomb_Defused"
						db.execute 'insert into rounds (ts, match, round, ct_wins, bomb_defused, bomb_planted, hostage_reached) values(?, ?, ?, ?, ?, ?, ?)', time, match, round, 1, 1, bomb_planted_, hostage_reached_
					when "SFUI_Notice_Target_Bombed"
						db.execute 'insert into rounds (ts, match, round, t_wins, bomb_detonated, bomb_planted, hostage_reached) values(?, ?, ?, ?, ?, ?, ?)', time, match, round, 1, 1, bomb_planted_, hostage_reached_
					else
						p l
						raise "unprocessed line"
					end
				when /^Team "((?:[^\\"]|\\[\\"])*)" scored "((?:[^\\"]|\\[\\"])*)" with "((?:[^\\"]|\\[\\"])*)" players$/
					# ignore
				when /^Molotov projectile spawned at .*$/
					# ignore
				when /^"((?:[^\\"]|\\[\\"])*)<((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)>" threw (molotov|hegrenade|decoy|flashbang|smokegrenade) \[(-?[0-9]+) (-?[0-9]+) (-?[0-9]+)\]$/
					# ignore
				else
					p l
					raise "unprocessed line"
				end
			end
		end
	end
end
