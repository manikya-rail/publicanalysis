# frozen_string_literal: true

require 'httparty'
require 'csv'

# class for the analysis
class GitHubRepoAnalysis
  # setting attribute readers
  attr_reader :parent_lang_hash

  def initialize
    # initializing both hashes
    @parent_lang_hash = Hash.new(0)
  end

  def init_api_call
    # reading api result to create the desired language hash
    url = 'https://api.github.com/orgs/google/repos'
    response = HTTParty.get(url)
    parsed_res = response.parsed_response
    parsed_res.each do |json_res|
      parent_lang_hash[json_res['language']] += 1
    end

    display_most_used(parent_lang_hash)
    display_least_used(parent_lang_hash)
    generate_csv(parsed_res)
    puts "\n Downloaded csv....\n\n"
  end

  def display_most_used(languages)
    # most used languages
    puts "\n Most used languages"
    puts Hash[languages.sort_by { |_k, v| -v }[0..4]]
  end

  def display_least_used(languages)
    # less used languages
    puts "\n Less used languages"
    puts Hash[languages.sort_by { |_k, v| v }[0..4]]
  end
  
  def generate_csv(parsed_res)
    # writing contents to output file
    CSV.open('Api_result.csv', 'wb') do |csv|
      csv << ['Repository name', 'language', 'Created Date']
      parsed_res.each do |value|
        unless value['language'].nil?
          csv << [value['name'], value['language'], value['created_at']]
        end
      end
    end
  end

end
GitHubRepoAnalysis.new.init_api_call
