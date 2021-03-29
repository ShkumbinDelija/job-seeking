This is a fun project where I just wanted to check which programming languages are more prominent in Kosovo.

To run the crawler (crawls Gjirafa and Telegrafi) run `ruby crawl.rb` (Please be nice to their servers).

I've made some methods which query the results in the query.rb file.

Example 1:

`ruby query.rb jobs_with_language 'ruby' 'react'` 

Response (retrieves links to the jobs): 

Showing links of jobs that contain language: ruby, react <br/>
"http://gjirafa.com/Shpallje/Pune/remote-senior-net-developer" <br/>
"http://gjirafa.com/Shpallje/Pune/remote-net-developer" <br/>
"http://gjirafa.com/Shpallje/Pune/reactjs-developer-pristina-office" <br/>
"http://gjirafa.com/Shpallje/Pune/remote-senior-net-developer" <br/>
"https://jobs.telegrafi.com/job/remote-php-full-stack-developer-remote-1-1" <br/>
"https://jobs.telegrafi.com/job/remote-ruby-on-rails-engineer-remote" <br/>
"https://jobs.telegrafi.com/job/full-stack-developer-nodereact-full-time" <br/>
"https://jobs.telegrafi.com/job/remote-ruby-on-rails-developer-remote-4-1" <br/>
...

Example 2:

`ruby query.rb language_occurences`

"Programming language: javascript, is mentioned: 107 times." <br/>
"Programming language: php, is mentioned: 98 times." <br/>
"Programming language: python, is mentioned: 49 times." <br/>
"Programming language: java, is mentioned: 46 times." <br/>
"Programming language: c#, is mentioned: 38 times." <br/>
"Programming language: basic, is mentioned: 23 times." <br/>
"Programming language: typescript, is mentioned: 17 times." <br />
...