$stdout.sync = true
# puts "-------------require-------------"

require 'sqlite3'
# puts "-------------Database.new-------------"

db2 =SQLite3::Database.new("audio-collins3.sqlite3")
# select * from audios order by content limit 10 offset 1000;
# puts "-------------execute SQL-------------"
played = false

db2.execute( "SELECT * FROM audios ORDER BY random() LIMIT 10" ) do |row|
#db2.execute( "select * from audios order by content limit 10 offset 1000;" ) do |row|
    content = row[0]
    audio = row[1]
    explanation = row[2]
    # puts "-------------begin-------------"
    # puts content
    # puts audio
    # puts "audio: #{audio}\n"
    # gets
    if !played
        # out = `mplayer.exe https://memorysheep.com/longmandsl/#{audio}`
        th = Thread.start do
            # puts "explanation: #{explanation}\n"

            wav_path = "G:\\En-En_Longman_DOCE5\\En-En-Longman_DOCE5.dsl.files\\#{audio}"
            `.\\cmdmp3.exe #{wav_path}`

        end
        th.join
        
        # played = true
    end
    trimmed_explanation = explanation.gsub(/\[.*?\]/, '')
    puts trimmed_explanation
    # puts "-------------end---------"

end

def test
    audio_file = "exa_p008-000222108.wav"
    # mplayer.exe https://memorysheep.com/longmandsl/exa_p008-000222108.wav
    out = `mplayer.exe https://memorysheep.com/longmandsl/#{audio_file}`
    # puts out
end
