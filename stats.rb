require 'json'

stats = {}

map = ""
round = 0

Dir['logs/*.log'].sort.each do |fn|
	open fn do |f|
		cvars = false
		bomb_planted = false
		hostage_reached = false

		f.each_line do |l|
			if l =~ /^L ([0-9]{2})\/([0-9]{2})\/([0-9]{4,}) - ([0-9]{2}):([0-9]{2}):([0-9]{2}): /
				#time = Time.new $3.to_i, $1.to_i, $2.to_i, $4.to_i, $5.to_i, $6.to_i
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
				round = 0
			when /^Started map "((?:[^\\"]|\\[\\"])*)" \(CRC "((?:[^\\"]|\\[\\"])*)"\)$/
				map = $1.split('/').last
				round = 0
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
				# ignore
			when /^"((?:[^\\"]|\\[\\"])*)<((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)>" changed name to "((?:[^\\"]|\\[\\"])*)"$/
				# ignore
			when /^"((?:[^\\"]|\\[\\"])*)<((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)><((?:[^\\"]|\\[\\"])*)>" purchased "((?:[^\\"]|\\[\\"])*)"$/
				# ignore
			when /^World triggered "((?:[^\\"]|\\[\\"])*)"$/
				case event = $1
				when "Game_Commencing"
					# ignore
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
				stats[map] = {
					t_wins: 0,
					ct_wins: 0,
					all_ct_killed: 0,
					all_t_killed: 0,
					hostage_reached: 0,
					hostage_rescued: 0,
					bomb_planted: 0,
					bomb_detonated: 0,
					bomb_defused: 0,
					time_ran_out: 0
				} if stats[map].nil?

				if bomb_planted
					stats[map][:bomb_planted] += 1
					bomb_planted = false
				end
				if hostage_reached
					stats[map][:hostage_reached] += 1
					hostage_reached = false
				end

				case event = $2
				when "SFUI_Notice_CTs_Win"
					stats[map][:all_t_killed] += 1
					stats[map][:ct_wins] += 1
				when "SFUI_Notice_Terrorists_Win"
					stats[map][:all_ct_killed] += 1
					stats[map][:t_wins] += 1
				when "SFUI_Notice_Target_Saved"
					stats[map][:time_ran_out] += 1
					stats[map][:ct_wins] += 1
				when "SFUI_Notice_All_Hostages_Rescued"
					stats[map][:hostage_rescued] += 1
					stats[map][:ct_wins] += 1
				when "SFUI_Notice_Hostages_Not_Rescued"
					stats[map][:time_ran_out] += 1
					stats[map][:t_wins] += 1
				when "SFUI_Notice_Bomb_Defused"
					stats[map][:bomb_defused] += 1
					stats[map][:ct_wins] += 1
				when "SFUI_Notice_Target_Bombed"
					stats[map][:bomb_detonated] += 1
					stats[map][:t_wins] += 1
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

puts JSON.pretty_generate stats
