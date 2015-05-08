# encoding: UTF-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


connection = ActiveRecord::Base.connection();

connection.execute(IO.read(Gem.loaded_specs['sip'].full_gem_path +
                           "/db/datos-basicas.sql"));
connection.execute(IO.read("db/datos-basicas.sql"));


connection.execute("INSERT INTO usuario 
	(nusuario, email, encrypted_password, password, 
  fechacreacion, created_at, updated_at, rol, confirmed_at) 
	VALUES ('sal7711', 'sal7711', 
	'$2a$10$RzZB8e0HK/RF4jTnTB7kiOEa7Hc/pI.xBGaXqhjTm1YFHVFEPFKEG', 
	'', '2014-08-26', '2014-08-26', '2014-08-26', 1, '2015-05-07');")

