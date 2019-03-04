# require 'file'
require 'pry'
require 'rails'
require 'sqlite3'
require 'fileutils'
require "active_record"
require 'bulk_insert'


ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database  => "audio.sqlite3"
)
# FileUtils.mv("audio.sqlite3", "audio.sqlite3.#{Time.now.to_i}.bak") if FileTest.exist?("audio.sqlite3")

# CREATE TABLE audios (content, audio,collins, explanation)
ActiveRecord::Schema.define do
  create_table :audios do |table|
      table.column :collins, :integer
      table.column :content, :string
      table.column :audio, :string
      table.column :explanation, :string
  end

  # create_table :tracks do |table|
  #     table.column :album_id, :integer
  #     table.column :track_number, :integer
  #     table.column :title, :string
  # end
end

class Audio < ActiveRecord::Base
  self.table_name = "audios"

  # has_many :tracks
end
puts "----------Audio.count: #{Audio.count}-------------------------------"
puts Audio.count
# puts Audio.all

def main
  path = "G:\\En-En_Longman_DOCE5\\En-En-Longman_DOCE5.dsl\\En-En-Longman_DOCE5.dsl"
  puts "---begin"
  words = []
  hash = {}
  FileUtils.mv("longman.sqlite3", "longman.sqlite3.#{Time.now.to_i}.bak") if FileTest.exist?("longman.sqlite3")
  db=SQLite3::Database.new("longman.sqlite3")
  db.execute("create table longman (content, explanation)")
  inserter=db.prepare("insert into longman (content,explanation) values (?,?)")
  File.open path, "rb:UTF-16LE" do |io|
    puts "---open file"
    i = 0
    # puts io

    temp = ""
    io.each_line do |line|
      if line[0] != " " && line[0] != "\t"
        inserter.execute(temp, hash[temp])
        puts line
        word = line.strip
        words.push(word)
        temp = word
        hash[temp] = ""
        i += 1
        puts i.to_s+' '
      else
        hash[temp]+= line

      end

      # puts line
      # i += 1
      # break if i > 100

    end
    puts hash.count
    # binding.pry
  end
  puts "---end"

  File.open('longman.dump', 'wb') { |f| f.write(Marshal.dump(hash)) }

end

def collins3
  path = "C:\\Users\\jiyuh\\Downloads\\word_list_of58.txt"
  words = []
  File.open path do |io|
    i = 0

    io.each_line do |line|
      words.push line.strip
      i += 1
      # break if i > 100
    end
    # puts hash.count
    # binding.pry
    # puts words
  end
  str = words.join("\',\'")
  File.open('words.txt', 'w') { |f| f.write("('"+str+"')") }
end

def audios
  db=SQLite3::Database.new("longman.sqlite3")
  # FileUtils.mv("audio.sqlite3", "audio.sqlite3.#{Time.now.to_i}.bak") if FileTest.exist?("audio.sqlite3")
  # Audio
  # db2 =SQLite3::Database.new("audio.sqlite3")
  # db2.execute("create table audios (content, audio,collins, explanation)")
  # inserter=db2.prepare("insert into audios (content, audio,collins, explanation) values (?,?,?,?)")
  hash = {}
  Audio.bulk_insert(set_size: 100) do |worker|

    db.execute( "select * from longman" ) do |row|
      #binding.pry
      word = row[0]
      explanation = row[1]
      collins = row[2]
      # explanation.scan(/\[s\](.+?)\[\/s\]/)
      if explanation.present?
        explanation.each_line do |line|
          if line.include?("[s]")
            if line.include?("[lang ")
              audio = line.scan(/\[s\](.+?)\[\/s\]/)[0][0]
              lang = line.scan(/\[lang.+?\](.+?)\[\/lang\]/)[0][0]
              hash[audio] = lang
              # puts "collins: collins, content: word, audio: audio, explanation: lang"
              # puts "collins: #{collins}, content: #{word}, audio: #{audio}, explanation: #{lang}"
              worker.add(collins: collins, content: word, audio: audio, explanation: lang)
              # inserter.execute(word, audio,collins, lang)
            else
              # audio = line.scan(/\[s\](.+?)\[\/s\]/)[0]
              # lang = line.strip
              # hash[audio] = lang
              # inserter.execute(word, audio,collins, lang)
              # puts "collins: #{collins}, content: #{word}, audio: #{audio}, explanation: #{lang}"

              line.scan(/\[s\](.+?)\[\/s\]/).each do | audio |
                audio = audio.first
                lang = line.strip
                hash[audio] = lang
                
                # inserter.execute(word, audio,collins, lang)
                worker.add(collins: collins, content: word, audio: audio, explanation: lang)

              end


            end
          end
        end
      end

    end
  end
  File.open('longman_audios.dump', 'wb') { |f| f.write(Marshal.dump(hash)) }
end

def play(audio)
  wav_path = "G:\\En-En_Longman_DOCE5\\En-En-Longman_DOCE5.dsl.files\\#{audio}"
  `.\\cmdmp3.exe #{wav_path}`
end

# main
audios