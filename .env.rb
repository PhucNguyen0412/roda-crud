case ENV['RACK_ENV'] ||= 'development'
when 'test'
  ENV['MY_APP_SESSION_SECRET'] ||= "mPgfofkkEwnVOJD0JlBFRtlze4RZi3y6/lsLSLBkDhHlP+XUzSZKhpEqLZNP\nQl9DohZ0WMiL8oi6yPiU3e4Ilg==\n".unpack('m')[0]
  ENV['MY_APP_DATABASE_URL'] ||= "postgres:///my_app_test?user=my_app"
when 'production'
  ENV['MY_APP_SESSION_SECRET'] ||= "nJYI04rn/f1PvNiMnBklBJ3vOZYKdDiElg7MSbGgLpnUQ1Bckwe1VMqaC1VY\n5rW2orxToJ2RkrFoLVjMnCO1yg==\n".unpack('m')[0]
  ENV['MY_APP_DATABASE_URL'] ||= "postgres:///my_app_production?user=my_app"
else
  ENV['MY_APP_SESSION_SECRET'] ||= "g/Iy27vlHhCWmX7Tq2Th6tFsZtHjOpLYp3l0DCRyE0uWbfa8YLq73X9NQHpL\n3UngcZI3Z2hhJ1anJ0yJpk4vTw==\n".unpack('m')[0]
  ENV['MY_APP_DATABASE_URL'] ||= 'postgres://postgres:postgres@localhost/my_app_development'
end
