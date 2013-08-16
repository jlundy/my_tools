require_relative './jenkins'

# Setup the base params for contacting the jenkins jobs 
base_uri = ENV["JENKINS_URL"] + "job/"
job_version = "lastCompletedBuild/"
api_loc = "api/xml/"
junit_loc = "testReport/"
job_name = ENV["TEST_JOB_NAME"] 

jenkinsCaller = Jenkins.new(ENV["USERNAME"], ENV["PASSWORD"])
job_uri = base_uri + job_name + "/"
job_api_response = jenkinsCaller.getJobApi(:job => job_uri + api_loc, :depth => 1)

job_history=job_api_response['build']
job_runs=job_history.size

total_failures = 0
failedJobs = Array.new(job_runs)

(job_api_response['build']).each do |build|
  jobNum = build['number'][0]
  failureCount = "0"

  # parse through every action element until I find the failed tests
  # because jenkins is not consistent with which action element it places these
  # I have to try to find it
  (build['action']).each do |action|
    begin 
      failureCount = action['failCount'][0]
      if ( failureCount != "0" )
        failedJobs[total_failures] = jobNum
        total_failures += 1
      end
      break
    rescue
      next 
    end
  end
end

puts total_failures.to_s + " of " + job_runs.to_s + " jobs failed for #{job_name}" 

# Now that we have all the failed build numbers
# We can go through the array and get the reason for those failures
failedJobs.each do | failedJob |
  if failedJob == nil
    break
  end
  puts"\n\nJob number #{failedJob}"
  job_api_response = jenkinsCaller.getJobApi(:job => job_uri + failedJob.to_s + "/" +  junit_loc + api_loc, :depth => 0)
  (job_api_response['suite']).each do | suite |
    (suite['case']).each do | testcase |
      if (testcase['status'][0] != "PASSED")
        puts "Failure:  " + testcase['name'][0]
        puts "  " + testcase['errorDetails'].to_s
      end
    end
  end
end
