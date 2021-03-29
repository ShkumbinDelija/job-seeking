# frozen_string_literal: true

require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'jobs.db')

class Language < ActiveRecord::Base
end

class Job < ActiveRecord::Base
end

def build_query_from_languages(languages)
  query = ''
  languages.size.times do |index|
    query += '(lower(title) LIKE ? OR lower(description) LIKE ? OR lower(href) LIKE ?)'
    query += ' OR ' unless index + 1 == languages.size
  end
  query
end

def jobs_with_language(languages)
  puts "\nShowing links of jobs that contain language: #{languages.join(', ')} \n\n"
  bind_variables = languages.map { |language| [(language = "%#{language.downcase}%"), language, language] }.flatten
  Job.where(build_query_from_languages(languages), *bind_variables).pluck(:href).each { |href| p href }
end

def language_occurences(_args)
  occurrences = {}
  Job.all.pluck(:description).compact.join(' ').split(' ').each do |word|
    if Language.exists?(downcased: word.downcase!)
      occurrences[word] = occurrences.key?(word) ? occurrences[word] + 1 : 1
    end
  end
  occurrences.sort_by { |_k, v| v }.reverse.to_h.each_key do |key|
    p "Programming language: #{key}, is mentioned: #{occurrences[key]} times."
  end
end

begin
  send(ARGV[0], ARGV[1..(ARGV.size)]) if ARGV.any?
ensure
  ActiveRecord::Base.clear_active_connections!
end
