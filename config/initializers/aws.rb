Aws.config.update({
  credentials: Aws::Credentials.new(ENV["AWS_ACCESS_KEY_ID"], ENV["AWS_SECRET_ACCESS_KEY"]),
  region: "us-west-2",
  endpoint: "http://localhost:8000"

})