# frozen_string_literal: true

require 'selenium-webdriver'
require 'sqlite3'
require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'jobs.db')

class Language < ActiveRecord::Base
end

class Job < ActiveRecord::Base
end

def generate_languages
  return unless Language.count.zero?

  File.open('languages.txt', 'r') do |file|
    file.each_line do |line|
      JSON.parse(line[1...line.size - 1]).each do |language|
        Language.create(name: language, downcased: language.downcase)
      end
    end
  end
end

def create_jobs_table
  return if ActiveRecord::Base.connection.table_exists?('jobs')

  SQLite3::Database.new('jobs.db').execute <<-SQL
  CREATE TABLE jobs (
    title TEXT,
    description TEXT,
    href TEXT
  );
  SQL
end

def create_languages_table
  return if ActiveRecord::Base.connection.table_exists?('languages')

  SQLite3::Database.new('jobs.db').execute <<-SQL
  CREATE TABLE languages (
    name TEXT,
    downcased TEXT
  );
  SQL
end

def fetch_links_from_gjirafa(browser, job_links)
  path = proc do |page = nil|
    f = page == nil ? '?k=Teknologji%20Informative%20-%20IT' : "?f=#{page}&k=Teknologji%20Informative%20-%20IT"
    "https://gjirafa.com/Top/Pune#{f}"
  end
  browser.navigate.to path.call
  browser.switch_to.frame browser.find_element(id: 'iframe_cookie')
  browser.find_element(xpath: '/html/body/div/div/button').click
  browser.switch_to.default_content
  number_of_pages = browser.find_element(xpath: '/html/body/div[1]/div[5]/div/div[6]/div[3]/p/strong[2]').text.to_i
  1.upto(number_of_pages) do |current_page_number|
    jobs = browser.find_elements(css: '#rezultatet > div.resultsAll.srcResults > ul > li')
    jobs.each { |job| job_links << job.find_element(tag_name: 'a').attribute('href') }
    break if number_of_pages == current_page_number

    browser.navigate.to path.call(current_page_number)
  end
end

def fetch_links_from_telegrafi(browser, job_links)
  100.times do |page|
    browser.navigate.to "https://jobs.telegrafi.com/?q=&vendi=&kategoria=Teknologji+Informative+-+IT&page=#{page}"
    jobs = browser.find_elements(css: '.homeJobContainer > ul > li')
    break if jobs.empty?

    jobs.each { |job| job_links << job.find_element(tag_name: 'a').attribute('href') }
  end
end

def fetch_jobs_from_gjirafa(browser, links)
  links.each do |link|
    browser.navigate.to(link)
    title = browser.find_element(class: 'primeAdsTitle').text
    description = browser.find_element(class: 'description').text
    Job.create(title: title, description: description, href: link)
  end
end

def fetch_jobs_from_telegrafi(browser, links)
  links.each do |link|
    browser.navigate.to(link)
    title = browser.find_element(css: '.shpallje-job-name > h3').text
    description = browser.find_element(class: 'shpallje-info').text
    Job.create(title: title, description: description, href: link)
  end
end

def fetch_jobs(browser, job_links)
  jobs = { telegrafi: [], gjirafa: [] }
  job_links.each do |link|
    next if Job.exists?(href: link.strip!)

    jobs[link.start_with?('https://jobs.telegrafi.com') ? :telegrafi : :gjirafa].push(link)
  end
  fetch_jobs_from_gjirafa(browser, jobs[:gjirafa])
  fetch_jobs_from_telegrafi(browser, jobs[:telegrafi])
end

begin
  job_links = []
  options = Selenium::WebDriver::Chrome::Options.new(args: ['--headless'])
  browser = Selenium::WebDriver.for :chrome, options: options
  create_jobs_table
  create_languages_table
  generate_languages
  fetch_links_from_gjirafa(browser, job_links)
  fetch_links_from_telegrafi(browser, job_links)
  fetch_jobs(browser, job_links)
ensure
  ActiveRecord::Base.clear_active_connections!
  browser.quit
end
