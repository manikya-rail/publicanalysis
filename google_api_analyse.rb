# frozen_string_literal: true

require 'httparty'
require 'csv'

class GitHubRepoAnalysis
  # setting attribute readers
  attr_reader :parent_lang_hash
  attr_reader :languages

  def initialize
    # initializing both hashes
    @parent_lang_hash = {}
    @languages = {}
  end

  def init_api_call
    # reading api result to create the desired language hash
    url = 'https://api.github.com/orgs/google/repos'
    response = HTTParty.get(url)
    parsed_res = response.parsed_response
    parsed_res.each  do |json_res|
      json_res.each  do |key, val|
        if key.to_s == 'language'
          if parent_lang_hash.key?(val)
            parent_lang_hash[val][val] += 1
            parent_lang_hash[val]["reponame_#{parent_lang_hash[val][val]}"] = json_res['name']
            parent_lang_hash[val]["create_date_#{parent_lang_hash[val][val]}"] = json_res['created_at']
          else
            parent_lang_hash[val] = {}
            parent_lang_hash[val][val] = 1
            parent_lang_hash[val]['name'] = val
            parent_lang_hash[val]['reponame_1'] = json_res['name']
            parent_lang_hash[val]['create_date_1'] = json_res['created_at']
          end
        end
      end
    end
    create_output_file
    write_to_output_file(parent_lang_hash)
  end

  def create_output_file
    # creating output file
    CSV.open('Api_result.csv', 'a') do |csv|
      csv << ['Language', 'Repository name', 'Created Date']
    end
  end

  def write_to_output_file(parent_lang_hash)
    # writing contents to output file
    parent_lang_hash.each do |key, _val|
      languages[parent_lang_hash[key]['name']] = parent_lang_hash[key][key].to_i

      CSV.open('Api_result.csv', 'a') do |csv|
        parent_lang_hash[key][key].to_i.times do |count|
          csv << [parent_lang_hash[key]['name'], parent_lang_hash[key]["reponame_#{count + 1}"], parent_lang_hash[key]["create_date_#{count + 1}"]]
        end
      end
    end
    display_most_used(languages)
    display_least_used(languages)
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
end

GitHubRepoAnalysis.new.init_api_call
