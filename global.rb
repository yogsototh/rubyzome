# Global configuration file

# write here the list of format you want your application to output
$viewsToLoad=["JSON","XML","HTML"]
$static_files_directory='/static'

# the DB URL default is an sqlite db file: datas.db 
# if the env variable DATABASE_URL is set it is the one choosen
# With this it works seemlessly with heroku
$db_url = case ENV['GPENV']
	when "PRODUCTION" then "postgres://mnyqdiisby:f5lxx1zz5pnorynqglhzmsp34@ec2-174-129-199-187.compute-1.amazonaws.com/mnyqdiisby"
	when "PREPROD" then "postgres://xnerjchzzq:f5lxx1zz5pnorynqglhzmsp34@ec2-50-16-228-68.compute-1.amazonaws.com/xnerjchzzq"
	when "LGP" then "postgres://ozzouhncpp:f5lxx1zz5pnorynqglhzmsp34@ec2-184-72-236-246.compute-1.amazonaws.com/ozzouhncpp"
	when "Y" then "" # TODO
	else ENV['DATABASE_URL'] || %{sqlite3://#{Dir.pwd}/datas.db}
end
