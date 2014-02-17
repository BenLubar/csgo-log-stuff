# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

match = nil
match_t1p = nil
match_t2p = nil
map = nil
round = nil
round_start = nil

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
        # ignore
      when /^Started map "((?:[^\\"]|\\[\\"])*)" \(CRC "((?:[^\\"]|\\[\\"])*)"\)$/
        map = $1.split('/').last
        round = -2
	match.destroy! if match and match.rounds.empty?
        match = Match.create! start: time, map: Map.find_or_create_by!(name: map, path: $1)
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
              Player.create! first_team: true, match: match, bot: Bot.find_or_create_by!(name: $1)
              match_t1p += 1
            end
          when "CT"
            unless match_t2p > 5
              Player.create! first_team: false, match: match, bot: Bot.find_or_create_by!(name: $1)
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
	  round_start = time
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
          Round.create! start: round_start, end: time, match: match, round: round, ct_wins: 1, all_t_killed: 1, bomb_planted: bomb_planted_, hostage_reached: hostage_reached_
        when "SFUI_Notice_Terrorists_Win"
          Round.create! start: round_start, end: time, match: match, round: round, t_wins: 1, all_ct_killed: 1, bomb_planted: bomb_planted_, hostage_reached: hostage_reached_
        when "SFUI_Notice_Target_Saved"
          Round.create! start: round_start, end: time, match: match, round: round, ct_wins: 1, time_ran_out: 1, bomb_planted: bomb_planted_, hostage_reached: hostage_reached_
        when "SFUI_Notice_All_Hostages_Rescued"
          Round.create! start: round_start, end: time, match: match, round: round, ct_wins: 1, hostage_rescued: 1, bomb_planted: bomb_planted_, hostage_reached: hostage_reached_
        when "SFUI_Notice_Hostages_Not_Rescued"
          Round.create! start: round_start, end: time, match: match, round: round, t_wins: 1, time_ran_out: 1, bomb_planted: bomb_planted_, hostage_reached: hostage_reached_
        when "SFUI_Notice_Bomb_Defused"
          Round.create! start: round_start, end: time, match: match, round: round, ct_wins: 1, bomb_defused: 1, bomb_planted: bomb_planted_, hostage_reached: hostage_reached_
        when "SFUI_Notice_Target_Bombed"
          Round.create! start: round_start, end: time, match: match, round: round, t_wins: 1, bomb_detonated: 1, bomb_planted: bomb_planted_, hostage_reached: hostage_reached_
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
  puts "Processed: #{fn}"
end
