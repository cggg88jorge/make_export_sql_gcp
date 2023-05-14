require "functions_framework"
require "json"
require 'uri'
require 'net/http'
require 'googleauth'
require 'google/apis/drive_v3'
require "google/cloud/storage"

FunctionsFramework.http "some" do |request|
  scopes =  [ 
              'https://www.googleapis.com/auth/cloud-platform',
              'https://www.googleapis.com/auth/sqlservice.admin'
            ]

  bucket_name = "some"
  file_name = "some_#{Time.now.strftime("%m-%d-%Y_%H.%M.%S")}.sql"
  uri = URI.parse('https://sqladmin.googleapis.com/v1/projects/some/instances/some/export')

  authorizer = Google::Auth::ServiceAccountCredentials.from_env(scope: scopes)

  response_json = authorizer.fetch_access_token
  token = response_json["access_token"]  
  
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request_new = Net::HTTP::Post.new(uri.request_uri)
  request_new["Authorization"] = "Bearer #{token}"
  request_new["Accept"] = "application/json"
  request_new.content_type = "application/json"
  request_new.body = {
 	"exportContext":
   		{
      		"fileType": "SQL",
      		"uri": "gs://#{bucket_name}/#{file_name}",
      		"databases": ["some"],
      		"offload": false
    	}
	}.to_json
  response = http.request(request_new)

  puts "#{response.code}"
  puts "#{response.message}"

  "ok"

end
