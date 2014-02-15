require 'json'

# an unquoted string
string_inner = /((?:[^\\"]|\\[\\"])*)/

# a quoted string
string = /"#{string_inner}"/

# a name-id-steam-team combo
# served with a side of fries
name = /"#{string_inner}<#{string_inner}><#{string_inner}><#{string_inner}>"/

# a name-id-steam combo
# hold the team
name_1 = /"#{string_inner}<#{string_inner}><#{string_inner}>"/

# an integer coordinate
coord = /\[(-?[0-9]+) (-?[0-9]+) (-?[0-9]+)\]/

stats = {}

map = ""

Dir['logs/*.log'].sort.each do |fn|
	open fn do |f|
		cvars = false

		f.each_line do |l|
			if l =~ /^L ([0-9]{2})\/([0-9]{2})\/([0-9]{4,}) - ([0-9]{2}):([0-9]{2}):([0-9]{2}): /
				time = Time.new $3.to_i, $1.to_i, $2.to_i, $4.to_i, $5.to_i, $6.to_i
				l = l[$&.size..-1]
			else
				p l
				raise "malformed log line"
			end

			if cvars
				next unless l =~ /^server cvars end$/
			end

			case l
			when /^Log file started \(file #{string}\) \(game #{string}\) \(version #{string}\)$/
				# ignore
			when /^Log file closed$/
				# ignore
			when /^Loading map #{string}$/
				map = $1.split('/').last
			when /^Started map #{string} \(CRC #{string}\)$/
				map = $1.split('/').last
			when /^server cvars start$/
				cvars = true
			when /^server cvars end$/
				cvars = false
			when /^server_cvar: #{string} #{string}$/
				# ignore
			when /^server_message: #{string}$/
				# ignore
			when /^Your server is out of date and will be shutdown during hibernation or changelevel, whichever comes first\.$/
				# ignore
			when /^#{name} entered the game$/
				# ignore
			when /^#{name} connected, address #{string}$/
				# ignore
			when /#{name} disconnected \(reason #{string}\)$/
				# ignore
			when /^#{name_1} switched from team <#{string_inner}> to <#{string_inner}>$/
				# ignore
			when /^#{name} purchased #{string}$/
				# ignore
			when /^World triggered #{string}$/
				case event = $1
				when "Game_Commencing"
					# ignore
				when "Round_Start"
					# ignore
				when "Round_End"
					# ignore
				else
					p l
					raise "unprocessed line"
				end
			when /^World triggered "killlocation" \(attacker_position #{string}\) \(victim_position #{string}\)$/
				# ignore
			when /^#{name} triggered "weaponstats2?" .*$/
				# ignore
			when /^\[META\] .*$/
				# ignore
			when /^#{name} #{coord} attacked #{name} #{coord} with #{string} \(damage #{string}\) \(damage_armor #{string}\) \(health #{string}\) \(armor #{string}\) \(hitgroup #{string}\)$/
				# ignore
			when /^#{name} #{coord} committed suicide with #{string}$/
				# ignore
			when /^#{name} #{coord} killed #{name} #{coord} with #{string}( \(headshot\))?$/
				# ignore
			when /^#{name} assisted killing #{name}$/
				# ignore
			when /^#{name} triggered #{string}$/
				case event = $5
				when "headshot"
					# ignore
				when "Got_The_Bomb"
					# ignore
				when "Dropped_The_Bomb"
					# ignore
				when "Planted_The_Bomb"
					# ignore
				when "Begin_Bomb_Defuse_Without_Kit"
					# ignore
				when "Defused_The_Bomb"
					# ignore
				when "Touched_A_Hostage"
					# ignore
				when "Rescued_A_Hostage"
					# ignore
				when "round_mvp"
					# ignore
				else
					p l
					raise "unprocessed line"
				end
			when /^Team #{string} triggered #{string} \(CT #{string}\) \(T #{string}\)$/
				stats[map] = {
					ct_win: 0,
					t_win: 0,
					hostage_rescued: 0,
					bomb_detonated: 0,
					bomb_defused: 0,
					time_ran_out: 0
				} if stats[map].nil?

				case event = $2
				when "SFUI_Notice_CTs_Win"
					stats[map][:ct_win] += 1
				when "SFUI_Notice_Terrorists_Win"
					stats[map][:t_win] += 1
				when "SFUI_Notice_Target_Saved"
					stats[map][:time_ran_out] += 1
				when "SFUI_Notice_All_Hostages_Rescued"
					stats[map][:hostage_rescued] += 1
				when "SFUI_Notice_Hostages_Not_Rescued"
					stats[map][:time_ran_out] += 1
				when "SFUI_Notice_Bomb_Defused"
					stats[map][:bomb_defused] += 1
				when "SFUI_Notice_Target_Bombed"
					stats[map][:bomb_detonated] += 1
				else
					p l
					raise "unprocessed line"
				end
			when /^Team #{string} scored #{string} with #{string} players$/
				# ignore
			when /^Molotov projectile spawned at .*$/
				# ignore
			when /^#{name} threw (molotov|hegrenade|decoy|flashbang|smokegrenade) #{coord}$/
				# ignore
			else
				p l
				raise "unprocessed line"
			end
		end
	end
end

puts JSON.pretty_generate stats
